#!usr/bin/perl -w
use strict;

my @unordered = qw (een twee drie vier vijf zes);

sub operation{
  my @res = ( );
  for (my $i = 0; $i<@_;$i++){
    $res[$i] = reverse $_[$i];
  }
  return @res;
}

my @precomputed = map{[operation($_),$_]} @unordered; # creatie van arrayreferenties op de plaatsen van @unordered, elke arrayref wijst naar een array met 2 elementen, het element na operation en het originele

print "$precomputed[0][0]"," is reverse of ","$precomputed[0][1]\n";

# my $test = [58,"hello"];
# print "\n@$test";
#
# print "\n$$test[0] & $$test[1]";

my @ordered_precomputed = sort {$a->[0] cmp $b->[0]} @precomputed;

foreach(@ordered_precomputed){
  print "$_->[0] & $_->[1]\n";
}

my @ordered = map {$_->[1]} @ordered_precomputed; # het resultaat hiervan is een array met echte elementen, geen referenties
print "@ordered\n\n";

# UITLEG
# de strategie hier is dat je een lijst hebt die je wil sorteren,
# je wil echter pas de lijst sorteren nadat je een operatie hebt gedaan op de elementen van de lijst
# je kan dit in meerdere stappen doen en voor elke tussenstap een variabele creëren
# je slaat in stap 1 voor elke element zowel het origineel op als het resultaat van operation(origineel)
# dit doe je door anonieme arrays te creëren als elementen
# na het sorteren maak je een laatste array waarbij je de originele elementen uit de anonieme arrays haalt, die staan nu in de juiste volgorde
# concreet: hier werden de inversen van enkele woorden genomen, die werden gesorteerd en de finale lijst zijn de originele woorden in de gesorteerde volgorde van hun inversen

# verkorte notatie map-sort-map


my @ordered_short = map {$_->[1]}
                    sort {$a->[0] cmp $b->[0]}
                    map {[operation($_),$_]}
                    @unordered;

for(@ordered_short){
  print "$_ ";
}
print "\n";

#
# print map  { $_->[0] }             # whole line
#       sort {
#               $a->[1] <=> $b->[1]  # gid
#                       ||
#               $a->[2] <=> $b->[2]  # uid
#                       ||
#               $a->[3] cmp $b->[3]  # login
#       }
#       map  { [ $_, (split /:/)[3,2,0] ] }
#       `cat /etc/passwd`; # qx{} perlop quote, interpolate (if necessary) and execute
#       # opm dit zal niet werken op windows (verkeerd pad), wel op linux-distr


my @split_pwd = map { [ $_,(split /:/)[3,2,0]] } `cat /etc/passwd`;

# UITLEG
# (split /:/) werkt in op $_ want we gaven geen EXPR mee
# split doet return in list context, en van die list nemen we een slice met name elementen op plaatsen 0, 2 en 3 echter niet in die volgorde, maar als 3, 2, 0
# door een list toe te voegen in een array treedt automatisch expansion op van die list, dus de anonieme arrays van @split_pwd bevatten elk 4 items
# er wordt een sort uitgevoerd op deze geëxtracte delen en finaal worden de originele lijnen teruggegeven gesorteerd zoals we wouden zonder opgeslagen intermediaire datastructuren

for my $i (0..3){
  print "full line $split_pwd[$i]->[0]";
  print "$split_pwd[$i]->[1]\n";
  print "$split_pwd[$i]->[2]\n";
  print "$split_pwd[$i]->[3]\n";
  print "$split_pwd[$i]->[4]\n";
}
