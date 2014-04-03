package PluginManagement;

use warnings;
use strict;
use utf8;

sub new()
{
  my ( $package ) = @_;

  my $hash=
  {
    'PLUGIN' => {},
  };

  return bless ( $hash, $package );
}

sub LoadPlugin()
{
  my ( $self, $name, $package ) = ( @_, '', '' );

  my $libpath = $package;

  $libpath =~ s/\:\:/\//g;
  $libpath = $self->{ 'basedir' } . '/' . $libpath . '.pm';

  if ( eval( "require \"$libpath\"" ) )
  {
    my $obj = eval{ $package->new };
    if ( $obj )
    {
      return $obj;
    }
  }

  return '';
}

sub LoadInstalledPlugin()
{
  my ( $self, $file, $dir ) = ( @_, '', '', '' );

  my @plugins = &Common::OpenFile( $dir . '/' . $file );

  my $count = 0;

  $self->{ 'basedir' } = $dir;

  foreach ( @plugins )
  {
    my $plugin = $_;
    chomp ( $plugin );

    my $package = $dir . '/' . $plugin;

    if ( -f $package . '/Install.pm' )
    {
      if ( eval ( "require \"$package/Install.pm\"" ) &&
           eval ( "exists( &$plugin\:\:Install\:\:Install )" ) &&
           eval ( "&$plugin\:\:Install\:\:Install( \$self );" ) )
      {
        ++$count;
      }

    }
  }

  return $count;
}

sub AddPlugin()
{
  my $self = shift( @_ );
  my %args = (
    'name'    => '',
    'package' => '',
    'type'    => 'NONE', # INLINE, BLOCK, HOOK
    @_
  );

  if ( $self eq '' || $args{ 'name' } eq '' || $args{ 'package' } eq '' ){ return ''; }

  my $obj = $self->LoadPlugin( $args{ 'name' }, $args{ 'package' } );

  if ( $obj eq '' ){ return ''; }

  if ( $args{ 'type' } =~ /INLINE/i )
  {
    $args{ 'type' } = 'INLINE';
  } elsif ( $args{ 'type' } =~ /BLOCK/i )
  {
    $args{ 'type' } = 'BLOCK';
  } elsif ( $args{ 'type' } =~ /HOOK/i )
  {
    $args{ 'type' } = 'HOOK';
  } else
  {
    $args{ 'type' } = 'NONE';
  }

  if ( $args{ 'type' } eq 'NONE' ){ return ''; }

  $self->{ 'PLUGIN' }->{ $args{ 'name' } } = {
    'object' => $obj,
    'type'   => $args{ 'type' }
  };

  return ref( $obj );
}

sub AddInlinePlugin()
{
  my ( $self, $name, $package ) = ( @_, '', '', '' );

  if ( $self eq '' || $name eq '' || $package eq '' ){ return ''; }

  return $self->AddPlugin( 'name' => $name, 'package' => $package, 'type' => 'INLINE' );
}

sub UsePlugin()
{
  my ( $self, $sonidori, $plugin, @args ) = ( @_, '', '', '', '' );
  my ( $type, $mode );

  unless ( exists( $self->{ 'PLUGIN' }->{ $plugin } ) )
  {
    return sprintf( 'ErrorPlugin:%s%s', $plugin, "\n" );
  }

  $type = $self->{ 'PLUGIN' }->{ $plugin }->{ 'type' };

  if ( $type eq 'INLINE' )
  {
    return $self->{ 'PLUGIN' }->{ $plugin }->{ 'object' }->Inline( $sonidori, @args );
  }elsif ( $type eq 'BLOCK' )
  {
    return $self->{ 'PLUGIN' }->{ $plugin }->{ 'object' }->Block( $sonidori, @args );
  }
  return 'ERROR';
}

1;

