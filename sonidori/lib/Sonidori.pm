#!/usr/bin/perl
package Sonidori;

################################################################################
# Program
################################################################################
use strict;
use warnings;
use utf8;
use open IO => ":utf8";
require bytes;

binmode( STDOUT, ":utf8" );

# Constructor
sub new()
{
  my ( $package ) = @_;

  my $hash = {};

  # Environment variable.
  $hash->{ 'ENV' } =
  {
    'ver'         => '0.1',
    'filepath'    => '',
    'mode'        => 'markdown',
    'dev'         => 'PC',
    'HTTP_HEADER' => { 'Content-Type' => 'text/html' },
  };

  # System Setting.
  $hash->{ 'SYSTEM' } =
  {
    'ENABLE_DIRECTORY'      => 1,
    'PUBLIC_DIR'            => './wiki',
    'BLOG_DIR'              => './blog',
    'CGI'                   => '',
    'INDEX_PAGE'            => 'FrontPage',
    'TEMPLATE'              => '.template.pl',
    'TAIL'                  => 'md',
    'SONIDORI_PATH'         => '../sonidori',
    'PLUGIN_DIR'            => 'plugin',
    'INSTALLED_PLUGIN_FILE' => 'plugins.txt',
    'HTML_TEMPLATE'         =>
    {
      'PC'                  => '../sonidori/template/template.html',
      'Android'             => '../sonidori/template/template.html',
      'AndroidMobile'       => '../sonidori/template/template_mobile.html',
      'iPhone'              => '../sonidori/template/template_mobile.html',
      'WindowsPhone'        => '../sonidori/template/template_mobile.html',
    },
  };

  # Add GET data.
  $hash->{ 'GDATA' }  = {};

  # Get data (GET method).
  $hash->{ 'GET' }       = {};
  $hash->{ 'GET_NAMES' } = [ 'page', 'tail', 'dir', 'dev' ];

  # Get data (POST method).
  $hash->{ 'POST' }       = {};
  $hash->{ 'POST_NAMES' } = [];

  # Get Cookie.
  $hash->{ 'COOKIE' }       = {};
  $hash->{ 'COOKIE_NAMES' } = [];

  # Hook.
  $hash->{ 'HOOK' } = { 'SetEnv' => {} };

  return bless( $hash, $package );
}

# Prepare routine.
sub Prepare ()
{
  my ( $sonidori ) = @_;

  $sonidori->LoadLibrary();

  $sonidori->Decode();

  $sonidori->LoadPlugin();

  $sonidori->SetEnv();

  $sonidori->SetViewMode();
}

# Set setting.
sub SetSetting()
{
  my ( $sonidori, $hash ) = ( @_, '', '' );

  $sonidori->{ 'SYSTEM' } = $hash;

  return 0;
}

# Load library and Hook API.
sub LoadLibrary()
{
  my ( $sonidori ) = @_;
  my %lib;
  my $path = $sonidori->{ 'SYSTEM' }{ 'SONIDORI_PATH' } . '/lib';

  if ( opendir( DIR, $path ) )
  {
    foreach ( readdir( DIR ) )
    {
      if ( -f $path . '/' . $_ && $_ =~ /(.+)(\.pm)$/ )
      {
        $lib{ $1 } = 1;
      }
    }
    closedir( DIR );
  }

  delete( $lib{ 'Sonidori' } );

  my @lib = sort{ $a cmp $b }( keys( %lib ) );

  foreach ( @lib )
  {
    my $libpath = $path . '/' . $_ . '.pm';
    if ( eval( "require \"$libpath\"" ) )
    {
      my $obj = eval{ $_->new( $sonidori ) };
      if ( $obj && ref( $obj ) )
      {
        # Success new.
        $sonidori->{ $_ } = $obj;
      }
    }
  } # end loop

  return 0;
}

sub SetHook()
{
  my ( $sonidori, $hook, $obj ) = ( @_, '', '' );

  if ( $hook eq '' || ! ref( $obj ) ){ return 1; }
  $sonidori->{ 'HOOK' }{ $hook }{ ref( $obj ) } = $obj;

  return 0;
}

sub Hook()
{
  my ( $sonidori, $key ) = ( @_, '' );

  my $ret = '';
  foreach ( keys( %{ $sonidori->{ 'HOOK' }{ $key } } ) )
  {
    $ret = $sonidori->{ 'HOOK' }{ $key }{ $_ }->Hook( $sonidori, $key );
    if ( $ret ){ return $ret; }
  }
  return $ret;
}

