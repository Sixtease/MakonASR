#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Encode;

my $dbh = eval { require DBI; DBI->connect('dbi:Pg:dbname=MakonFM','sixtease','',{AutoCommit=>0}) };
if (not $dbh) { warn "No DB connection, omitting dictionary" }

my $enc = $ENV{EV_encoding} || 'UTF-8';

my %phone_map;
my $phone_map_fn = $ENV{MAKONFM_PHONE_MAP};
if (open my $phone_map_fh, '<', $phone_map_fn) {
    %phone_map = map {chomp; split /\s+/, $_, 2} <$phone_map_fh>;
}

my $out_fn = pop @ARGV;
if ($out_fn) {
    close STDOUT;
    open STDOUT, '>', $out_fn or die "Couldn't open '$out_fn': $!";
}

LINE:
while (<>) {
    for (decode($enc, $_)) {
        chomp;
        my $writ = $_;
        if (/[^\w\s]/) {
            print encode($enc, $writ), (' ' x 7), "sil\n";
            next
        }
        my $out = '';
        if (my @spec = specialcase()) {
            for my $pron (@spec) {
                $out .= $writ . (' ' x 7) . $pron . "\n";
            }
        }
        $out .= $writ;
        $out .= (' ' x 7);
        init();
        prepis();
        tr/[A-Z]/[a-z]/;
        prague2pilsen();
        infreq();
        add_sp();
        if (/[^a-z ]/) {
            warn "unvyslovable $_\n";
            next
        }
        $out .= "$_\n";
        print encode($enc, $out);
        print_variants($writ);
    }
}

sub specialcase {
    return if not $dbh;
    my $ref = $dbh->selectcol_arrayref('SELECT pron FROM dict WHERE form=?', {}, $_);
    return @$ref
}

