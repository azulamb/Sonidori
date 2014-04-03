#!/usr/bin/perl

################################################################################
# Setting
################################################################################

# Please edit setting script path;
require '../sonidori/setting_admin.pl';

# Please edit lib path.
use lib qw( ../sonidori/lib );

################################################################################
# Program
################################################################################
use strict;
use warnings;
use utf8;

use Sonidori;

# Create Sonidori object.
our $Sonidori = Sonidori->new();

$Sonidori->SetSetting( &SETTING::GetSetting() );

$Sonidori->Prepare();

# Call Sonidori Main.
print $Sonidori->Out();

