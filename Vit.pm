package SMS::Send::IS::Vit;
use strict;

use SMS::Send::Driver ();
use LWP::UserAgent ();
use HTTP::Cookies ();

our $VERSION = '0.02';

our @ISA = 'SMS::Send::Driver';

sub new
{
    my ($pkg) = @_;

    my $ua = LWP::UserAgent->new(
        agent      => sprintf("%s/%s", __PACKAGE__, $VERSION),
        cookie_jar => {},
    );

    my %self = (
        ua => $ua,
        extra => undef,
    );

    bless \%self => $pkg;
}

# private sub to parse the "extra" form data from a html string
my $parse_extra = sub
{
    my ($content) = @_;
    my $extra;

    # Try to parse it with TreeBuilder
    eval {
        require HTML::TreeBuilder;

        my $tree = HTML::TreeBuilder->new_from_content($content);

        $extra = $tree->look_down(
            _tag => 'input',
            name => 'extra',
        )->attr('value');
    };

    # Yay
    return $extra if $extra;

    # Fall back on parsing it with a regex
    ($extra) = $content =~ /
        <input .*? value="([0-9]+)" \s* name="extra">
    /x;

    return $extra;
};

sub send_sms
{
    my ($self, %arg) = @_;
    my ($ua, $extra) = @$self{qw(ua extra)};

    my $uri = 'http://vit.is/spsms/servlet/com.trackwell.vas.spsms.Sender';

    # Input longer than 100 chars will fail anyway
    if (length $arg{text} > 100) {
        require Carp;
        Carp::croak("text length limit is 100 characters");
    }

    # Don't request a cookie from the main page if we have it cached
    unless ($ua->cookie_jar and $ua->cookie_jar->as_string) {
        my $res = $ua->get($uri);

        return unless $res->is_success;

        # Give them some time to recover from someone asking them for
        # a cookie
        sleep 1;

        $self->{extra} = $parse_extra->($res->content);
    }

    # We have a cookie and the extra data, query the script

    my $res = $ua->post($uri,
        Referer => $uri,
        Content => [
            txtSimanumer => $arg{to},
            txtSkilabod  => $arg{text},

            # They change this periodically
            extra => $self->{extra},
        ],
    );

    $res->is_success;
}



1;

__END__

=head1 NAME

SMS::Send::IS::Vit - SMS::Send driver for vit.is

=head1 SYNOPSIS

    use SMS::Send;

    my $sender = SMS::Send->new("IS::Vit");

    my $ok = $ender->send_sms(
        to   => '6811337',
        text => 'Y hlo thar',
    );

    if ($ok) {
        print "Yay SMS\n";
    } else {
        print "Oh noes failure\n";
    }

=head1 DESCRIPTION

A regional L<SMS::Send> driver for Iceland that deliers messages via
L<http://vit.is>. Vit only supports ending sms messages to
SE<iacute>minn users, see L<SMS::Send::IS::Vodafone> for sending SMS
to Vodafone users.

=head1 CAVEATS

This module will call C<sleep(1)> when it first retrieves a cookie
before it submits the sms. The vit.is server does not seem to
recognize a cookie it handed out until after a slight delay.

=head1 AUTHOR

E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason <avar@cpan.org>

=head1 LICENSE

Copyright 2007-2008 E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
