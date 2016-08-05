#!/usr/bin/perl -w
use strict; 

print "The whole ARGV: @ARGV\n";

my $filename = shift @ARGV;

print "The whole ARGV with the first element shifted off: @ARGV\n";

open my $filename_fh, '<', "$filename"
  or die "Could not open $filename $!";
  my %hash;
  while(<$filename_fh>){ # the diamond operator reads the input
    chomp; # the actual content of what <> read is in $_
    ( my $regio, my $ouder, my $population,my $area ) = split /;/;
    $hash{$regio} = { regio      => $regio,                # UITLEG:
                      ouder      => $hash{$ouder},         # Hier wordt een datastructuur gemaakt die er als volgt uitziet
                      kinderen   => [],                    # hash (die alles omvat) met de regionamen als keys
                      number     => 0,                     # bij elke regionaam hoort een 'more elaborate record' vgl met een struct uit C
                      niveau     => 0,                     # elk van die records heeft volgende velden: de regionaam, een referentie naar het record van de ouder!!
                      population => $population,           # een referentie naar een anonieme array voor de kinderen, een nummer en een niveau beiden voorlopig 0
                      area       => $area };               # een populatie die we ook uit een lijn vh csv bestand haalden en een area

  # het meest opmerkelijke is dat alles regio's in deze hash zitten, dus ouders en kinderen zitten allemaal samen in %hash en elke regio kent ook alles van zijn ouder en dus indirect ook alles vd ouder van hun ouder
  # LET OP: de creatie van de value gebeurt niet met () maar met {} dwz dat de value die je zal krijgen via $hash{$regio} een referentie is naar een anonieme hash. Die anonieme hash bevat het complexe record, een record dat zelf ook nog referenties heeft
 push @{ $hash{$ouder}->{kinderen} }, $hash{$regio};
 # push ARRAY , LIST
 # LINKERDEEL
 # perlreftut use rule 1: you can use @{$aref} instead of @array anywhere, dus wat tussen @{   } staat moet een referentie naar een array zijn
 # $hash{$ouder}->{kinderen}
 # deel 1: $hash{$ouder}: %hash is een echte hash (geen referentie naar een hash) dus element access is inderdaad $hash{$key}
 # deel 2: de key $ouder leidt naar een referentie van het complexe record de volledige schrijfwijze zonder gebruik te maken van Use Rule 2 (het pijltje) zou ${$hash{$ouder}}{kinderen} zijn
 # het pijltje is een vereenvoudiging en de key kinderen van de anonieme hash (het complexe record) leidt naar een referentie voor een anonieme array
 # zo is de cirkel rond, wat tussen @{} staat is wel degelijk een referentie naar een array
 # RECHTERDEEL
 # naar het anonieme array achter het veld kinderen van de ouder wordt een referentie gepusht naar het complexe record van het kinderen

  my $refouder = $hash{$regio}->{ouder};
  # tijdelijke variabele referentie naar het complexe record van de ouder

  $hash{$regio}{niveau}=$refouder->{niveau}+1;
  # LINKERDEEL
  # arrow rule: in between two subscripts the -> may be omitted
  # $hash{$regio}{niveau} is equivalent met $hash{$regio}->{niveau}
  # RECHTERDEEL
  # $refouder is een referentie naar het complexe record van de ouder, mbv de -> wordt het niveau opgevraagd en er wordt 1 bij opgeteld
  # de telling van de niveau's zal oplopend zijn, hoewel de grootte van de regio steeds zal afnemen


  next unless $population;
  # zelfde als next if (! $population), uitvoering als de conditie false is
  # if $population = false execute next, false kan enkel als $population = 0 zie perl boolean values
  # next zal er voor zorgen dat de rest van deze iteratie van de while loop niet uitgevoerd zal worden
  # nadien start gwn een nieuwe iteratie vd lus

  while ($refouder) {
       $refouder->{number}     += 1;              # UITLEG
       $refouder->{population} += $population;    # zolang $refouder een echte referentie is gaat deze lus door, als $refouder undef is dan gaat de lus niet door, vgl met while(pointer) in C++
       $refouder->{area}       += $area;          # de ouderregio krijgt een hogere number (+1), de populatie en opp vd kindregio worden bij de ouderregio geteld
       $refouder = $refouder->{ouder};            # de referentie wordt bijgesteld en wordt de ouder van de ouder. Zo krijgen alle hogere niveaus steeds de correcte data, dit gaat door tot er geen ouder meer is.
   } # OPM: als je dit met warnings laat lopen zal je veel output krijgen in deze vorm:
   # Argument "" isn't numeric in addition (+) at labo3_10.pl line 59, <$filename_fh> line 57.
 }# dat is omdat de ouderknoop nog niet noodzakelijk aan bod is gekomen waardoor er nog geen waarde toegekend is aan een bepaalde eigenschap, zet warnings uit als je dit niet wil zien

