#!/usr/bin/perl -w
use strict;

my $wireless_netw = {
SSID => "", # let op komma's geen puntkomma's
Security => "",
Connected_Devices => []
}; # puntkomma na de declaratie vd hash niet vergeten

my $input = "Cisco access point; WPA2-Personal; 192.168.0.234; 192.168.0.239";

my @parts = split(/; /, $input);
$wireless_netw -> {SSID} = shift @parts;
$wireless_netw -> {Security} = shift @parts;
while(my ($item) = splice(@parts, 0, 1)){ #OPM: de haakjes rond $item zijn er om aan te duiden dat splice eigenlijk in list context terug geeft,
                                              # hier wordt maar 1 element eraf gehaald dus zonder de haakjes werkt het ook nog
  push @{$wireless_netw->{Connected_Devices}}, $item;
}

printf "SSID: %-30s\nSecurity: %s\nConnected Devices: %20s\n",$wireless_netw->{SSID},$wireless_netw->{Security},join(", ",@{$wireless_netw->{Connected_Devices}});

# Stel dat er een file aanwezig was die een hele oplijsting van wireless_netw is dan zou voor elk van die netwerken de datastructuur ingevuld kunnen worden
# Het resultaat is dan bv een array van deze datastructuren (meer precies elk element van de array zou een referentie zijn naar zijn datastructuur)
# Het zou ook mogelijk worden om lijsten te maken gesorteerd op een van de velden van het record
# bv $bySSID{$wireless_netw->{SSID}} = $wireless_netw
# bovenstaande lijn stopt de referentie naar het record als value in een nieuwe hash %bySSID die als key telkens de SSID van het netwerk in kwestie heeft
# een veld van de datastructuur wordt maw gebruikt als key om te wijzen naar dezelfde volledige datastructuur.
# Dat kan handig zijn als je van plan ben opzoekingen te doen adhv die property van je record
