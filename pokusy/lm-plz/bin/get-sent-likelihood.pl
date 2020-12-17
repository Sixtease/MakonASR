#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;
use Encode qw(decode decode_utf8 encode_utf8);

my $lm_fn = shift;
open my $lm_fh, '<', $lm_fn;
for (1 .. 4) {
  scalar <$lm_fh>;
}

my %lm;

print STDERR "loading language model ... ";

while (my ($tok_log_lh, $enc_token) = split /\s+/, scalar <$lm_fh>) {
  my $token = lc decode 'iso-8859-2', $enc_token;
  $lm{$token} = $tok_log_lh;
  
}
close $lm_fh;
print STDERR "done\n";

while (<>) {
  print STDERR '.' if $. % 10000 == 0;
  say STDERR $. if $. % 1e6 == 0;
  chomp;
  my $sent = my $in_sent = decode_utf8($_);
  for ($sent) {
    s/\W+/ /g;
    s/^ +//;
    s/ +$//;
  }
  my $sent_log_lh = 0;
  my @inwords = split /\s+/, lc $sent;
  next if not @inwords;
  for (@inwords) {
    $sent_log_lh += ($lm{$_} // $lm{'<unk>'});
  }
  my $weighted_lh = $sent_log_lh / @inwords;
  say encode_utf8 "$weighted_lh $in_sent";
}
