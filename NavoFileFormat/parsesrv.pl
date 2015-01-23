#! perl -w
#
# parsesrv.pl [filename]
#
# Parses a .srv file so it can be easily loaded into Matlab.

use strict;

my $nameLine    = "0\n";
my $wptlblLine  = "0\n";
my $trnlblLine  = "0\n";
my $ladderLine  = "0\n";
my $ellipseLine = "0\n";
my $polygonLine = "0\n";
my $areaLine    = "0\n";  

open (LINE, "> lines.temp") or die "Cannot create lines.temp: $!";
open (WPT, "> wpt.temp") or die "Cannot create wpt.temp: $!";
open (EXCLUDE, "> exclude.temp") or die "Cannot create exclude.temp: $!";

while (<>) {

    # Multiple records possible

    if (/^EXCLUDE/) {
        s/EXCLUDE=//;
        my @temp = split /;/;
        print EXCLUDE "@temp";
    } elsif (/^LINE/) {
        s/LINE=//;
        my @temp = split /;/;
        print LINE "@temp";
    } elsif (/^POINT/) {
        s/POINT=//;
        my @temp1 = split /;/;
        my @temp2 = split ' ', $temp1[1];
        if ($temp2[2] =~ /N/) {
            $temp2[2] =~ s/N//;
            $temp1[1] = $temp2[0] + $temp2[1]/60 + $temp2[2]/3600;
        } elsif ($temp2[2] =~ /S/) {
            $temp2[2] =~ s/S//;
            $temp1[1] = -$temp2[0] - $temp2[1]/60 - $temp2[2]/3600;
        }
        my @temp3 = split ' ', $temp1[2];
        if ($temp3[2] =~ /E/) {
            $temp3[2] =~ s/E//;
            $temp1[2] = $temp3[0] + $temp3[1]/60 + $temp3[2]/3600;
        } elsif ($temp2[2] =~ /W/) {
            $temp3[2] =~ s/W//;
            $temp1[2] = -$temp3[0] - $temp3[1]/60 - $temp3[2]/3600;
        }
        if ($temp1[3] =~ /^\s*$/) {
            $temp1[3] = "-";
        }
        print WPT "@temp1";
    }
    
    # Single records only

    if (/^NAME/) {
        s/NAME=//;
        $nameLine = "1 $_";
    } elsif (/^WPTLBL/) {
        s/WPTLBL=//;
        my @temp = split /;/;
        $wptlblLine = "1 @temp";
    } elsif (/^TRNLBL/) {
        s/TRNLBL=//;
        my @temp = split /;/;
        $trnlblLine = "1 @temp";
    } elsif (/^LADDER/) {
        s/LADDER=//;
        my @temp = split /;/;
        $ladderLine = "1 @temp";
    } elsif (/^ELLIPSE/) {
        s/ELLIPSE=//;
        my @temp = split /;/;
        $ellipseLine = "1 @temp";
    } elsif (/^POLYGON/) {
        s/POLYGON=//;
        my @temp = split /;/;
        $polygonLine = "1 @temp";
    } elsif (/^AREA/) {
        s/AREA=//;
        $areaLine = "1 $_";
    }     
}
        
open (OTHER, "> other.temp") or die "Cannot create wpt.temp: $!";
print OTHER "$nameLine$wptlblLine$trnlblLine$ladderLine$ellipseLine$polygonLine$areaLine";






