package Blog;

use warnings;
use strict;
use utf8;

# This module adds blog.

# Constructor.
sub new()
{
  my ( $package, $sonidori ) = @_;
  my $hash = {};

  my $obj = bless( $hash, $package );

  push ( @{ $sonidori->{ 'GET_NAMES' } }, 'blog' );
  $sonidori->SetHook( 'SetEnv', $obj );
  $sonidori->SetHook( 'Out', $obj );

  return $obj;
}

# Destructor.
sub DESTROY()
{
  my ( $self ) = @_;
}

sub Hook()
{
  my ( $self, $sonidori, $hookpoint ) = @_;
  if ( $sonidori->{ 'GET' }{ 'blog' } ne '' )
  {
    if ( $hookpoint eq 'SetEnv' )
    {
      return $self->HookSetEnv( $sonidori );
    } elsif ( $hookpoint eq 'Out' )
    {
      return $self->HookOut( $sonidori );
    }
  }

  return '';
}

sub HookSetEnv()
{
  my ( $self, $sonidori ) = @_;

  if ( $sonidori->{ 'GET' }{ 'blog' } =~ /([0-9]{4})([0-9]{2})([0-9]{2})/ )
  {
    # Blog
    my ( $y, $m, $d ) = ( $1, $2, $3 );

    $sonidori->{ 'ENV' }{ 'filepath' } = sprintf( '%s/%4d/%02d/%02d/%s.%s',
      $sonidori->{ 'SYSTEM' }{ 'BLOG_DIR' },
      $y, $m, $d,
      $sonidori->{ 'SYSTEM' }{ 'INDEX_PAGE' },
      $sonidori->{ 'ENV' }{ 'tail' } );

    $sonidori->{ 'ENV' }{ 'page' } = '';

    return 'ok';
  } elsif ( $sonidori->{ 'GET' }{ 'blog' } =~ /([0-9]{4})([0-9]{2})/ )
  {
    # Day
    my ( $y, $m ) = ( $1, $2 );

    $sonidori->{ 'ENV' }{ 'filepath' } = sprintf( '%s/%4d/%02d',
      $sonidori->{ 'SYSTEM' }{ 'BLOG_DIR' },
      $y, $m );

    $sonidori->{ 'ENV' }{ 'page' } = '';

    return 'ok';
  } elsif ( $sonidori->{ 'GET' }{ 'blog' } =~ /([0-9]{4})/ )
  {
    # Month
    my ( $y ) = ( $1 );

    $sonidori->{ 'ENV' }{ 'filepath' } = sprintf( '%s/%4d',
      $sonidori->{ 'SYSTEM' }{ 'BLOG_DIR' },
      $y );

    $sonidori->{ 'ENV' }{ 'page' } = '';

    return 'ok';
  } else
  {
    # Year

    $sonidori->{ 'ENV' }{ 'filepath' } = $sonidori->{ 'SYSTEM' }{ 'BLOG_DIR' };

    $sonidori->{ 'ENV' }{ 'page' } = '';

    return 'ok';
  }

  return '';
}

sub HookOut()
{
  my ( $self, $sonidori ) = @_;

  my $md = '';
  my $title = '';

  my $path = $sonidori->{ 'ENV' }{ 'filepath' };

  if ( -f $path )
  {
    my ( @line ) = &Common::OpenFile( $path );
    $title = shift( @line );
    $sonidori->AddLastModifiedFromFile( $path );

    chomp( $title );
    if ( $title eq '' ){ $title = 'NoTitle' }

    # Parse.
    $md = &Common::Markdown( join( '', "# $title", @line ) );

    #return $sonidori->DefaultViewMarkdown( $sonidori->{ 'ENV' }{ 'filepath' }, $md, $title . ' - ' );
  } elsif ( -d $sonidori->{ 'ENV' }{ 'filepath' } )
  {
    $path = $sonidori->{ 'ENV' }{ 'filepath' };

    # Year or Month or Day list.
    my @dirs = &Common::DirectoryList( $path );

    my $base = $sonidori->{ 'ENV' }{ 'filepath' };
    $base =~ s/blog//;
    $base =~ s/\.//g;
    my $title = $base;
    $base =~ s/\///g;

    foreach ( @dirs )
    {
      $_ = sprintf( '+ [%02d](%s?blog=%s%02d)', $_, $sonidori->{ 'SYSTEM' }{ 'CGI' }, $base, $_ );
    }

    my $text = '';

    $text .= "# List\n";

    $text .= join( "\n", @dirs );

    # Parse.
    $md = &Common::Markdown( $text );

    #return $sonidori->DefaultViewMarkdown( $sonidori->{ 'ENV' }{ 'filepath' }, $md, $title . ' - ' );
  }

  my $html = '';
  # Load Template & Call template routine.
  if ( $md ne '' )
  {
    $path =~ s/$sonidori->{ 'SYSTEM' }{ 'BLOG_DIR' }//;
    $path =~ s/^\///;
    $path =~ s/^\.//;
    $path =~ s/\/+/\//g;
    if ( &Core::LoadModuleTopDown (
           'path'     => $path,
           'module'   => $sonidori->{ 'SYSTEM' }{ 'TEMPLATE' },
           'base_dir' => $sonidori->{ 'SYSTEM' }{ 'BLOG_DIR' },
           'perlpath' => $sonidori->{ 'SYSTEM' }{ 'PERL_PATH' } ) )
    {
      $html = join ( '', &Template::MarkDown( $sonidori, $sonidori->{ 'ENV' }{ 'filepath' }, $md, $title ) );
    } else
    {
      $html = $sonidori->DefaultViewMarkdown( $md, '' );
    }
  }

  return $html;
}

1;
