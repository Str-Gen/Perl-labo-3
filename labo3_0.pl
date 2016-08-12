use strict;
use warnings;
use v5.010;

#DATA
my %gewest=( "Antwerpen"      => "Vlaanderen", "Henegouwen"   => "Wallonie",
          "Limburg"        => "Vlaanderen", "Namen"        => "Wallonie",
          "Oost-Vlaanderen"=> "Vlaanderen", "Luik"         => "Wallonie",
          "Vlaams-Brabant" => "Vlaanderen", "Luxemburg"    => "Wallonie",
          "West-Vlaanderen"=> "Vlaanderen", "Waals-Brabant"=> "Wallonie");

my %provincie=( "Aalst"       => "Oost-Vlaanderen", "Brugge"  => "West-Vlaanderen",
             "Dendermonde" => "Oost-Vlaanderen", "Ieper"   => "West-Vlaanderen",
             "Eeklo"       => "Oost-Vlaanderen", "Oostende"=> "West-Vlaanderen",
             "Oudenaarde"  => "Oost-Vlaanderen", "Kortrijk"=> "West-Vlaanderen",
             "Sint-Niklaas"=> "Oost-Vlaanderen", "Gent"    => "Oost-Vlaanderen",
             "Halle"       => "Vlaams-Brabant" , "Genk"    => "Limburg"        ,
             "Leuven"      => "Vlaams-Brabant" , "Hasselt" => "Limburg"        ,
             "Vilvoorde"   => "Vlaams-Brabant" , "Tongeren"=> "Limburg"        );

# hash inversion

# 1 zonder de duplicaten bij te houden

my %gewest_rev_dumb = reverse %gewest;

sub hashprint{
my (%hash) = @_;
while((my $k,my $v) = each %hash){
  print "key: $k => $v\n";
  }
}
say "print originele hash en nadien de geïnverteerde hash zonder rekening te houden met duplicaten";
&hashprint(%gewest);
print "*"x50,"\n";
&hashprint(%gewest_rev_dumb);

print "*"x50;
print "\n"x4;

say "print originele hash en nadien de geïnverteerde hash nu wel rekening houdende met duplicaten";
&hashprint(%gewest);

my %gewest_rev_smart;
{
while((my $k, my $v) = each(%gewest)){
  push @{$gewest_rev_smart{$v}} , $k;
  # uitleg:
  # push verwacht als eerste param een echt array
  # $gewest_rev_smart{$v} $v is de key, en aan de valueset wordt nu een element toegevoegd
  # de eerste keer dat dit doorgaat treedt autovivifaction op, er wordt een array klaargezet
  # dat array heeft geen naam maar is er wel, daarom is @{$gewest_rev_smart{$v}} een echt array
  # en $gewest_rev_smart{$v} een referentie naar een array
  # bij dat array push je $k
  }
}

print "*"x50,"\n";
{
foreach my $k (keys %gewest_rev_smart){
print "key: $k =>";
  print "@{$gewest_rev_smart{$k}}\n";
}
}
