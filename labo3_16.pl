#!usr/bin/perl -w
use strict;

my @OARG = @ARGV; # kopie van de command line args
undef $/;        # slurp mode, lees alles tot EOF marker
$_ = <>;         # diamond operator leest het hele bestand in en plaatst de inhoud in $_
s/.* w$//ms;     # hier staat eigenlijk $_ =~ /.* w$//ms
# '.' matcht elk karakter ook \n, bestand wordt gezien als 1 string maar met multiline detectie, lijn moet eindigen op w in s11 is dat bv alles t/m einde lijn 50
# alles tot aan die lijn wordt vervangen door niets
s/^endstream.*//ms; # alles wat na een lijn komt met endstream als start van de lijn wordt ook gediscard

# rechte of gekromde lijnen ?
                            # indien gekromde lijnen: enkel �nteresse in eindpunten van segmenten
my $curly = (s/^\d+(?:\.\d*)? \d+(?:\.\d*)? \d+(?:\.\d*)? \d+(?:\.\d*)? (\d+(?:\.\d*)? \d+(?:\.\d*)?) c$/$1 l/gsm ? 1 : 0 );
# start met ten minste 1 digit character aan het begin van de lijn
# dan 1 of 0 keer \.\d* in een non-capture group (?:) escaping van . met \
# dan een spatie !
# dan ten minste 1 digit
# dan 1 of 0 keer \.\d* in een non-capture group (?:)
# dan een spatie
# enz in totaal 6 keer
# lijn MOET eindigen met c
# replacement is capture group 1 spatie l
# global replacement

# print 'curly = ',$curly;
#
# print ;

my $f = $_; # $f bevat de nieuwe versie, $_ blijft intact
my %X;
my %Y;

while ( $f =~ /^(\d+)(?:\.\d*)? (\d+)(?:\.\d*)? m.(\d+)(?:\.\d*)? (\d+)(?:\.\d*)? l$/sgm )
{                            # bepaling verschillende X- en Y-waarden van eindpunten van segmenten
    $X{$1} = undef;          # er is enkel capturing van de \d+ delen, de \.\d* is niet alleen optioneel, maar wordt ook niet gecaptured
    $X{$3} = undef;          # lijn moet starten met \d+ en moet eindigen op l
    $Y{$2} = undef;          # let ook op de m. in het midden de m zal voorkomen als je kijkt naar s11 of c11 en de . mag \n matchen dankzij /s modifier op regex
    $Y{$4} = undef;          # creatie van de hashes %X en %Y, coördinaten steeds X,Y paren; keys zijn de coördinaten voorlopig nog undef values
}

my $z=-1;                       # mappen verschillende X-waarden op kolomnummers
my $dz=1-$curly;                # $curly = 1 voor gekromde lijnen, 0 voor rechte lijnen
                           # ===> $dz = 0 voor gekromde lijnen en $dz = 1 voor rechte lijnen
my $maxX = 0;

for (sort {$a <=> $b} keys %X) { # ascending key sort van hash X, maw ascending sort op Xco
  $dz=1-$dz*$curly;          # individueel indien rechte lijnen, in groepjes van twee indien gekromde lijnen
  $z+=$dz;
  $X{$_}=$z;
  $maxX =$z;                 # grootste kolomnummer
}
# }
# print 'maxX = ',"$maxX\n";
# foreach (sort {$a <=> $b} keys %X){
#   print "$_ => $X{$_}\n";
# }

# UITLEG
# om het RAW format pdf beter te verstaan is het aan te raden om pg 111 - 112 en de nodige tabellen waarnaar daar verwezen wordt te raadplegen in:
# http://wwwimages.adobe.com/www.adobe.com/content/dam/Adobe/en/devnet/pdf/pdfs/PDF32000_2008.pdf
#
# verder moet opgemerkt worden dat bij het doorlopen van het bestand het mogelijk is dat een bepaalde geëxtracte waarde opnieuw voorkomt
# dan wordt geen nieuwe key gemaakt in de hash want het element is niet uniek, daarom zijn er veel minder keys in de hash dan men misschien zou verwachten
# de kolomnummers worden toegevoegd, in een tekening met rechte lijnen zal elke key een nieuwe kolom zijn
# in een tekening met kromme lijnen gaan 2 waarden aan dezelfde kolom toegewezen worden. Het kan handig zijn om zelf wat iteraties van de lus te doen je zal merken
# bestanden met rechte lijnen $dz = 1 (voor lus) en de sequentie gegenereerd in de lus is 1,1,1,1,... => z += 1 elke iteraties
# bestanden met kromme lijnen $dz = 0 (voor lus) maar de seq gegenereerd in de lus is 1,0,1,0,1 => z += 1 om de twee iteraties

$z=-1;                       # mappen verschillende Y-waarden op rijnummers
$dz=1-$curly;                # worden gereset naar de startwaarden van voor de lus van X mapping

my $maxY = 0;

for (sort {$a <=> $b} keys %Y) {
  $dz=1-$dz*$curly;          # individueel indien rechte lijnen, in groepjes van twee indien gekromde lijnen
  $z+=$dz;
  $Y{$_}=$z;
  $maxY =$z;                 # grootste rijnummer
}



print 'maxX = ',"$maxX\n";
print 'maxY = ',"$maxY\n";
print '%X',"\n";

foreach (sort {$a <=> $b} keys %X){
  print "$_ => $X{$_}\n";
}
print '%Y',"\n";
foreach (sort {$a <=> $b} keys %Y){
  print "$_ => $Y{$_}\n";
}