# Decode.
sub Decode()
{
  my ( $sonidori, $tmpbase ) = ( @_, '' );

  if ( $tmpbase ne '' ){ $sonidori->{ 'Decode' }->{ 'BASE_FILE_NAME' } = $tmpbase; }

  # Get data (GET method).
  $sonidori->{ 'GET' }    = $sonidori->{ 'Decode' }->Get( @{ $sonidori->{ 'GET_NAMES' } } );
  # Get data (POST method).
  $sonidori->{ 'POST' }   = $sonidori->{ 'Decode' }->Post( @{ $sonidori->{ 'POST_NAMES' } } );
  # Get Cookie.
  $sonidori->{ 'COOKIE' } = $sonidori->{ 'Decode' }->GetCookie( @{ $sonidori->{ 'COOKIE_NAMES' } } );

  return 0;
}

# Load pligin.
sub LoadPlugin()
{
  my ( $sonidori ) = @_;

  if ( ref( $sonidori->{ 'SYSTEM' }{ 'PLUGIN_DIR' } ) eq 'ARRAY' )
  {
    foreach ( @{ $sonidori->{ 'SYSTEM' }{ 'PLUGIN_DIR' } } )
    {
      $sonidori->{ 'PluginManagement' }->LoadInstalledPlugin(
        $sonidori->{ 'SYSTEM' }{ 'INSTALLED_PLUGIN_FILE' },
        $sonidori->{ 'SYSTEM' }{ 'SONIDORI_PATH' } . '/' . $_
      );
    }
  } else
  {
    $sonidori->{ 'PluginManagement' }->LoadInstalledPlugin(
      $sonidori->{ 'SYSTEM' }{ 'INSTALLED_PLUGIN_FILE' },
      $sonidori->{ 'SYSTEM' }{ 'SONIDORI_PATH' } . '/' . $sonidori->{ 'SYSTEM' }{ 'PLUGIN_DIR' }
    );
  }
  return 0;
}

# Set view mode.
sub SetViewMode()
{
  my ( $sonidori, $mode ) = ( @_, '' );

  # View mode.
  if ( $mode ne '' )
  {
    $sonidori->{ 'ENV' }{ 'dev' } = $mode;
  } elsif ( $sonidori->{ 'GET' }{ 'dev' } eq 'pc' )
  {
    $sonidori->{ 'ENV' }{ 'dev' } = 'PC';
    $sonidori->{ 'GDATA' }{ 'dev' } = 'pc';
  } elsif ( $sonidori->{ 'GET' }{ 'dev' } eq 'mobile' )
  {
    $sonidori->{ 'ENV' }{ 'dev' } = 'AndroidMobile';
    $sonidori->{ 'GDATA' }{ 'dev' } = 'mobile';
  } else
  {
    $sonidori->{ 'ENV' }{ 'dev' } = &Common::GetPageType();
  }

  return 0;
}

sub SetEnv()
{
  my ( $sonidori ) = @_;

  $sonidori->{ 'ENV' }{ 'tail' } = $sonidori->{ 'SYSTEM' }{ 'TAIL' };

  my $flag = $sonidori->Hook( 'SetEnv' );

  unless ( $flag )
  {
    $sonidori->{ 'ENV' }{ 'page' } = $sonidori->{ 'GET' }{ 'page' };

    # Complementary extention.
    if ( $sonidori->{ 'GET' }{ 'tail' } ne '' )
    {
      $sonidori->{ 'ENV' }{ 'tail' } = $sonidori->{ 'GET' }{ 'tail' };
    }

    # Complementary page name.
    if ( $sonidori->{ 'GET' }{ 'page' } eq '' )
    {
      if ( $sonidori->{ 'GET' }{ 'dir' } ne '' )
      {
        $sonidori->{ 'ENV' }{ 'page' } = $sonidori->{ 'GET' }{ 'dir' };
      } else
      {
        $sonidori->{ 'ENV' }{ 'page' } = $sonidori->{ 'SYSTEM' }{ 'INDEX_PAGE' };
      }
    }
    $sonidori->{ 'ENV' }{ 'filepath' } = $sonidori->SetFilepath();
  }

  return 0;
}

