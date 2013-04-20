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
    my $capitalize_next = 0;
    my $i;
    my @fonets;
    my $offset = 0;
    LINE:
    while (<>) {
        if (/-- word alignment --/) {
            $in_wa = 1;
            $i = 0;
            $offset = shift @$splits;
        };
        if (/=== end forced alignment ===/) {
            $in_wa = 0;
        }
        if (/pass1_best_phonemeseq:/ or /phseq1:/) {
            s/^\S*: //;
            @fonets = split / \| /;
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
            push @rv, \%rec;
            $i++;
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
