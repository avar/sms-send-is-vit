use Test::More tests => 1;
use SMS::Send;

my $sender = SMS::Send->new("IS::Vit");

eval {
    $sender->send_sms(
        to => '1234',
        text => join("", ("x" x 101)),
    );
};
like $@, qr/length limit/, "length limit is 100";
