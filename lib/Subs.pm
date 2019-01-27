package Subs;

use 5.010;
use strict;
use warnings;
use utf8;
use Exporter qw(import);
use JSON::XS qw(decode_json encode_json);

my $json = JSON::XS->new->pretty(1)->space_before(0);

our @EXPORT_OK = qw(decode_subs encode_subs json_start json_end);

our $pad_start = 'jsonp_subtitles(';
our $pad_end   = ");\n";
sub json_start {
    my ($stem) = @_;
    return qq/$pad_start\{ "filestem": "$stem", "data": /;
}
sub json_end {
    return "\n}$pad_end";
}
sub encode_subs {
    my ($data, $stem) = @_;
    return json_start($stem) . $json->encode($data) . json_end();
}

sub decode_subs {
    my ($subs_arg) = @_;
    my $subs_fh;
    my $json;
    if (ref $subs_arg eq 'GLOB' or ref(\$subs_arg) eq 'GLOB') {
        $subs_fh = $subs_arg;
    }
    elsif (index($subs_arg, 'jsonp_subtitles(') >= 0) {
        $json = $subs_arg;
    }
    else {
        open $subs_fh, '<', $subs_arg or die "Couldn't open subs $subs_arg for reading: $!";
    }
    $json ||= join('', <$subs_fh>);
    
    $json =~ s/^[^{]+//;
    $json =~ s/[^}]+$//;

    undef $@;
    my $subs = decode_json($json);
    return $subs;
}

42;

__END__
