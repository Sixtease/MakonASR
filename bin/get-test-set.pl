#!/usr/bin/perl

# expects output of get_humanic_subs.pl on input

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

my ($in_audio_dir, $out_audio_dir, $test_out_mlf_fn) = @ARGV;

my %is_test = map {;$_=>1} split /:/, $ENV{MAKONFM_TEST_TRACKS};
my $test_start = $ENV{MAKONFM_TEST_START_POS} || 0;
my $test_end   = $ENV{MAKONFM_TEST_END_POS}   || 'Infinity';

open my $test_mlf_fh,  '>:utf8', $test_out_mlf_fn  or die "Couldn't open '$test_out_mlf_fn': $!";

my $log_fh;
if ($ENV{SUB_EXTRACTION_LOG}) {
    open $log_fh, '>', $ENV{SUB_EXTRACTION_LOG};
}

print {$test_mlf_fh}  "#!MLF!#\n";

$/ = '';
LINE:
while (<STDIN>) {
    my ($head, $sent, $end) = split /\n/;
    my ($sid, $filestem, $start) = split /\s+/, $head;
    my $in_audio_fn = "$in_audio_dir/$filestem.wav";
    my $out_audio_fn = "$out_audio_dir/$sid.wav";

    my $mlf_fh;
    my $is_test_sent = 0;
    if ($is_test{$filestem}
        and $start > $test_start
        and $end   < $test_end
    ) {
        $mlf_fh = $test_mlf_fh;
        $is_test_sent = 1;
    }
    
    my $kind = $is_test_sent ? 'test' : 'train';
    print {$log_fh} "$filestem $start .. $end => $sid ($kind)\n" if $log_fh;
    next if not $is_test_sent;
    
    my ($cmd, $error);
    
    cmd(qq(sox "$in_audio_fn" --channels 1 "$out_audio_fn" trim "$start" "=$end" remix -));
    
    print {$mlf_fh} qq("*/$sid.lab"\n);
    $sent =~ s/\s+/\n/g;
    1 while chomp $sent;
    $sent .= "\n.\n";
    print {$mlf_fh} uc $sent;
}

sub cmd {
    my ($cmd) = @_;
    my $error = system($cmd);
    if ($error) {
        print {$log_fh || 'STDERR'} "Command failed (#$error): $cmd\n";
        return 0
    }
    return 1
}
