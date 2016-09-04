#!usr/bin/perl -w
use strict;

#Use a simple file format with one field per line:

#    FieldName: Value

#and separate records with blank lines.

# dit is de structuur van het record
my $wireless_netw = {
SSID => "", # let op komma's geen puntkomma's
Security => "",
Connected_Devices => []
}; # puntkomma na de declaratie vd hash niet vergeten



my @Array_of_Records = (
{SSID => "wireless netw 1", Security => "WPA2-Personal",Connected_Devices => [qw(192.168.1.234 192.168.1.235)]},
{SSID => "wireless netw 2", Security => "WEP",Connected_Devices => [qw(192.168.1.236 192.168.1.237)]});

foreach my $record (@Array_of_Records) {
    for my $key (sort keys %$record) {
      if(ref($record->{$key}) eq "ARRAY"){print "$key: ",join(", ",@{$record->{$key}}),"\n";}
        else{print "$key: $record->{$key}\n";}
    }
    print "\n";
}

# UITLEG
# ref() checkt of argument een referentie is, mogelijke waarden zie http://perldoc.perl.org/functions/ref.html
# de opbouw van de array is als volgt: @Array_of_Records krijgt via list assignment 2 volledige records mee met de structuur van een $wireless_netw records

# Inlezen, te onthouden perl special variable: $/ input record separator
# http://www.perl.com/pub/2004/06/18/variables.html
# in short:
# $/ = "\n" ---default elke newline is nieuw record
# $/ = undef --- slurp mode: lees alles tot aan de end of file marker
# $/ = "" --- paragraph read mode een lege lijn tussen 2 blokken is de separator, meerdere lege lijnen mag ook equiv met "\n\n+", maar zelf kan je geen regex toekennen aan $/
