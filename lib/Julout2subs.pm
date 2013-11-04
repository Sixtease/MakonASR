package Julout2subs;

use strict;
use utf8;
use Encode qw(decode);
use Evadevi::Util qw(get_filehandle);
use JSON ();

my $enc = $ENV{EV_encoding};

sub parse {
    my ($fh, $splits) = @_;
    my @rv;
    my $in_wa = 0;
    my $in_pa = 0;
    my $capitalize_next = 0;
    my ($i,$j);
    my @fonets;
    my @cmscores;
    my $offset = 0;
    my $prev_r;
    #my %word2phone_cnt;
    my @phone_num_to_word;
    LINE:
    while (<>) {
        if (/-- word alignment --/) {
            $in_wa = 1;
            $i = 0;
            #%word2phone_cnt = ();
            @phone_num_to_word = ();
            $offset = shift @$splits;
        };
        if (/-- phoneme alignment --/) {
            $in_pa = 1;
            $j = 0;
        }
        if (/=== end forced alignment ===/) {
            $in_wa = $in_pa = 0;
        }
        if (/pass1_best_phonemeseq:/ or /phseq1:/) {
            s/^\S*: //;
            @fonets = split / \| /;
        }
        if (/cmscore1:/) {
            s/^\S*: //;
            @cmscores = split /\s+/;
        }
        if ($in_wa) {
            my ($start, $end, $score, $word_bytes) = /\[\s*(\d+)\s+(\d+)\s*\]\s*(-?[\d.]+)\s+(\S+)/ or next LINE;
            my $word = decode($enc, $word_bytes);
            if ($word eq '<s>') {
                $capitalize_next = 1;
                $i++;
                next LINE
            }
            if ($word eq '</s>') {
                $rv[-1]{occurrence} .= '.' if @rv;
                next LINE
            }
            my %rec = (timestamp => $offset + $start/100, wordform => lc $word);
            if ($capitalize_next) {
                $rec{occurrence} = ucfirst lc $word;
                $capitalize_next = 0;
            }
            else {
                $rec{occurrence} = lc $word;
            }
            $rec{fonet} = $fonets[$i];
            $rec{fonet} =~ s/^\s+|\s+$//;
            
            my @phones = split /\s+/, $rec{fonet};
            #$word2phone_cnt{\%rec} = scalar(@phones);
            push(@phone_num_to_word, map(scalar(@rv), @phones));
            
            $rec{cmscore} = $cmscores[$i];
            push @rv, \%rec;
            $i++;
        }
        if ($in_pa) {
            my ($start, $end, $triphone) = /\[\s*(\d+)\s+(\d+)\s*\]\s*-?[\d.]+\s+([-+\w]+)/ or next LINE;
            
            next if $triphone eq 'sil';
            
            my ($l,$monophone,$r);
            if (($l,$monophone,$r) = $triphone =~ /(\w+)-(\w+)\+(\w+)/) { }
            elsif (($monophone,$r) = $triphone =~ /(\w+)\+(\w+)/) { }
            elsif (($l,$monophone) = $triphone =~ /(\w+)-(\w+)/) { }
            else {
                $monophone = $triphone;
            }
            
            # not all sp's are in phone alignment;
            # hence, we must pretend as if they were here based on the context
            # to correct the positional matching between word alignment
            # and phone alignment
            if ($l eq 'sp' and $prev_r eq 'sp') {
                $j++;
            }
            
            if ($monophone eq 'sp') {
                my $word_i = $phone_num_to_word[$j];
                $rv[$word_i]{slen} = ($end - $start) / 100;
            }
            
            $j++;
            
            $prev_r = $r;
        }
    }
    return \@rv
}

sub json_start {
    my ($stem) = @_;
    return qq/jQuery(document).trigger("got_subtitles.MakonFM", { "filestem": "$stem", "data": /
}
sub json_end {
    return "\n});\n"
}

sub convert {
    my ($fh, $splits_file, $stem) = @_;
    my $splits_fh = get_filehandle($splits_file);
    my @splits;
    while (<$splits_fh>) {
        /([\d.]+)\s*\.\./ and push @splits, $1;
    }
    my $subs = parse($fh, \@splits);
    return json_start($stem) . JSON->new->pretty->encode($subs) . json_end();
}

1

__END__
