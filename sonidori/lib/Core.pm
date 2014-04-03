package Core;

# Core Library

use warnings;
use strict;
use utf8;

sub LoadModule()
{
  my %args = (
    'module'   => '',
    @_
  );

  if ( -f $args{ 'module' } )
  {
    require $args{ 'module' };
    return $args{ 'module' };
  }

  return '';
}

sub LoadModuleTopDown()
{
  my %args = (
    'path'     => '',
    'module'   => '',
    'base_dir' => '',
    @_
  );

  my $lmodule = $args{ 'base_dir' } . '/' . $args{ 'module' };
  my $tmp = $args{ 'base_dir' };

  my @list = split( /\//, $args{ 'path' } );

  foreach ( @list )
  {
    $tmp = $tmp . '/' . shift( @list );
    if( -f $tmp . '/' . $args{ 'module' } )
    {
      $lmodule = $tmp . '/' . $args{ 'module' };
    }
  }

  return &Core::LoadModule( 'module' => $lmodule );
}

sub LoadPackage()
{
  my %args = (
    'module'   => '',
    'package'  => '',
    'function' => '',
    @_
  );

  if ( &Core::LoadModule( $args{ 'module' } ) ne '' )
  {
    my $ret = eval( "exists ( &$args{ 'package' }::$args{ 'function' } )" );
    if ( $ret )
    {
      return $args{ 'module' };
    }
  }

  return '';
}

sub AddPlugin()
{
  my %args = (
    'plugin'   => '',
    'perlpath' => 'perl',
    @_
  );

  my @plugins = &Common::OpenFile( $args{ 'plugin' } );

  foreach ( @plugins )
  {
    &Core::LoadPackage(
      'module'   => '',
      'package'  => '',
      'function' => 'Plugin', );
  }

}

1;

__END__
=POD
=head1 Name
Core : Sonidori core module.

