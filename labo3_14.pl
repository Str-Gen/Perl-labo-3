#!usr/bin/perl -w
use strict;

# uitzicht mailboxbestand
# Headerparagraaf
# From
# Subject

# Bericht

my (@msgs,@sub);
my $msgno = -1;
$/ = "";

while(<>){

# print "\nThis is the paragraph I read:\n$_\n"; for debugging purposes

  if(/\AFrom/){
    /^Subject:
      \s* (?# arbitrary amount of whitespace)
      (?:Re:\s*)* (?# non-capturing group Re and arbitrary whitespace, this subpattern may be matched any number of times in a row)
      (.*) (?# capturing group any character any amount of times)
    /xmi;
    # $_ =~ regex hierboven, resultaat in $_ is true of false
    $sub[++$msgno] = lc($1) || ''; #subject = lowercase(wat gecaptured werd) of lege string, het zal lege string zijn als lc($1) false geeft, als er geen match was dan $1 = undef -> false
  }
  next if /\AFrom/; # deze lijn zorgt ervoor dat enkel de content van een bepaald bericht wordt opgeslagen in de array met de messages, wel nog steeds op de juiste plaats, want die plaats werd bepaald in de code hierboven
  $msgs[$msgno] .= $_;
  # totdat een volgende match is gevonden worden alle paragraphs beschouwd als deel van de vorige mail en via append assignment toegevoegd aan het bericht
  # dit betekent wel dat een bericht met mangled heading (zeer onwaarschijnlijk bv From zou verkeerd geschreven moeten zijn of in txt file met opzet lowercase zonder i modifier aan de regex toe te voegen) ook bij het vorige bericht zal worden gestopt
}

# foreach(@sub){
#   print "subject = $_\n"; for debugging purposes
# }

for my $i (sort{$sub[$a] cmp $sub[$b] || $a <=> $b} (0..$#msgs)){
  printf "msgs[%d]: %s\n",$i,$msgs[$i];
}
