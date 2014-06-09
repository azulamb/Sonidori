#!/usr/bin/perl

################################################################################
# Setting
################################################################################

# Please edit lib path.
use lib qw( ../sonidori/lib );

# Please edit setting script path;
require '../sonidori/setting.pl';


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
if (
  $Sonidori->{ 'SYSTEM' }{ 'ENABLE_EDIT' } == 1 &&
  $Sonidori->{ 'GET' }{ 'edit' } ne '' )
{
  print $Sonidori->EditOut();
  exit( 0 );
}

print $Sonidori->Out();