sub SetFilepath()
{
  my ( $sonidori ) = @_;

  # Filepath (Full).
  my $filepath = $sonidori->{ 'SYSTEM' }{ 'PUBLIC_DIR' } . '/' . $sonidori->{ 'ENV' }{ 'page' } . '.' . $sonidori->{ 'ENV' }{ 'tail' };

  # File check.
  if ( !( -f $filepath ) )
  {
    # Directory check.

    if ( $sonidori->{ 'SYSTEM' }{ 'ENABLE_DIRECTORY' } ne '0' &&
         -d $sonidori->{ 'SYSTEM' }{ 'PUBLIC_DIR' } . '/' . $sonidori->{ 'GET' }{ 'page' } )
    {
      if ( $sonidori->{ 'GET' }{ 'dir' } eq '' && $sonidori->{ 'SYSTEM' }{ 'PUBLIC_DIR' } . '/' . $sonidori->{ 'GET' }{ 'page' } . '/' . $sonidori->{ 'SYSTEM' }{ 'INDEX_PAGE' } . '.' . $sonidori->{ 'ENV' }{ 'tail' } )
      {
        # FrontPage.
        $sonidori->{ 'ENV' }{ 'page' } = $sonidori->{ 'SYSTEM' }{ 'PUBLIC_DIR' } . '/' . $sonidori->{ 'ENV' }{ 'page' } . '/' . $sonidori->{ 'SYSTEM' }{ 'INDEX_PAGE' };
        $filepath = $sonidori->{ 'ENV' }{ 'page' } . '.' . $sonidori->{ 'ENV' }{ 'tail' };
      } else
      {
        # Directory list.
        $sonidori->{ 'ENV' }{ 'mode' } = 'dir';
        $sonidori->{ 'ENV' }{ 'page' } = $sonidori->{ 'GET' }{ 'dir' };
        $filepath = $sonidori->{ 'SYSTEM' }{ 'PUBLIC_DIR' } . '/' . $sonidori->{ 'ENV' }{ 'page' };
      }
    } else
    {
      # Not found.
      $filepath = '.404.' . $sonidori->{ 'SYSTEM' }{ 'TAIL' };
    }
  } elsif ( !( -r $sonidori->{ 'ENV' }{ 'filepath' } ) ||
            $sonidori->{ 'GET' }{ 'page' } =~ /^\./ )
  {
    # Cannot read file.
    $sonidori->{ 'ENV' }{ 'filepath' } = '.401.' . $sonidori->{ 'SYSTEM' }{ 'TAIL' };
  }

  return $filepath;
}

sub Out()
{
  my ( $sonidori ) = ( @_, '', '' );

  my $html = $sonidori->Hook( 'Out' );

  if ( $html eq '' )
  {
    if ( $sonidori->{ 'ENV' }{ 'mode' } eq 'markdown' )
    {
      # Markdown.
      $html .= $sonidori->File2HTMLOut( $sonidori->{ 'ENV' }{ 'filepath' } );
    } elsif ( $sonidori->{ 'ENV' }{ 'mode' } eq 'dir' )
    {
      # Directory.
      $html .= $sonidori->Dir2HTMLOut( $sonidori->{ 'ENV' }{ 'filepath' } );
    } else
    {
      # Binary file.
      $html .= $sonidori->Binnary2Out( $sonidori->{ 'ENV' }{ 'filepath' } );
    }
  }

  # Add Content-Length.
  $sonidori->AddContentLength( $html );

  # Printout HTTP Header.
  my $htmlheader = $sonidori->HTMLHeader();

  return $htmlheader . $html;
}

sub File2HTMLOut()
{
  my ( $sonidori, $file ) = @_;

  # OpenFile.
  my $text = join ( '', &Common::OpenFile( $file ) );
  $sonidori->AddLastModifiedFromFile( $file );

  return $sonidori->Markdown2HTMLOut( $text, $file );
}

sub Markdown2HTMLOut()
{
  my ( $sonidori, $text, $file ) = @_;
  my $html = '';
  # Parse.
  my $md = &Common::Markdown( $text );

  # Load Template & Call template routine.
  if ( $sonidori->LoadTemplate ( $file ) )
  {
    $html = join ( '', &Template::MarkDown( $sonidori, $file, $md ) );
  } else
  {
    $html = $sonidori->DefaultViewMarkdown( $md, '' );
  }

  return $html;
}