sub init {
    if (/ß/) { deutsch() };
    s/NISM/NYZM/g;
    s/TISM/TYZM/g;
    s/ANTI/ANTY/g;
    s/AKTI/AKTY/g;
    s/ATIK/ATYK/g;
    s/TICK/TYCK/g;
    s/KANDI/KANDY/g;
    s/NIE/NYE/g;
    s/NII/NYY/g;
    s/ARKTI/ARKTY/g;
    s/ATRAKTI/ATRAKTY/g;
    s/AUDI/AUDY/g;
    s/CAUSA/KAUZA/g;
    s/CELSIA/CELZIA/g;
    s/CHIL/ČIL/g;
    s/DANIH/DANYH/g;
    s/EFEKTIV/EFEKTYV/g;
    s/FINITI/FINYTY/g;
    s/DEALER/D ii LER/g;
    s/DIAG/DYAG/g;
    s/DIET/DYET/g;
    s/DIF/DYF/g;
    s/DIG/DYG/g;
    s/DIKT/DYKT/g;
    s/DILET/DYLET/g;
    s/DIPL/DYPL/g;
    s/DIRIG/DYRYG/g;
    s/DISK/DYSK/g;
    s/DISPLAY/DYSPLEJ/g;
    s/DISP/DYSP/g;
    s/DIST/DYST/g;
    s/DIVIDE/DYVIDE/g;
    s/^DOUČ/DO!UČ/;
    s/DUKTI/DUKTY/g;
    s/EDIC/EDYC/g;
    s/^EX(?=[AEIOUÁÉÍÓÚŮ])/EGZ/;
    s/ELEKTRONI/ELEKTRONY/g;
    s/ENERGETI/ENERGETY/g;
    s/ETIK/ETYK/g;
    s/FEMINI/FEMINY/g;
    s/FINIŠ/FINYŠ/g;
    s/MONIE/MONYE/g;
    s/GENETI/GENETY/g;
    s/GIENI/GIENY/g;
    s/IMUNI/IMUNY/g;
    s/^INDI(?=.)/INDY/;
    s/INDIV/INDYV/g;
    s/INICI/INYCI/g;
    s/INVESTI/INVESTY/g;
    s/KARATI/KARATY/g;
    s/KARDI/KARDY/g;
    s/KLAUS(?=.)/KLAUZ/g;
    s/KOMUNI/KOMUNY/g;
    s/KONDI/KONDY/g;
    s/KREDIT/KREDYT/g;
    s/KRITI/KRITY/g;
    s/KOMODIT/KOMODYT/g;
    s/KONSOR/KONZOR/g;
    s/LEASING/L ii z ING/g;
    s/GITI/GITY/g;
    s/MEDI/MEDY/g;
    s/MOTIV/MOTYV/g;
    s/MANAG/MENEDŽ/g;
    s/NSTI/NSTY/g;
    s/MINI/MINY/g;
    s/MINUS/MÝNUS/g;
    s/ING/YNG/g;
    s/GATIV/GATYV/g;
    s/(?<=.)MATI/MATY/g;
    s/^MATI(?=[^CČN])/MATY/;
    s/^MATINÉ/MATYNÉ/;
    s/MANIP/MANYP/g;
    s/MODERNI/MODERNY/g;
    s/NAU/NA!U/;
    s/ZAU/ZA!U/;
    s/^NE/NE!/;
    s/^ODD/OD!D/;
    s/^ODT/OT!T/;
    s/^ODI(?=[^V])/ODY/;
    s/ORGANI/ORGANY/g;
    s/OPTIM/OPTYM/g;
    s/PANICK/PANYCK/g;
    s/PEDIATR/PEDYATR/g;
    s/PERVITI/PERVITY/g;
    s/^PODD/POD!D/g;
    s/^PODT/POT!T/g;
    s/POLITI/POLITY/g;
    s/POZIT/POZYT/g;
    s/^POUČ/PO!UČ/g;
    s/^POULI/PO!ULI/g;
    s/PRIVATI/PRIVATY/g;
    s/PROSTITU/PROSTYTU/g;
    s/^PŘED(?=[^Ě])/PŘED!/;
    s/RADIK/RADYK/g;
    s/^RADIO/RADYO/;
    s/RELATIV/RELATYV/g;
    s/RESTITU/RESTYTU/g;
    s/ROCK/ROK/g;
    s/^ROZ/ROZ!/g;
    s/RUTIN/RUTYN/g;
    s/^RÁDI(?=.)/RÁDY/g;
    s/SCHWARZ/ŠVARC/g;
    s/SCHW/ŠV/g;
    s/SHOP/ŠOP/g;
    s/^SEBE/SEBE!/g;
    s/^SHO/SCHO/g;
    s/SOFTWAR/SOFTVER/g;
    s/SORTIM/SORTYM/g;
    s/SPEKTIV/SPEKTYV/g;
    s/SUPERLATIV/SUPERLATYV/g;
    s/NJ/Ň/g;
    s/STATISTI/STATYSTY/g;
    s/STIK/STYK/g;
    s/STIMUL/STYMUL/g;
    s/STUDI/STUDY/g;
    s/TECHNI/TECHNY/g;
    s/TELECOM/TELEKOM/g;
    s/TELEFONI/TELEFONY/g;
    s/TETIK/TETYK/g;
    s/TEXTIL/TEXTYL/g;
    s/TIBET/TYBET/g;
    s/TIBOR/TYBOR/g;
    s/TIRANY/TYRANY/g;
    s/TITUL/TYTUL/g;
    s/TRADI/TRADY/g;
    s/UNIVER/UNYVER/g;
    s/VENTI/VENTY/g;
    s/VERTIK/VERTYK/g;
    s/AUGUSTIN/aw GUST ii N/g;
    s/^ZAU/ZA!U/g;
    s/ÄH/É/g;
    s/[ÄÆŒ]/É/g;
    y/Å/O/;
    s/[ĆÇ]/C/g;
    s/[ËÈĘ]/E/g;
    y/Ï/Y/;
    s/[ĽĹŁ]/L/g;
    y/Ñ/Ň/;
    s/Ô/UO/g;
    s/ÖH/É/g;
    y/Ö/É/;
    y/Ø/O/;
    y/Ŕ/R/;
    s/ÜH/Ý/g;
    y/Ü/Y/;
}

