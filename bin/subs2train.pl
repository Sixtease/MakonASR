#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

my ($in_mfcc_dir, $out_mfcc_dir, $in_audio_dir, $out_audio_dir, $out_mlf_fn) = @ARGV;

open my $mlf_fh, '>:utf8', $out_mlf_fn or die "Couldn't open '$out_mlf_fn': $!";

my $log_fh;
if ($ENV{SUB_EXTRACTION_LOG}) {
    open $log_fh, '>', $ENV{SUB_EXTRACTION_LOG};
}

print {$mlf_fh} "#!MLF!#\n";

$/ = '';
LINE:
while (<STDIN>) {
    my ($head, $sent, $end) = split /\n/;
    my ($sid, $filestem, $start) = split /\s+/, $head;
    my $in_mfcc_fn = "$in_mfcc_dir/$filestem.mfcc";
    my $out_mfcc_fn = "$out_mfcc_dir/$sid.mfcc";
    my $in_audio_fn = "$in_audio_dir/$filestem.mp3";
    my $out_audio_fn = "$out_audio_dir/$sid.wav";
    
    print {$log_fh} "$filestem $start .. $end => $sid\n" if $log_fh;
    next if not -e $in_mfcc_fn;
    
    my ($cmd, $error);
    
    if ($ENV{HCOPY_FROM_AUDIO}) {
        my $wav_fn  = "$ENV{EV_workdir}temp/wav/$filestem.wav";
        my $mfcc_fn = "$ENV{EV_workdir}temp/wav/$filestem.mfcc";
        if (-e $wav_fn) { }
        else {
            system qq(mkdir -p "$ENV{EV_workdir}temp/wav");
            unlink glob("$ENV{EV_workdir}temp/wav/*");
            cmd(qq(sox "$in_audio_fn" --channels 1 "$wav_fn" mixer))
                or next LINE;
            cmd(qq(HCopy -C "$ENV{EV_homedir}resources/htk-config-wav2mfcc-full" "$wav_fn" "$mfcc_fn"))
                or next LINE;
        }
        cmd(qq(HCopy -T 1 -C "$ENV{EV_homedir}resources/htk-config-mfcc2mfcc-full" -s ${start}e7 -e ${end}e7 "$mfcc_fn" "$out_mfcc_fn"))
            or next LINE;
        cmd(qq(sox "$wav_fn" "$out_audio_fn" trim "$start" "=$end"))
            or next LINE;
    }
    else {
        cmd(qq(HCopy -T 1 -C "$ENV{EV_homedir}resources/htk-config-mfcc2mfcc-full" -s ${start}e7 -e ${end}e7 "$in_mfcc_fn" "$out_mfcc_fn"))
            or next LINE;
        cmd(qq(sox "$in_audio_fn" --channels 1 "$out_audio_fn" trim "$start" "=$end" mixer))
            or next LINE;
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
