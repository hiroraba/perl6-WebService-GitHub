use Test;
use WebServices::GitHub;
use WebServices::GitHub::Role::Debug;
use WebServices::GitHub::Role::CustomUserAgent;

my $gh = WebServices::GitHub.new();

$gh does WebServices::GitHub::Role::Debug;
$gh does WebServices::GitHub::Role::CustomUserAgent;
$gh.set-custom-useragent('perl6-WG-test/0.1');

my $res = $gh.request('/users/fayland');
my $ua = $res.raw.request.field('User-Agent');
is $ua, 'perl6-WG-test/0.1';

done-testing;