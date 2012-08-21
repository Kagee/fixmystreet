package FixMyStreet::Cobrand::hild1;
use base 'FixMyStreet::Cobrand::Default';
use utf8;
use strict;
use warnings;

#use Carp;
use mySociety::MaPit;
use FixMyStreet::Geocode::OSM;

sub country { return 'NO'; }
sub set_lang_and_domain {
    my ( $self, $lang, $unicode, $dir ) = @_;
    my $set_lang = mySociety::Locale::negotiate_language( 'en-gb,English,en_GB|nb,Norwegian,nb_NO', 'nb' );
    mySociety::Locale::gettext_domain( 'FixMyStreet', $unicode, $dir );
    mySociety::Locale::change();
    return $set_lang;
}
sub site_title { my ($self) = @_; return 'hild1'; }
sub get_council_sender { return 'E-post' };

sub example_places {
    return [ '2815', 'Bakkegata, Gjøvik' ];
}
sub enter_postcode_text { _('Tast inn et postnummer eller gatenavn og tettsted') }

sub area_types {
 return ( 'ICO' );

#    return ( 'NKO', 'NFY', 'NRA' );
}

sub geocode_postcode {
    my ( $self, $s ) = @_;

    if ($s =~ /^\d{4}$/) {
        my $location = mySociety::MaPit::call('postcode', $s);
        if ($location->{error}) {
            return {
                error => $location->{code} =~ /^4/
                    ? _('That postcode was not recognised, sorry.')
                    : $location->{error}
            };
        }
        return {
            latitude  => $location->{wgs84_lat},
            longitude => $location->{wgs84_lon},
        };
    }
    return {};
}

sub find_closest {
    my ( $self, $latitude, $longitude ) = @_;
    return FixMyStreet::Geocode::OSM::closest_road_text( $self, $latitude, $longitude );
}

1;