sub Dir2HTMLOut()
{
  my ( $sonidori, $dir ) = @_;
  my $html = '';

  # Load Template & Call template routine.
  if ( $sonidori->LoadTemplate ( $dir ) )#$template ) )
  {
    $html = join ( '', &Template::Directory( $sonidori, $dir ) );
  } else
  {
    $html = $sonidori->DefaultViewDirectory( $dir );
  }

  return $html;
}

sub Binnary2Out()
{
  my ( $sonidori, $file ) = @_;
  my $html = '';
  # TODO rewirte content-type

  my @out = &Common::OpenBinFile ( $file );

  binmode STDOUT;
  $html =  join ( '', @out );

  return $html;
}

sub HTMLHeader()
{
  my ( $sonidori ) = @_;
  my $htmlheader = '';
  foreach ( keys ( %{ $sonidori->{ 'ENV' }{ 'HTTP_HEADER' } } ) )
  {
    $htmlheader .= sprintf( "%s: %s%s", $_, $sonidori->{ 'ENV' }{ 'HTTP_HEADER' }{ $_ }, "\n" );
  }

  return $htmlheader . "\n";
}

sub AddContentLength()
{
  my ( $sonidori, $data ) = @_;
  return $sonidori->AddHtmlHeader( 'Content-Length', bytes::length( $data ) );
}

sub AddHtmlHeader()
{
  my ( $sonidori, $key, $value ) = @_;

  $sonidori->{ 'ENV' }{ 'HTTP_HEADER' }{ $key } = $value;

  return 0;
}

sub AddLastModified()
{
  my ( $sonidori, $lastmod ) = ( @_, 0 );
  $sonidori->{ 'ENV' }{ 'HTTP_HEADER' }{ 'Last-Modified' } = &Common::DateRFC1123( $lastmod );

  return 0;
}

sub AddLastModifiedFromFile()
{
  my ( $sonidori, $file ) = ( @_, '' );

  my $lastmod = 0;

  if ( -f $file )
  {
    $lastmod = ( stat $file )[ 9 ];
  }

  return $sonidori->AddLastModified( $lastmod );
}

