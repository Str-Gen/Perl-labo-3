#!usr/bin/perl -w
use strict;

my @OARG = @ARGV;
undef $/;
$_ = <>;

my ($width,$height) = /^<svg width="(\d+)" height="(\d+)"/ms;

my ($cols,$rows) = /<title>(\d+) by (\d+) orthogonal maze<\/title>/ms; #vergeet de / van /title niet te escapen, anders zou de regexp eindigen voor die /

s/.*stroke-linejoin="round">$//ms;

my ($minX,$minY) = m{<line x1="(\d+)" y1="(\d+)"}ms;
#print 'minX = ',$minX,' minY = ',$minY,"\n";

my %vert_segm = ( );
my %horiz_segm = ( );

sub HoHprint { #opm je moet een hash reference meegeven als arg
	my %hash = %{$_[0]};
	foreach my $k1 (sort keys %hash){
		print "$k1 => \n";
		foreach my $k2 (sort keys %{$hash{$k1}}){
			print "\t$k2 => $hash{$k1}{$k2};\n";
		}
	}
}

sub HoAprint {
	my %hash = %{$_[0]};
	foreach my $key (sort{$a <=> $b} keys %hash){
		print "$key => @{$hash{$key}}\n";
	}
}

my $maxX = 0;
my $maxY = 0;
my $marginX = 0;
my $marginY = 0;

my $f = $_;
while ($f =~ m{<line x1="(\d+)" y1="(\d+)" x2="(\d+)" y2="(\d+)"/>}gms){ # SVG oorsprong linksboven x-as + naar R y-as + naar beneden
# alle lijnen zijn ofwel horizontaal ofwel verticaal
$minX = $1 if $1<$minX;
$minY = $2 if $2<$minY;
$maxX = $3 if $3>$maxX;
$maxY = $4 if $4>$maxY;
#print "minX = $1, minY = $2, maxX = $3, maxY = $4\n";

if($1 == $3){ # verticale lijn
$vert_segm{$1}->{$2} = $4; # $vert_segm{$1} = {$2 => $4} is FOUT, als de key al bestaat ($1) dan wordt een nieuwe anonieme hash gemaakt die de oude overschrijft
}                            # ook hier is autovivication weer van belang, met deze syntax zal voor elke nieuwe $1 die gezien wordt een nieuw paar in de hash komen



elsif($2 == $4){ #horizontale lijn
	$horiz_segm{$2}->{$1} = $3;
}
}
$marginX = ($width-($maxX-$minX))/2;
$marginY = ($height-($maxY-$minY))/2;
print "marginX = $marginX en marginY = $marginY\n";

print "Verticale segmenten, 1ste kolom is de vaste X waarde\n";
HoHprint(\%vert_segm);

print "Horizontale segmenten, 1ste kolom is de vaste Y waarde\n";
HoHprint(\%horiz_segm);

# { DIT WERKT WEL MAAR DE KEYS ZIJN NIET GESORTEERD
#   print "verticale segmenten:\n";
#   while(my ($k,$v) = each %vert_segm){
#     print "$k => ";
#     while(my ($k2 ,$v2) = each %{$v}){
#       print "\t$k2 => $v2\n";
#     }
#     print "\n";
#   }
# }

my $cellwidth = ($width-2*$marginX)/$cols;
print "cellwidth = $cellwidth\n";

my %blocks = ( );

while($f =~ m{<text x="(\d+)" y="(\d+)" (?:text-anchor="middle" style="font-family:Arial Narrow; font-size: xx-small;")?>(\d+)</text>}gms){
	$blocks{$3} = [$1-$1 % ($cellwidth/2),$2-$2 % ($cellwidth/2)];
}
print "blokken met centrum (X,Y)\n";
HoAprint(\%blocks);