sub deutsch {
    s/ß/S/g;
    s/EI/AJ/g;
    s/Z/C/g;
    s/SCH/Š/g;
    s/^SP/ŠP/;
    s/^ST/ŠT/;
    s/CK/K/g;
    s/EU/OJ/g;
    s/V/F/g;
}

sub prepis {
    # Hrubý fonetický přepis (skript programu sed, používán ve spojení s init.scp)
    # 11.9.1997 Autor: Nino Peterek, peterek@ufal.ms.mff.cuni.cz

    # namapování nechtěných znaků na model ticha
    s/^.*[0-9].*$/sil/g;

    # náhrada víceznakových fonémů speciálním znakem, případně rozepsání znaku na více fonémů
    s/CH/#/g;
    s/W/V/g;
    s/Q/KV/g;
    #s/DŽ/&/g;  v původním vyslov nefungovalo
    s/DZ/@/g;
    s/X/KS/g;

    # ošetření Ě 
    s/(?<=[BFPV])Ě/JE/g;
    s/DĚ/ĎE/g;
    s/TĚ/ŤE/g;
    s/NĚ/ŇE/g;
    s/MĚ/MŇE/g;
    s/Ě/E/g;

    # změkčující i
    s/DI/ĎI/g;
    s/TI/ŤI/g;
    s/NI/ŇI/g;
    s/DÍ/ĎÍ/g;
    s/TÍ/ŤÍ/g;
    s/NÍ/ŇÍ/g;

    # asimilace znělosti
    s/B$/P/g;
    s/B(?=[PTŤKSŠCČ#F])/P/g;
    s/B(?=[BDĎGZŽ@&H]$)/P/g;
    s/P(?=[BDĎGZŽ@&H])/B/g;
    s/D$/T/g;
    s/D(?=[PTŤKSŠCČ#F])/T/g;
    s/D(?=[BDĎGZŽ@&H]$)/T/g;
    s/T(?=[BDĎGZŽ@&H])/D/g;
    s/Ď$/Ť/g;
    s/Ď(?=[PTŤKSŠCČ#F])/Ť/g;
    s/Ď(?=[BDĎGZŽ@&H]$)/Ť/g;
    s/Ť(?=[BDĎGZŽ@&H])/Ď/g;
    s/V$/F/g;
    s/V(?=[PTŤKSŠCČ#F])/F/g;
    s/V(?=[BDĎGZŽ@&H]$)/F/g;
    s/F(?=[BDĎGZŽ@&H])/V/g;
    s/G$/K/g;
    s/G(?=[PTŤKSŠCČ#F])/K/g;
    s/G(?=[BDĎGZŽ@&H]$)/K/g;
    s/K(?=[BDĎGZŽ@&H])/G/g;
    s/Z$/S/g;
    s/Z(?=[PTŤKSŠCČ#F])/S/g;
    s/Z(?=[BDĎGZŽ@&H]$)/S/g;
    s/S(?=[BDĎGZŽ@&H])/Z/g;
    s/Ž$/Š/g;
    s/Ž(?=[PTŤKSŠCČ#F])/Š/g;
    s/Ž(?=[BDĎGZŽ@&H]$)/Š/g;
    s/Š(?=[BDĎGZŽ@&H])/Ž/g;
    s/H$/#/g;
    s/H(?=[PTŤKSŠCČ#F])/#/g;
    s/H(?=[BDĎGZŽ@&H]$)/#/g;
    s/#(?=[BDĎGZŽ@&H])/H/g;
    s/\@$/C/g;
    s/\@(?=[PTŤKSŠCČ#F])/C/g;
    s/\@(?=[BDĎGZŽ@&H]$)/C/g;
    s/C(?=[BDĎGZŽ@&H])/\@/g;
    s/&$/Č/g;
    s/&(?=[PTŤKSŠCČ#F])/Č/g;
    s/&(?=[BDĎGZŽ@&H]$)/Č/g;
    s/Č(?=[BDĎGZŽ@&H])/&/g;
    s/Ř$/>/g;
    s/Ř(?=[PTŤKSŠCČ#F])/>/g;
    s/Ř(?=[BDĎGZŽ@&H]$)/>/g;
    s/(?<=[PTŤKSŠCČ#F])Ř/>/g;


    #zbytek
    s/NK/ng K/g;
    s/NG/ng G/g;
    s/MV/mg V/g;
    s/MF/mg F/g;
    s/NŤ/ŇŤ/g;
    s/NĎ/ŇĎ/g;
    s/NŇ/Ň/g;
    s/CC/C/g;
    s/DD/D/g;
    s/JJ/J/g;
    s/KK/K/g;
    s/LL/L/g;
    s/NN/N/g;
    s/MM/M/g;
    s/SS/S/g;
    s/TT/T/g;
    s/ZZ/Z/g;
    s/ČČ/Č/g;
    s/ŠŠ/Š/g;
    s/-//g;

    # závěrečný přepis na HTK abecedu
    s/>/rsz /g;
    s/EU/eu /g;
    s/AU/au /g;
    s/OU/ou /g;
    s/Á/aa /g;
    s/Č/cz /g;
    s/Ď/dj /g;
    s/É/ee /g;
    s/Í/ii /g;
    s/Ň/nj /g;
    s/Ó/oo /g;
    s/Ř/rzs /g;
    s/Š/sz /g;
    s/Ť/tj /g;
    s/Ú/uu /g;
    s/Ů/uu /g;
    s/Ý/ii /g;
    s/Ž/zs /g;
    s/Y/i /g;
    s/&/dzs /g;
    s/\@/ts /g;
    s/#/ch /g;
    s/!//g;
    s/([A-Z])/$1 /g;
#    s/$/ sp/g;
}

sub prague2pilsen {
    s/au/aw/g;
    s/ch/x/g;
    s/cz/ch/g;
    s/dzs/dzh/g;
    s/es/e s/g;
    s/eu/ew/g;
    s/ou/ow/g;
    s/rsz/rsh/g;
    s/rzs/rzh/g;
    s/sz/sh/g;
    s/ts/dz/g;
    s/zs/zh/g;
}

sub infreq {
    while (my ($from, $to) = each %phone_map) {
        s/\b$from\b/$to/g;
    }
    return;

    #s/dz/c/g;
    #s/dzh/ch/g;
    #s/ew/e u/g;
    #s/aw/a u/g;
    #s/mg/m/g;
    #s/oo/o/g;
}

sub add_sp {
    s/ *$/ sp/;
}

sub print_variants {
    my ($writ) = @_;
    if (/^o /) {
        print encode($enc, "$writ       v $_\n");
    }
    # TODO vosumnást (cf. Vyslov.pm)
}

__END__

=head1 NAME

vyslov (Czech for pronounce)

=head1 SYNOPSIS

 $ vyslov.pl [inputFile inputFile2 ...] outputFile

=head1 DESCRIPTION

converts Czech text in CAPITALS in iso-latin-2 to Czech phonetic alphabet in
iso-latin-2. All input files will be concatenated into the output file. If no
input files are specified, reads from STDIN.

If you want the script to operate in another encoding, set the EV_encoding
environment variable to the desired encoding. If you want to use
the Prague-style transliteration (sz instead of sh), just comment out the call
to prague2pilsen function.

This is a rewrite of vyslov shell-script by Nino Peterek, which was using tools
written by Pavel Ircing. These are copy-pasted including comments into this
script.

=head1 AUTHOR

Jan Oldrich Kruza E<lt>sixtease@cpan.orgE<gt>

http://www.sixtease.net/

=head1 COPYRIGHT

Public domain