sub SplitArgs()
{
  my ( $sonidori, $args ) = ( @_, '', '' );

  my @args;

  if ($args =~ /([\s\t]+)/ )
  {
    while ( $args =~ /([\s\t]+)/ )
    {
      my ( $prev, $match, $next ) = ( $`, $&, $' );
      if ( $prev =~ /^\"(.*)/ )
      {
        $prev = $1;
        if ( !( $prev =~ /\"$/ ) && $next =~ /(.*)\"(.*)/ )
        {
          $prev .= $match . $1;
          $next = $1;
        }
      }
      push ( @args, $prev );
      $args = $next;
    }
    if ( $args ne '' ){ push( @args, $args ); }
  } else
  {
    @args = ( $args );
  }

  return @args;
}

sub PluginParse()
{
  my ( $sonidori, @lines ) = @_;
  my @src = ();

  @lines = split ( /\n/, join ( '', @lines ) );

  while ( @lines )
  {
    my $line = shift ( @lines );
    chomp ( $line );

    if ( $line =~ /\{\{.+\}\}/ )
    {
      # inline plugin

      my $src = '';
      foreach ( split ( /\{\{/, $line ) )
      {
        if ( $_ =~ /(.+)\}\}(.*)/ )
        {
          my $after = $2;
          my ( $plugin, $args ) = split ( /\s+/, $1, 2 );
          unless ( $args ){ $args = ''; }
          my @args = $sonidori->SplitArgs ( $args );
          $src .= $sonidori->{ 'PluginManagement' }->UsePlugin ( $sonidori, $plugin, @args );
          $src .= $after;
        } else
        {
          $src .= $_;
        }
      }

      push ( @src, "$src" );
    } elsif ( $line =~ /^\{\{(.+)/ )
    {
      # block plugin

      my ( $plugin, $args ) = split ( /\s+/, $1, 2 );
      unless ( $args ){ $args = ''; }
      my @args = $sonidori->SplitArgs ( $args );

      my $block = '';

      while ( @lines )
      {
        $line = shift( @lines );
        if ( $line =~ /^\}\}/ )
        {
          last;
        } else { $block .= $line; }
      }

      push ( @src, $sonidori->{ 'PluginManagement' }->UsePlugin ( $sonidori, $plugin, $block, @args ) );

      push( @src, "$block" );

    } else
    {
      # text
      push ( @src, $line );
    }

  } # while

  return join ( "\n", @src );
}

sub SonidoriLink()
{
  my ( $sonidori ) = ( @_, '' );
  return sprintf( '<a href="http://hiroki.azulite.net/?page=Sonidori">Sonidori</a> ver %s made by Hiroki.', $sonidori->{ 'ENV' }{ 'ver' } );
}

sub LoadTemplate ()
{
  my ( $sonidori, $path ) = ( @_, '', '' );
  $path =~ s/$sonidori->{ 'SYSTEM' }{ 'PUBLIC_DIR' }//;
  $path =~ s/^\///;
  $path =~ s/^\.//;
  $path =~ s/\/+/\//g;

  return &Core::LoadModuleTopDown (
    'path'     => $path,
    'module'   => $sonidori->{ 'SYSTEM' }{ 'TEMPLATE' },
    'base_dir' => $sonidori->{ 'SYSTEM' }{ 'PUBLIC_DIR' },
    'perlpath' => $sonidori->{ 'SYSTEM' }{ 'PERL_PATH' } );
}

sub LoadTemplateHtml()
{
  my ( $sonidori, %data ) = @_;
  my @line = &Common::OpenFile( $data{ 'htmltemplate' } );

  $data{ 'sonidori' } = $sonidori->SonidoriLink();

  foreach ( @line )
  {
    while ( $_ =~ /\<\!\-\- (.+) \-\-\>/ )
    {
      my $key = $1;
      if ( exists( $data{ $1 } ) )
      {
        my $value = $data{ $key };
        $_ =~ s/\<\!\-\- $key \-\-\>/$value/;

      } elsif ( $key =~ /(plugin)\:(.*)/ )
      {
        my ( $plugin, $arg ) = ( $1, $2 );
        $_ =~ s/\<\!\-\- $key \-\-\>/\{\{$arg\}\}/;
      } else
      {
        $_ =~ s/\<\!\-\- $key \-\-\>//;
      }
    }
  }

  return join( '', @line );
}

sub DefaultViewMarkdown()
{
  my ( $sonidori, $file, $text, $title ) = ( @_, '', '', '' );
  my %data;

  $data{ 'htmltemplate' } = $sonidori->{ 'SYSTEM' }{ 'HTML_TEMPLATE' }{ $sonidori->{ 'ENV' }{ 'dev' } };
  $data{ 'article' } = $text;
  $data{ 'title' } = $title;

  my $html = $sonidori->LoadTemplateHtml( %data );

  return $sonidori->PluginParse ( $html );
}

sub DefaultViewDirectory()
{
  my ( $sonidori, $base ) = ( @_, '', '' );
  my %data;

  my $text = "# Contents List\n";
  foreach ( &Common::DirectoryList( $base ) )
  {
    $text .= sprintf( '+ %s%s', $_, "\n" );
  }
  my $md = &Common::Markdown( $text );
  $data{ 'htmltemplate' } = $sonidori->{ 'SYSTEM' }{ 'HTML_TEMPLATE' }{ $sonidori->{ 'ENV' }{ 'dev' } };
  $data{ 'article' } = $md;

  my $html = $sonidori->LoadTemplateHtml( %data );

  return $sonidori->PluginParse ( $html );
}

# Address GET.

sub CreateGetData()
{
  my ( $sonidori ) = @_;

  my @get;
  foreach ( keys( %{ $sonidori->{ 'GDATA' } } ) )
  {
    push ( @get, sprintf( '%s=%s', $_, &Common::URLEncode( $sonidori->{ 'GDATA' }{ $_ } ) ) );
  }

  return join( '&', @get );
}

sub AddGetData()
{
  my ( $sonidori, $key, $value ) = ( @_, '', '' );

  if ( $key eq '' ){ return 1; }

  $sonidori->{ 'GDATA' }{ $key } = $value;

  return 0;
}

sub DeleteGetData()
{
  my ( $sonidori, $key ) = ( @_, '' );

  if ( $key eq '' || ! exists( $sonidori->{ 'GDATA' }{ $key } ) )
  {
    return 1;
  }

  delete( $sonidori->{ 'GDATA' }{ $key } );

  return 0;
}
