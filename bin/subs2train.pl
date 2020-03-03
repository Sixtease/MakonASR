#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

my ($in_mfcc_dir, $out_mfcc_dir, $in_audio_dir, $out_audio_dir, $train_out_mlf_fn, $test_out_mlf_fn) = @ARGV;

my $IN_AUDIO_SUF = $ENV{MAKONFM_INPUT_AUDIO_FORMAT} || 'flac';

my %is_test = map {;$_=>1} split /:/, $ENV{MAKONFM_TEST_TRACKS};
my $test_start = $ENV{MAKONFM_TEST_START_POS} || 0;
my $test_end   = $ENV{MAKONFM_TEST_END_POS}   || 'Infinity';

open my $train_mlf_fh, '>:utf8', $train_out_mlf_fn or die "Couldn't open '$train_out_mlf_fn': $!";
open my $test_mlf_fh,  '>:utf8', $test_out_mlf_fn  or die "Couldn't open '$test_out_mlf_fn': $!";

my $log_fh;
if ($ENV{SUB_EXTRACTION_LOG}) {
    open $log_fh, '>', $ENV{SUB_EXTRACTION_LOG};
}

print {$train_mlf_fh} "#!MLF!#\n";
print {$test_mlf_fh}  "#!MLF!#\n";

$/ = '';
LINE:
while (<STDIN>) {
    my ($head, $sent, $end) = split /\n/;
    my ($sid, $filestem, $start) = split /\s+/, $head;
    my $in_mfcc_fn = "$in_mfcc_dir/$filestem.mfcc";
    my $out_mfcc_fn = "$out_mfcc_dir/$sid.mfcc";
    my $in_audio_fn = "$in_audio_dir/$filestem.$IN_AUDIO_SUF";
    my $out_audio_fn = "$out_audio_dir/$sid.wav";

    my $mlf_fh = $train_mlf_fh;
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
    
    my ($cmd, $error);
    
    if ($ENV{HCOPY_FROM_AUDIO}) {
        next if not -e $in_audio_fn;

        my $wav_fn = ($IN_AUDIO_SUF eq 'wav') ? $in_audio_fn : "$ENV{EV_workdir}wav/$filestem.wav";
        system qq(mkdir -p "$ENV{EV_workdir}mfcc");
        my $mfcc_fn = "$ENV{EV_workdir}mfcc/$filestem.mfcc";

        if (-e $wav_fn) { }
        else {
            system qq(mkdir -p "$ENV{EV_workdir}wav");
            unlink glob("$ENV{EV_workdir}wav/*");
            warn "'$in_audio_fn' => '$wav_fn'\n";
            cmd(qq(sox "$in_audio_fn" --channels 1 "$wav_fn" remix -))
                or next LINE;
        }
        if (-e $mfcc_fn) { }
        else {
            warn "'$wav_fn' => '$mfcc_fn'\n";
            cmd(qq(HCopy -C "$ENV{EV_homedir}resources/htk-config-wav2mfcc-full" "$wav_fn" "$mfcc_fn"))
                or next LINE;
        }

        cmd(qq(HCopy -T 1 -C "$ENV{EV_homedir}resources/htk-config-mfcc2mfcc-full" -s ${start}e7 -e ${end}e7 "$mfcc_fn" "$out_mfcc_fn"))
            or next LINE;
        cmd(qq(sox "$wav_fn" "$out_audio_fn" trim "$start" "=$end"))
            or next LINE;
    }
    else {
        next if not -e $in_mfcc_fn;

        cmd(qq(HCopy -T 1 -C "$ENV{EV_homedir}resources/htk-config-mfcc2mfcc-full" -s ${start}e7 -e ${end}e7 "$in_mfcc_fn" "$out_mfcc_fn"))
            or next LINE;
        print {$log_fh} qq(\$ sox "$in_audio_fn" --channels 1 "$out_audio_fn" trim "$start" "=$end" remix -\n) if $log_fh;
    }
    
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
