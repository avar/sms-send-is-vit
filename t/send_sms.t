use Test::More;
use SMS::Send;

my $number;

if ($number = $ENV{SMS_TO}) {
    plan tests => 1;
} else {
    plan skip_all => "Set SMS_TO to a valid Vit number to test sms sending";
}

my $sender = SMS::Send->new("IS::Vit");

my $ok = $sender->send_sms(
    to => $ENV{SMS_TO},
    text => $ENV{SMS_TEXT} || sprintf("SMS::Send::IS::Vit test message at %s", scalar localtime),
);

if ($ok) {
    pass "sent sms";
} else {
    fail "no sms sent";
}