my @muren_per_blok = ();
for my $i (1..keys %blocks){
  my @muren = (0,0,0,0); # volgorde = Links, Rechts, Boven, Onder
  # print "going to do block{$i}\n";


  for (keys %{$vert_segm{$blocks{$i}->[0]-$cellwidth/2}}){
  	#print "checking left for cell ",$i,"\n";
  	my $rangeStart = $_;
    #print "$rangeStart ";
    my $rangeEnd = $vert_segm{$blocks{$i}->[0]-$cellwidth/2}->{$_};
    #print "$rangeEnd\n";
    
    if($blocks{$i}->[1]>= $rangeStart && $blocks{$i}->[1] <= $rangeEnd){
      $muren[0] = 1; # maw ja er is een muur hier            
  }
  else {
  	$muren[0] = 0 if $muren[0]!=1;
      #ZEER BELANGRIJK: als je die test niet schrijft krijg je in 50% van de gevallen rommel
      # uitleg: Perl houdt hashes niet gesorteerd bij, als je je programma laat lopen kan wat vorige keer key 0 was nu key 1 zijn
      # de bug treedt op als eerst een correcte range wordt getest (en dus een muur wordt gezet)
      # maar nadien de andere range test en faalt, waarna je muur wordt overschreven omdat de test eerste if faalde
      # ik heb ook geprobeerd de lus af te breken als er een muur gezet is met next, maar de resultaten waren niet consistent
      # deze oplossing werkt
  }
}

for (keys %{$vert_segm{$blocks{$i}->[0]+$cellwidth/2}}){
	my $rangeStart = $_;
    #print "$rangeStart ";
    my $rangeEnd = $vert_segm{$blocks{$i}->[0]+$cellwidth/2}->{$_};
    #print "$rangeEnd\n";

    
    if($blocks{$i}->[1] >= $rangeStart && $blocks{$i}->[1] <= $rangeEnd){
    	$muren[1] = 1;         
    }
    else{
    	$muren[1] = 0 if $muren[1] != 1;
    }
}

for (keys %{$horiz_segm{$blocks{$i}->[1]-$cellwidth/2}}){
	my $rangeStart = $_;
    #print "$rangeStart ";
    my $rangeEnd = $horiz_segm{$blocks{$i}->[1]-$cellwidth/2}->{$_};
    #print "$rangeEnd\n";

    if($blocks{$i}->[0] >= $rangeStart && $blocks{$i}->[0] <= $rangeEnd){
    	$muren[2] = 1;
    }
    else{
    	$muren[2] = 0 if $muren[2] != 1;
    }
}

for (keys %{$horiz_segm{$blocks{$i}->[1]+$cellwidth/2}}){
	my $rangeStart = $_;
    #print "$rangeStart ";
    my $rangeEnd = $horiz_segm{$blocks{$i}->[1]+$cellwidth/2}->{$_};
    #print "$rangeEnd\n";

    if($blocks{$i}->[0] >= $rangeStart && $blocks{$i}->[0] <= $rangeEnd){
    	$muren[3] = 1;
    }
    else {
    	$muren[3] = 0 if $muren[3] != 1;
    }
}

push @muren_per_blok, [@muren];


  #print "going to next block\n\n";

} # einde van de for (1..keys %blocks)

sub AoAprint {
	my @array = @{$_[0]};
	print "muren 1 = ja, 0 = nee volgorde L R B O\n";
	for my $i (0..$#array){
		print "cell ",$i+1,"\t","@{$array[$i]}\n";
	}
}

AoAprint(\@muren_per_blok);

# reminder: in @muren per block zit de data over de muren van cell 1 in plaats 0 vh array etc.

# voor buren ga ik een array van arrays gebruiken

my @bereikbare_buren = ();
for (0..$#muren_per_blok){
	$bereikbare_buren[$_] = [ ];
}

for(my $index = 0; $index< scalar @muren_per_blok; $index++){

# if(defined($muren_per_blok[$index -1]) && (($index-1)%5 != 0)){
# 	if($muren_per_blok[$index -1][0] == 0){ # linkerbuur checken 

# 	}
if($muren_per_blok[$index][0] == 0){
	push @{$bereikbare_buren[$index]}, $index; 
	#linkerbuur, omdat $index altijd 1tje achterloopt op het celnummer, kan je als er een match is gwn index gebruiken, index is het celnummer van de linkercel
}

if($muren_per_blok[$index][1] == 0){
	push @{$bereikbare_buren[$index]}, $index+2;
	#rechterbuur, omdat $index altijd 1tje achterloopt op het celnummer, moet je 2 bijtellen om 1 voorbij het huidige celnummer te eindigen, dat is dan het celnummer van de rechterbuur
}

if($muren_per_blok[$index][2] == 0){
	push @{$bereikbare_buren[$index]}, $index-($cols-1); 
}

if($muren_per_blok[$index][3] == 0){
	push @{$bereikbare_buren[$index]}, $index+($cols+1);
}
}

{
	for my $i (0..$#bereikbare_buren){
		print $i+1,"\t";
		foreach(@{$bereikbare_buren[$i]}){
			print "$_\t";
		}
		print "\n";
	}
}



# start en eindcel zoeken, doolhoven met meer dan 1 in- of uitgang zullen niet werken met onderstaande code
my $startcel_index = 0;
my $eindcel_index = 0;

for(my $index = 0; $index<scalar @bereikbare_buren; $index++){

	foreach(@{$bereikbare_buren[$index]}){
		if($_ <= 0 && !$startcel_index){
			$startcel_index = $index+1;
		}
		if($_ <= 0 && $startcel_index && !$eindcel_index){
			$eindcel_index = $index+1 if $startcel_index != $index+1;
		}
	}
}

print "mijn startcel heeft nummer: ",$startcel_index,".\n";
print "mijn eindcel heeft nummer: ",$eindcel_index,".\n";







