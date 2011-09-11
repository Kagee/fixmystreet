package FixMyStreet::App::View::Web;
use base 'Catalyst::View::TT';

use strict;
use warnings;

use mySociety::Locale;
use mySociety::Web qw(ent);
use FixMyStreet;
use CrossSell;
use Utils;

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.html',
    INCLUDE_PATH       => [          #
        FixMyStreet->path_to( 'templates', 'web', 'default' ),
    ],
    ENCODING       => 'utf8',
    render_die     => 1,
    expose_methods => [
        'loc', 'nget', 'tprintf', 'display_crosssell_advert', 'prettify_epoch',
        'add_links', 'version',
    ],
    FILTERS => {
        escape_js => \&escape_js,
        html      => \&html_filter,
    },
# Disable the compile cache until we figure out where to store these
# on fiksgatami.no
#    COMPILE_EXT => '.ttc',
    STAT_TTL    => FixMyStreet->config('STAGING_SITE') ? 1 : 86400,
);

=head1 NAME

FixMyStreet::App::View::Web - TT View for FixMyStreet::App

=head1 DESCRIPTION

TT View for FixMyStreet::App.

=cut

=head2 loc

    [% loc('Some text to localize') %]

Passes the text to the localisation engine for translations.

=cut

sub loc {
    my ( $self, $c, @args ) = @_;
    return _(@args);
}

=head2 nget

    [% nget( 'singular', 'plural', $number ) %]

Use first or second srting depending on the number.

=cut

sub nget {
    my ( $self, $c, @args ) = @_;
    return mySociety::Locale::nget(@args);
}

=head2 tprintf

    [% tprintf( 'foo %s bar', 'insert' ) %]

sprintf (different name to avoid clash)

=cut

sub tprintf {
    my ( $self, $c, $format, @args ) = @_;
    return sprintf $format, @args;
}

=head2 display_crosssell_advert

    [% display_crosssell_advert( email, name ) %]

Displays a crosssell advert if permitted by the cobrand.

=cut

sub display_crosssell_advert {
    my ( $self, $c, $email, $name, %data ) = @_;

    return unless $c->cobrand->allow_crosssell_adverts();
    return CrossSell::display_advert( $c, $email, $name, %data );
}

=head2 Utils::prettify_epoch

    [% pretty = prettify_epoch( $epoch, $short_bool ) %]

Return a pretty version of the epoch.

    $short_bool = 1;     # 16:02, 29 Mar 2011
    $short_bool = 0;     # 16:02, Tuesday 29 March 2011

=cut

sub prettify_epoch {
    my ( $self, $c, $epoch, $short_bool ) = @_;
    return Utils::prettify_epoch( $epoch, $short_bool );
}

=head2 add_links

    [% add_links( text ) | html_para %]

Add some links to some text (and thus HTML-escapes the other text.

=cut

sub add_links {
    my ( $self, $c, $text ) = @_;

    $text =~ s/\r//g;
    $text = ent($text);
    $text =~ s{(https?://[^\s]+)}{<a href="$1">$1</a>}g;
    return $text;
}

=head2 escape_js

Used to escape strings that are going to be put inside JavaScript.

=cut

sub escape_js {
    my $text = shift;
    my %lookup = (
        '\\' => 'u005c',
        '"'  => 'u0022',
        "'"  => 'u0027',
        '<'  => 'u003c',
        '>'  => 'u003e',
    );
    $text =~ s/([\\"'<>])/\\$lookup{$1}/g;
    return $text;
}

=head2 html_filter

Same as Template Toolkit's html_filter, but escapes ' too, as we don't (and
shouldn't have to) know whether we'll be used inbetween single or double
quotes.

=cut

sub html_filter {
    my $text = shift;
    for ($text) {
        s/&/&amp;/g;
        s/</&lt;/g;
        s/>/&gt;/g;
        s/"/&quot;/g;
        s/'/&#39;/g;
    }
    return $text;
}

my %version_hash;
sub version {
    my ( $self, $c, $file ) = @_;
    unless ($version_hash{$file}) {
        my $path = FixMyStreet->path_to('web', $file);
        $version_hash{$file} = ( stat( $path ) )[9];
    }
    return "$file?$version_hash{$file}";
}

1;

