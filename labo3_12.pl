#!usr/bin/perl -w
use strict;

my $aantal=1/2;
my @aantal;
my %prefix;
for my $prefix (reverse 0..32) {             # prefixlengte <-> aantal adressen
  $aantal*=2;
  $aantal[$prefix]=$aantal; # tabel die voor elke prefix het aantal mogelijke adressen bijhoudt
  $prefix{$aantal}=$prefix; # hash die voor een 'aantal' adressen bijhoudt wat de prefixlengte is, omgekeerde van bovenstaande en in een hash
}
# opm over de for loop, het is in Perl mogelijk om te zeggen for $iteratievar (LIST) 0..32 produceert een lijst van 0 t/m 32 adhv range operator '..'

# {
#   my $i = 0;
# foreach (@aantal){
#   print "prefix: $i \t max # addr. $_.\n";
#   $i++;
# }
# # opm closure oftwel naked block om lexical variables (e.g. my ...) te scopen tot enkel dat block
# }

my $error=0;
my @V;

for my $net (@ARGV) {
  my @ip=split /[.\/]/,$net;                    # 4 bytes netwerkadres + 1 byte prefixlenge
  splice @ip,(@ip-1),0,(0)x(5-@ip) if @ip<5; # eventueel aanvullen met 0 bytes
 print "\@ip = @ip\n";
  #UITLEG
#splice ARRAY,OFFSET,LENGTH,LIST
#Removes the elements designated by OFFSET and LENGTH from an array, and replaces them with the elements of LIST, if any.
  # dus splice ARRAY = @ip, OFFSET = (@ip-1), LENGTH = 0, LIST = (0)x(5-@ip) extra nullen enkel as @ip<5 (dus bv 3 bytes netwerkadres & 1 byte prefixlengte)
  # 200.25/16 -> OFFSET = 2, LENGTH = 0, LIST = (0)x(2) -> @ip = [200,25,0,0,16]
  my $start = 0;
  $start=$start*256+$ip[$_] for 0..3;        # compacte representatie netwerkadres
  print "start = $start\n";

#1ste iteratie => 0*256 + ip[0] = 200, 2de iteratie => 200*256 + 25 = 51225, 3de iteratie => 51225*256 + 0 = 51225*256, 4de iteratie (51225*256)*256 + 0

print '$start % $aantal[$ip[4]] = ';
my $tmp = $start % $aantal[$ip[4]];
print "$tmp\n";

  if ($start%$aantal[$ip[4]]) {              # berekening minimale prefixlengte in $start zit volledige numerieke waarde van het netwerkadres en dat wordt vergeleken (modulo) met de waarde die in de array aantal zit bv aantal[20]=4096
    $ip[4]++ while $start%$aantal[$ip[4]];   # opm voor het netwerk van de ISP dat eerder werd gebruikt: 200.25.0.0/16 geldt dat $aantal = 3357081600 en dat is deelbaar zonder rest door 2^16 (65536), dus deze lus gaat niet door voor het netwerk van de ISP in dit geval
    print "$net vereist minimaal /$ip[4]\n";
    $error++;
  }

  @V=([$start,$aantal[$ip[4]]]) unless @V;    # initialiseren verzameling supernets

  printf "\@V = %s\n",join(", ",@{$V[0]});

  #UITLEG
  # voeg aan het array V een referentie naar een array toe als V nog leeg is: unless @v === if(!@V)
  # dat array bevat $start en $aantal[$ip[4]] (het max aantal adressen voor het subnetw bij gegeven prefixlengte)
  # dit zal enkel uitgevoerd worden voor het eerste argument om de command line (hier het supernet van de ISP), want elke referentie behalve undef wordt gezien als true
}

{
  my $i = 0;  
  foreach(@V){
    printf "\n\@V[$i] = %s (start)\n",join(" aantal =  ",@{$V[$i]});
    $i++;
  }
}

exit(0) if $error;


