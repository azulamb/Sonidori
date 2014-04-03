package Decode;

use warnings;
use strict;
use utf8;

# Constructor
sub new()
{
  my ( $package ) = @_;
  my $hash = {};

  $hash->{ 'POST_MAX' } = 0;
  $hash->{ 'DELETE_FILES' } = [];
  $hash->{ 'BASE_FILE_NAME' } = '.tmp.' . $$;

  return bless( $hash, $package );
}

sub DESTROY()
{
  my ( $self ) = @_;
  $self->Release();
}

sub Release()
{
  my ( $self ) = @_;
  # Tmpfile delete.
  while ( scalar( @{ $self->{ 'DELETE_FILES' } } ) )
  {
    my $file = shift( @{ $self->{ 'DELETE_FILES' } } );
    if ( ref ( $file ) eq 'ARARY' )
    {
      foreach ( @{ $file } ){ if ( -f $_ ){ unlink( $_ ); } }
    } elsif ( -f $file ){ unlink( $file ); }
  }
}

sub Get
{
  my ( $self, @names ) = @_;

  my $query = exists ( $ENV{ 'QUERY_STRING' } ) ? $ENV{ 'QUERY_STRING' } : '';

  my %ret = &Decode::Common( $query  );

  foreach ( @names )
  {
    unless ( exists ( $ret{ $_ } ) )
    {
      $ret{ $_ } = '';
    }
  }

  return \%ret;
}

sub Post
{
  my ( $self, @names ) = @_;

  my $query = '';
  my %ret;

  if ( exists ( $ENV{ 'CONTENT_LENGTH' } ) )
  {
    if ( $self->{ 'POST_MAX' } > 0 && $ENV{ 'CONTENT_LENGTH' } > $self->{ 'POST_MAX' } )
    {
      $ret{ '__ERROR' } = sprintf( 'CONTENT_LENGTH(%d) is size(%d) over.', $ENV{ 'CONTENT_LENGTH' }, $self->{ 'POST_MAX' } );
    } else
    {
      $query = <STDIN>;
      if ( $query =~ /\=/ )
      {
        %ret = &Decode::Common( $query );
      } else
      {
        # Multipart.
        %ret = $self->PostMultipart( $query );
      }
    }
  }

  foreach ( @names )
  {
    unless ( exists ( $ret{ $_ } ) )
    {
      $ret{ $_ } = '';
    }
  }

  return \%ret;
}

# If enctype="multipart/form-data"
# GET DATA(sample)
# ------WebKitFormBoundaryoqfoScRJ36ICu1Y3
# Content-Disposition: form-data; name="fileName"; filename="index.html.txt"
# Content-Type: text/plain
# 
# upload text file
# :
# 
# ------WebKitFormBoundaryoqfoScRJ36ICu1Y3
# Content-Disposition: form-data; name="submit"
# 
# form data
# ------WebKitFormBoundaryoqfoScRJ36ICu1Y3--

# Multipart data structure

# FILE PART
# --...--XXXX....XXX  <= split line.
# Content-Disposition: form-data; name="FORM NAME"; filename="FILE NAME" <= Form data.
# <= Empty newline.
# Upload file data.
# 

# DATA PART
# --...--XXXX....XXX  <= split line.
# Content-Disposition: form-data; name="FORM NAME";
# <= Empty newline.
# Data

# END PART
# --...--XXXX....XXX--  <= end line.

# FILE PART & DATA PART ... ENDPART

sub PostMultipart()
{
  my ( $self, $split ) = ( @_, '' );
  my $read = 0;

  my %ret;

  if ( $split eq '' )
  {
    $split = <STDIN>;
  }
  $split =~ s/[\r\n]//g;

  my $mode;
  my $key;
  my $FHANDLE;
  my $filename = '';

  my $line = $split;
  while ( 1 )
  {
    if ( $line =~ /^($split)/ )
    {
      # New part.
      $mode = 'HEADER';
      $key = '_';
      if ( $filename ne '' )
      {
        close( $FHANDLE );
        $filename = '';
      }
    } elsif( $mode eq 'HEADER' )
    {
      # Header.
      $line =~ s/[\r\n]//g;
      if ( $line eq '' ){ $mode = ''; }
      if ( $line =~ /Content-Disposition:/i )
      {
        # Form data.
        my ( $head, $name, $file ) = ( split( /\;/, $line ), '' );
        $name =~ /\"(.+)\"/;
        $key = $1;

        if ( $file ne '' )
        {
          # Prepare file upload.

          # Create filepath.
          $file =~ s/[^ \w\d\.]//g;
          $filename = $self->{ 'BASE_FILE_NAME' } . $file;

          unless ( exists( $ret{ $key } ) )
          {
            $ret{ $key } = $filename;
          } else
          {
            # Array value.
            unless ( ref ( $ret{ $key } ) eq 'ARARY' )
            {
              my $tmp = $ret{ $key };
              delete ( $ret{ $key } );
              $ret{ $key }[ 0 ] = $tmp;
            }
            push ( @{ $ret{ $key } }, $filename );
          }

          # Add auto delete file list.
          push( @{ $self->{ 'DELETE_FILES' } }, $filename );

          open( FILE, ">> $filename" );
          $FHANDLE = *FILE;
        }
      }
    } else
    {
      # Data.
      if ( $filename ne '' )
      {
        print $FHANDLE $line;
      } else
      {
        my $data = '';
        until ( $line =~ /^($split)/ )
        {
          $data .= $line;
          $line = <STDIN>;
        }

        unless ( exists( $ret{ $key } ) )
        {
          # Value.
          $ret{ $key } = $data;
        } else
        {
          # Array value.
          unless ( ref ( $ret{ $key } ) eq 'ARARY' )
          {
            my $tmp = $ret{ $key };
            delete ( $ret{ $key } );
            $ret{ $key }[ 0 ] = $tmp;
          }
          push ( @{ $ret{ $key } }, $data );
        }

        next;
      }
    }

    $line = <STDIN>;
  }

  return %ret;
}

sub GetCookie()
{
  my ( $cookie_name, @names ) = @_;

  my $cookie = exists ( $ENV{ 'HTTP_COOKIE' } ) ? $ENV{ 'HTTP_COOKIE' } : '';

  my @cookies = split( /;/, $cookie );

  my $query = '';

  foreach ( @cookies )
  {
    my ( $key, $value ) = split( /\=/, $_, 2 );
    if ( $key eq $cookie_name ){ $query = $value; }
  }

  my %ret = &Decode::Common( $query );

  foreach ( @names )
  {
    unless ( exists ( $ret{ $_ } ) )
    {
      $ret{ $_ } = '';
    }
  }

  return \%ret;
}

sub Common( \$ )
{
  my @args = split( /&/, $_[0] );
  my %ret;
  foreach ( @args )
  {
    my ( $name, $val ) = split( /=/, $_, 2 );
    $val =~ tr/+/ /;
    $val =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack('C', hex($1))/eg;
    unless ( exists ( $ret{ $name } ) )
    {
      $ret{ $name } = $val;
    } else
    {
      unless ( ref ( $ret{ $name } ) =~ /^ARRAY/ )
      {
        my $tmp = $ret{ $name };
        delete ( $ret{ $name } );
        $ret{ $name }[ 0 ] = $tmp;
      }
      push ( @{ $ret{$name} }, $val );
    }
  }

  return %ret;
}

1;
