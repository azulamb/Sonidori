package admin::plugin;

use warnings;
use strict;
use utf8;

sub new()
{
  my ( $package ) = @_;

  my $hash = {};

  return bless ( $hash, $package );
}

sub Dir2Table()
{
  my ( $self, $dir, $file ) = ( @_ );

  $file = $dir . $file;

  my $html = '';
  my %pluginlist;

  if ( opendir( DIR, $dir ) )
  {
    my @tmp = readdir( DIR );
    closedir( DIR );
    foreach ( @tmp )
    {
      if ( -d $dir . $_  && !( $_ =~ /^\./ ) ){ $pluginlist{ $_ } = 0; }
    }
  }

  if ( -f $file && open( FILE, "< $file" ) )
  {
    while ( <FILE> )
    {
      if ( exists( $pluginlist{ $_ } ) ){ $pluginlist{ $_ } = 1; }
    }
    close( FILE );
  }

  $html .= sprintf( '<form>' ); # todo pluginfile.
  $html .= sprintf( '<table>' );
  my @list = sort{ $a cmp $b }( keys( %pluginlist ) );
  foreach ( @list )
  {
    $html .= sprintf( '<tr><td><input type="checkbox" value="%s" checked="%s" /></td><td>%d</td></tr>',
        $_, ( $pluginlist{ $_ } ? 'checked' : '' ),
        $_
      );
  }
  $html .= sprintf( '</table>' );
  $html .= sprintf( '</form>' );

  return $html;
}

sub Inline()
{
  my ( $self, $sonidori ) = ( @_ );

  my $html = '';

  if ( ref( $sonidori->{ 'SYSTEM' }{ 'PLUGIN_DIR' } ) eq 'ARRAY' )
  {
    foreach ( @{ $sonidori->{ 'SYSTEM' }{ 'PLUGIN_DIR' } } )
    {
      $html .= $self->Dir2Table( $sonidori->{ 'SYSTEM' }{ 'INSTALLED_PLUGIN_FILE' }, $sonidori->{ 'SYSTEM' }{ 'SONIDORI_PATH' } . '/' . $_ . '/' );
    }
  } else
  {
    $html .= $self->Dir2Table( $sonidori->{ 'SYSTEM' }{ 'INSTALLED_PLUGIN_FILE' }, $sonidori->{ 'SYSTEM' }{ 'SONIDORI_PATH' } . '/' . $sonidori->{ 'SYSTEM' }{ 'PLUGIN_DIR' } . '/' );
  }

  return $html;
}

1;
