package blog::Install;

use warnings;
use strict;
use utf8;

sub Install()
{
  my ( $obj ) = @_;
  $obj->AddInlinePlugin( 'bloglist', 'blog::bloglist' );
  $obj->AddInlinePlugin( 'breadcrumbs_blog', 'blog::breadcrumbs_blog' );

}

1;