shift @ARGV; # adres supernet ISP verwijderen vh array
while (@ARGV) {                              # verwerken subnets
  my $sub=$ARGV[0];
  my @ip=split /[.\/]/,$sub;
  splice @ip,(@ip-1),0,(0)x(5-@ip) if @ip<5;
  my $start=0;
  $start=$start*256+$ip[$_] for 0..3; # zelfde code als hoger

  my $ind=-1;
  my $found=0;
  for my $super (@V) {                          # welk supernet bevat subnet ?
    $ind++;
    if ($start>=$super->[0] && $start<$super->[0]+$super->[1]) {
      # is start die hoger berekend werd minstens groter of gelijk aan de start van supernet 1 en is het maximaal kleiner dan supernet 1 + grootte van dat supernet
      # merk op dat geteld wordt met de vereenvoudigde notatie (zie berekening start) ipv met de 4 byte blokken
      $found=1;
      if($aantal[$ip[4]]==$super->[1]) {     # supernet verwijderen indien = subnet (op $super->[1] vindt men aantal[prefixlengte van supernet]) conditie is eigenlijk prefix subnet =? prefix supernet
	splice @V,$ind,1;
	shift @ARGV;                         # volgend subnet behandelen
      }
      elsif($aantal[$ip[4]]<$super->[1]) {   # supernet opsplitsen  indien > subnet; dit zal de meer voorkomende situatie zijn, de klant heeft een kleinere netwerkprefix dan de ISP
	my $helft=$super->[1]/2;
	splice @V,$ind,1,([$super->[0],$helft],[$super->[0]+$helft,$helft]);
  # UITLEG
  # voeg aan array @V vanaf $ind voor 1 plaats (maw element op $ind zelf) een een lijst van 2 anonieme arrays toe
  # [$super->[0],$helft] = originele supernetadres, maar de prefix is gedeeld door 2
  # [$super->[0]+$helft,$helft] = originele supernetadres
      }
      {
        my $i = 0;
        foreach(@V){
          printf "\n\@V[$i] = %s (start)\n",join("aantal =  ",@{$V[$i]});
          $i++;
        }
      }

      last;                                  # geen overlappende supernetten mogelijk
    }

  } # last will make the code pick up again here, 5 perl loops: while, until, for, foreach & naked block, if doesn't qualify as loop, last is zoals break, echt einde van de hele lus
  shift @ARGV unless $found;                 # subnet negeren indien supernet gevonden (!!!)

}

# (!!!) deze lijn zorgt eigenlijk voor een groot deel van de logica
# de meeste subnetten zullen de volgende stappen ondergaan
# 1. wordt ingelezen
# 2. zit subnet in supernet?
# 3. zijn supernet en subnet even groot? normaalgezien zelden want ze zouden daarvoor dezelfde prefix moeten hebben
# 4. is subnet kleiner dan supernet? -> halveer supernet
# 5. als subnet niet gevonden werd (maw het zat niet in de range van het supernet) skip en ga naar volgende subnet
# 6. meestal zal het subnet echter gevonden zijn in de range van het supernet en zal er opnieuw door de while lus gelopen worden
   # in vele gevallen zal stap 3 weer false zijn maar 4 true zodat er verder gesplitst wordt, dat splitsen gaat door tot aantal adr van subnet gelijk is aan het aantal adressen van het fragment van het supernet


for my $v (@V) {
  my @ip=();                                    # 4 bytes netwerkadres + 1 byte prefixlenge
  for my $b (reverse 0..3) {                  # herassemblage naar de 4 byte vorm met prefixlengte
    $ip[$b]=$v->[0]%256;
    $v->[0]-=$ip[$b];
    $v->[0]/=256;
  }
  pop @ip while (@ip>1 && !$ip[-1]);         # trailing 0's verwijderen !$ip[-1] betekent als laatste element van array ip false is (enkel 0 is false)
  print join (".",@ip),"/$prefix{$v->[1]}\n";
}
