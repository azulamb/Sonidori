package base::Install;

use warnings;
use strict;
use utf8;

sub Install()
{
  my ( $obj ) = @_;
  $obj->AddInlinePlugin( 'dirlink', 'base::dirlink' );
  $obj->AddInlinePlugin( 'img', 'base::img' );
  $obj->AddInlinePlugin( 'breadcrumbs', 'base::breadcrumbs' );

}

1;
