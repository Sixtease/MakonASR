#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;
use Encode qw(decode decode_utf8 encode_utf8);

sub load_lm {
  my ($lm_fn) = @_;
  open my $lm_fh, '<', $lm_fn;
  for (1 .. 4) {
    scalar <$lm_fh>;
  }

  my %lm;
  while (my ($tok_log_lh, $enc_token) = split /\s+/, scalar <$lm_fh>) {
    my $token = lc decode 'iso-8859-2', $enc_token;
    $lm{$token} = $tok_log_lh;
    
  }
  close $lm_fh;
  return \%lm;
}

say STDERR "loading language models ...";
my @lms;
for my $lm_fn (@ARGV) {
  say STDERR $lm_fn;
  push @lms, load_lm($lm_fn);
}
say STDERR "done";

while (<STDIN>) {
  print STDERR '.' if $. % 10000 == 0;
  say STDERR $. if $. % 1e6 == 0;
  chomp;
  my $sent = my $in_sent = decode_utf8($_);
  for ($sent) {
    s/\W+/ /g;
    s/^ +//;
    s/ +$//;
  }
  my @sent_log_lh = map 0, @lms;
  my @inwords = split /\s+/, lc $sent;
  next if not @inwords;
  for my $i (0 .. $#lms) {
    my $lm = $lms[$i];
    for (@inwords) {
      $sent_log_lh[$i] += ($lm->{$_} // $lm->{'<unk>'});
    }
  }
  my @weighted_lh = map {; $_ / @inwords } @sent_log_lh;
  say encode_utf8 "@weighted_lh $in_sent";
}
