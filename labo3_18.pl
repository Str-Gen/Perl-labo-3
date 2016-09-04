#!usr/bin/perl
use strict;
use warnings;

my @OARG = @ARGV;
my @field = ();

sub AoAprint{
	my @arr = @{$_[0]};
	for my $i (0..$#arr){	
	my @tmp = @{$arr[$i]};
	for(@tmp){
		if($_){
			my $zeroes = 0;
			my @s = (split //,$_);
			if(scalar @s == 2){$zeroes = 1;}
			elsif(scalar @s == 1){$zeroes = 2;}
			print "0"x$zeroes,$_,' ';
		}
		else{
			print ' 'x4;
		}
	}
	print "\n";	
		
	}
}

sub HoAprint{
my %hash = %{$_[0]};
foreach my $key (sort{$a <=> $b} keys %hash){
	print "$key => @{$hash{$key}}\n";
	}
}


while(<>){
	chomp;
	push @field,[(split / /,$_)];
}

AoAprint(\@field);

my $size = scalar @field;
my $max_nr = $size*$size;

my @solution = (); # array van arrays dat de voorlopige oplossing bevat
my %possible = (); # hash met als waarde voor een key ofwel SET (dwz geen verandering mogelijk) ofwel een array met opties
my %used_values = ();
{
	for my $i (0..$size-1){
		for my $j (0..$size-1){
			if($field[$i][$j] ne '...' ){
				$solution[$i][$j] = $field[$i][$j];
					my $t = $solution[$i][$j];
					$t =~ s/^[0]*([1-9]+)/$1/; # leading 0'en verwijderen
				$used_values{$t} = 1; # alle reeds ingevulde getalwaarden zullen true geven bij test
				$possible{($i*$size)+($j+1)} = "SET";
			}
			else{
				$solution[$i][$j] = '   ';
				$possible{($i*$size)+($j+1)} = [];
			}
		}
	}
}

{
	print "reeds ingevulde getalwaarden:\n";
	for(sort {$a <=> $b}keys %used_values){
		print "$_ => $used_values{$_}\n";
	}
}

{
	print "celnummer => opties\n";
	for(sort{$a <=> $b} keys %possible){
		print "$_ =>\t $possible{$_}\n";
	}
}

for my $turn (0..3){

my %neighbours = ();

for (1..$max_nr){
	$neighbours{$_} = [];
}

{
	for my $i (0..$size-1){
		for my $j (0..$size-1){			
			my $this_cell = ($i*5)+($j+1);
			#bovenburen?
			my $up = 1;
			while($i-$up >= 0 && $possible{$this_cell - $up*$size} ne "SET"){
				push @{$neighbours{$this_cell}}, $this_cell-$up*$size;
				$up++;
			}
			#onderburen?
			my $down = 1;
			while($i+$down < $size && $possible{$this_cell + $down*$size} ne "SET"){
				push @{$neighbours{$this_cell}}, $this_cell+$down*$size;
				$down++;
			}
			#linkerburen?
			my $left = 1;
			while($j-$left >= 0 && $possible{$this_cell - $left} ne "SET"){
				push @{$neighbours{$this_cell}} , $this_cell-$left;
				$left++;
			}
			#rechterburen?
			my $right = 1;
			while($j+$right < $size && $possible{$this_cell + $right} ne "SET"){
				push @{$neighbours{$this_cell}}, $this_cell+$right;
				$right++;
			}
		}
	}
}


print "alle buren per cel:\n";
HoAprint(\%neighbours);

{
	for (keys %possible){		
		if($possible{$_} eq "SET"){
			my $rownr = int(($_-1) / $size);
			my $colnr = ($_-1) % $size;
			my $value = $solution[$rownr][$colnr];
			for my $i (@{$neighbours{$_}}){
				if($_ - $i < $size && $_-$i > -$size && $_-$i != 0){
					push @{$possible{$i}}, $value + ($_-$i) if(!exists($used_values{$value +($_-$i)}) && ($value + $_ - $i)>0);
					push @{$possible{$i}}, $value -($_-$i) if(!exists($used_values{$value - ($_-$i)}) && ($value - $_ + $i)>0);
				}
				else{
					my $delta = ($_-$i)/$size;					
					push @{$possible{$i}}, $value + $delta if(!exists($used_values{$value+$delta}) && $value+$delta > 0);
					push @{$possible{$i}}, $value - $delta if(!exists($used_values{$value-$delta}) && $value-$delta > 0);
				}
			}
		}
	}
}

{
	for (sort{$a <=> $b}keys %possible){
		print "opties cel $_:  ";
		if($possible{$_} eq "SET"){
			print "none\n";
		}
		elsif(scalar @{$possible{$_}} != 0){
			print "@{$possible{$_}}\n";
		}
		else{
			print "none because all values taken\n";
		}
	}
}


my %candidate = ();
my %guaranteed = (); # zie opm wat verder
{
	for(keys %possible){
		if($possible{$_} ne "SET"){		
		my %seen;	
		print "cell $_\t";
		print "@{$possible{$_}}\n";
### LET OP TURN DIE HIER EENS VOORKOMT
		if(scalar @{$possible{$_}} == 1 && $turn > 1){ # als er maar 1 waarde mogelijk zou zijn, deze vw zal meestal pas na een aantal iteraties kunnen optreden
				$guaranteed{$_} = @{$possible{$_}}[0];
				print "cel $_ wordt sowieso $guaranteed{$_}\n";
			}
		for(@{$possible{$_}}){				
				$seen{$_}++;
			}
		for(keys %seen){
			print "$_ => $seen{$_}\n";
		}
		for my $k (keys %seen){
			if($seen{$k}>=2){
				push @{$candidate{$_}}, $k;
			}		
		}	
		
		
		}
	}
}

{
	for(sort {$a <=>$b} keys %candidate){
		print "cel $_: @{$candidate{$_}}\n";
	}
}

my %candidate_reversed = ();

{
	for(keys %candidate){		
		my @vals = @{$candidate{$_}};
		for my $v (@vals){
			push @{$candidate_reversed{$v}},$_;
		}	
		
	}		
}
print "candidate reversed:";
HoAprint(\%candidate_reversed);
print "\n\n";

for (keys %candidate_reversed){
	if(scalar values @{$candidate_reversed{$_}} == 1 && !exists($used_values{$_})){
		$possible{$candidate_reversed{$_}[0]} = "SET";
		$used_values{$_} = 1;
		#print "$candidate_reversed{$_}[0]\n";
		my $rownr = int(($candidate_reversed{$_}[0]-1) / $size);
		#print "$rownr\n";
		my $colnr = ($candidate_reversed{$_}[0]-1) % $size;
		#print "$colnr\n";
		$solution[$rownr][$colnr] = $_;
	}
	elsif(scalar values @{$candidate_reversed{$_}} == 2){ #centrumcel discrimineren
		my $centrumcelnummer = int($size/2) * $size + int($size/2) +1;		
		my @plaats = grep {$_ != $centrumcelnummer} @{$candidate_reversed{$_}};
		if(scalar @plaats == 1){
			$possible{$plaats[0]} ="SET";
			$used_values{$_} = 1;
			my $rownr = int(($plaats[0]-1)/ $size);
			my $colnr = ($plaats[0]-1) % $size;
			#print "[$rownr][$colnr]\n";
			$solution[$rownr][$colnr] = $_;
		}
		elsif(scalar @plaats == 2){
			# te plaatsen waarde zit in $_
			for my $p (@plaats){
				my $rownr = int(($p-1)/$size);
				my $colnr = ($p-1) % $size;
				my @close = (undef,undef,undef,undef); #array met waarden L R B O
				if($colnr-1>=0){
					$close[0] = $solution[$rownr][$colnr-1] if ($solution[$rownr][$colnr-1] ne "    ");
				}
				if($colnr+1<$size){
					$close[1] = $solution[$rownr][$colnr+1] if ($solution[$rownr][$colnr+1] ne "    ");
				}
				if($rownr-1>=0){
					$close[2] = $solution[$rownr-1][$colnr] if ($solution[$rownr-1][$colnr] ne "    ");
				}
				if($rownr+1<$size){
					$close[3] = $solution[$rownr+1][$colnr] if ($solution[$rownr+1][$colnr] ne "    ");
				}
				# in between horizontaal oplossing

				if(defined($close[0]) && defined($close[1])){
					if(($close[0]+$close[1])/2 == $_){
					$solution[$rownr][$colnr] = $_;
					$used_values{$_} = 1;
					$possible{$p} = "SET";
					}
				}
				if(defined($close[2]) && defined($close[3])){
					if(($close[2]+$close[3])/2 == $_){
					$solution[$rownr][$colnr] = $_;
					$used_values{$_} = 1;
					$possible{$p} = "SET";
					}
				}
			}
		}
	}

}
# gegarandeerde invullen
for(keys %guaranteed){
	my $rownr = int(($_-1) / $size);
	my $colnr = ($_-1) % $size;
	$solution[$rownr][$colnr] = $guaranteed{$_} if($solution[$rownr][$colnr] eq "    ");
	$possible{$_} = "SET";
	$used_values{$guaranteed{$_}} = 1;
}


# hash possible opruimen:
for(keys %possible){
	if($possible{$_} ne "SET"){
		$possible{$_} = [];
	}
}

AoAprint(\@solution);
print "\n";


}



