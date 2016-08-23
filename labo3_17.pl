#!usr/bin/perl -w
use strict;

my @OARG = @ARGV;
undef $/;
$_ = <>;

my ($width,$height) = /^<svg width="(\d+)" height="(\d+)"/ms;
my ($rows,$cols) = /<title>(\d+) by (\d+) orthogonal maze<\/title>/ms; #vergeet de / van /title niet te escapen, anders zou de regexp eindigen voor die /


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

my $cellwidth = ($width-2*$marginX)/$rows;
print "cellwidth = $cellwidth\n";

my %blocks = ( );

while($f =~ m{<text x="(\d+)" y="(\d+)" (?:text-anchor="middle" style="font-family:Arial Narrow; font-size: xx-small;")?>(\d+)</text>}gms){
  $blocks{$3} = [$1-$1 % ($cellwidth/2),$2-$2 % ($cellwidth/2)];
}
print "blokken met centrum (X,Y)\n";
HoAprint(\%blocks);


my @muren_per_blok = ();
for my $i (1..keys %blocks){
  my @muren = (); # volgorde = Links, Rechts, Boven, Onder
  # print "going to do block{$i}\n";

  for (keys %{$vert_segm{$blocks{$i}->[0]-$cellwidth/2}}){
    my $rangeStart = $_;
    print "$rangeStart ";
    my $rangeEnd = $vert_segm{$blocks{$i}->[0]-$cellwidth/2}->{$_};
    print "$rangeEnd\n";

    if($blocks{$i}->[1]>= $rangeStart && $blocks{$i}->[1] <= $rangeEnd){
      $muren[0] = 1; # maw ja er is een muur hier
    }
    else {
      $muren[0] = 0;
    }
  }

  for (keys %{$vert_segm{$blocks{$i}->[0]+$cellwidth/2}}){
    my $rangeStart = $_;
    print "$rangeStart ";
    my $rangeEnd = $vert_segm{$blocks{$i}->[0]+$cellwidth/2}->{$_};
    print "$rangeEnd\n";

    if($blocks{$i}->[1] >= $rangeStart && $blocks{$i}->[1] <= $rangeEnd){
      $muren[1] = 1;
    }
    else{
      $muren[1] = 0;
    }
  }

  for (keys %{$horiz_segm{$blocks{$i}->[1]-$cellwidth/2}}){
    my $rangeStart = $_;
    print "$rangeStart ";
    my $rangeEnd = $horiz_segm{$blocks{$i}->[1]-$cellwidth/2}->{$_};
    print "$rangeEnd\n";

    if($blocks{$i}->[0] >= $rangeStart && $blocks{$i}->[0] <= $rangeEnd){
      $muren[2] = 1;
    }
    else{
      $muren[2] = 0;
    }
  }

  for (keys %{$horiz_segm{$blocks{$i}->[1]+$cellwidth/2}}){
    my $rangeStart = $_;
    print "$rangeStart ";
    my $rangeEnd = $horiz_segm{$blocks{$i}->[1]+$cellwidth/2}->{$_};
    print "$rangeEnd\n";

    if($blocks{$i}->[0] >= $rangeStart && $blocks{$i}->[0] <= $rangeEnd){
      $muren[3] = 1;
    }
    else {$muren[3] = 0;}
  }

  push @muren_per_blok, [@muren];


  print "\n going to next block\n";

} # einde van de for (1..keys %blocks)

sub AoAprint {
  my @array = @{$_[0]};
  for my $i (0..$#array){
  print "cell ",$i+1,"\tmuren 1 = ja, 0 = nee volgorde = L R B O\t","@{$array[$i]}\n";
  }
}

AoAprint(\@muren_per_blok);
