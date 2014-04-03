package Template;

use warnings;
use strict;

sub MarkDown()
{
  my ( $sonidori, @args ) = @_;

  $sonidori->{ 'SYSTEM' }{ 'HTML_TEMPLATE' } =
  {
    'PC'            => '../sonidori/template/template_blog.html',
    'Android'       => '../sonidori/template/template_blog.html',
    'AndroidMobile' => '../sonidori/template/template_blog.html',
    'iPhone'        => '../sonidori/template/template_blog.html',
    'WindowsPhone'  => '../sonidori/template/template_blog.html',
  };

  return $sonidori->DefaultViewMarkdown( @args );
}

sub Directory()
{
  my ( $sonidori, @args ) = @_;

  $sonidori->{ 'SYSTEM' }{ 'HTML_TEMPLATE' } =
  {
    'PC'            => '../sonidori/template/template_blog.html',
    'Android'       => '../sonidori/template/template_blog.html',
    'AndroidMobile' => '../sonidori/template/template_blog.html',
    'iPhone'        => '../sonidori/template/template_blog.html',
    'WindowsPhone'  => '../sonidori/template/template_blog.html',
  };

  return $sonidori->DefaultViewDirectory( @args );
}

1;