my $refknoop = $hash{Belgie}; # initialisatie voor controle 1 === referentie naar de knoop van het hoogste number
my @refqueue = ($refknoop);   # initialisatie voor controle 2
%hash = ();                # hash niet meer nodig !

# controle 1: hierarchielijn vanaf Belgie, met telkens kind met grootste population

while ($refknoop) {
    print "knoop:      ", $refknoop->{regio}, "\n";
    print "kinderen:   ", join( " ", map { $_->{regio} }
                                     sort { $a->{regio} cmp $b->{regio} }
                                     @{ $refknoop->{kinderen} } ), "\n";
  # UITLEG
  # join EXPR,LIST === Joins the separate strings of LIST into a single string with fields separated by the value of EXPR, and returns that new string
  # dus hier EXPR = " "
  #
  # In dit deel begin je best van achter naar voor opdat het logisch zo zijn
  # map BLOCK LIST ===
#Evaluates the BLOCK for each element of LIST (locally setting $_ to each element) and returns the list value composed of the results of each such evaluation.
#In scalar context, returns the total number of elements so generated.
#Evaluates BLOCK in list context, so each element of LIST may produce zero, one, or more elements in the returned value.
  # maw de regionaam wordt uit het record gehaald
  #

  # sort BLOCK LIST ===
#sortering volgens code in block, inline sorteermethode van de LIST
  # In dit geval worden de namen van de regio's asciibetically gesorteerd

  # LIST = @{ $refknoop->{kinderen} } dit is een list van referenties van kinderen @{referentie naar array} let op lijnen 26 & 36 voor de code en de uitleg, de elementen van de array zijn dus referenties

  # het totaal van gesorteerde regionamen wordt als 1 string aan elkaar geplakt met spaties en geprint

    print "#gemeenten: ", $refknoop->{number},     "\n";
    print "population: ", $refknoop->{population}, "\n";
    print "area:       ", $refknoop->{area},       "\n";
    print "\n";
    ($refknoop) = sort { $b->{population} <=> $a->{population} } @{ $refknoop->{kinderen} };
  # let op de forced list context, sort wordt immers toegepast op een list en geeft ook een list terug, in dit geval wordt er
  # let ook op $b <=> $a descending sort maw grootste waarde eerst
}

# controle 2: volledige hierarchie vanaf Belgie

print "\n@refqueue\n";
while ($refknoop=shift @refqueue) {
    printf "%-41s %8d %6d\n",(("    "x($refknoop->{niveau}-1)).$refknoop->{regio}),$refknoop->{population},$refknoop->{area};
    unshift @refqueue,sort { $b->{population} <=> $a->{population} } @{ $refknoop->{kinderen} };
}
# %-41s is 41 char wijd left justified, de rest is 8 char rechts justified en 6 char rechts justified
#("    "x($refknoop->{niveau}-1)) is print whitespace maal niveau -1 zodat de kinderen met meer indentation gelist zullen worden (zie eerder niveau is hoger voor kind dan voor ouder)
# dan stringconcat via . operator op $refknoop->{regio}, dat alles tussen haakjes want dat was enkel het deel voor %s

 # UITLEG
 # unshift ARRAY,LIST
#This is the opposite operation of shift. unshift will take one or more values (or even 0 if that's what you like)
#and place it at the beginning of the array moving all the other elements to the right.

#aan de array @refqueue wordt een lijst toegevoegd van referenties naar kinderen, die referenties werden gesorteerd opdat het kind met het hoogste aantal inwoners eerst in de queue staat
