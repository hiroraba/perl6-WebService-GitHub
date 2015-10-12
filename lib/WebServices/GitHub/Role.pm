unit module WebServices::GitHub::Role;

use v6;

use URI;
use MIME::Base64;
use JSON::Tiny; # from-json
use HTTP::Request;
use HTTP::UserAgent;
use WebServices::GitHub::Response;

role WebServices::GitHub::Role {
    has $.endpoint = 'https://api.github.com';
    has $.access-token;
    has $.auth_login;
    has $.auth_password;

    has $.ua = HTTP::UserAgent.new;
    has $.useragent = 'perl6-WebService-GitHub/0.1.0';

    method request(Str $path, $method='GET', :$data) {
        state $ua;

        # 'GET', 'POST', 'PUT', 'PATCH', 'HEAD', 'DELETE'

        my $uri = URI.new($.endpoint ~ $path);
        if ($method eq 'GET' and $data) {
            $uri.query_form($data);
        }

        my $request = HTTP::Request.new;
        $request.set-method($method);
        $request.uri($uri);
        $request.header.field(User-Agent => $.useragent);
        $request.header.field(Accept => 'application/vnd.github.v3+json');

        if $.auth_login.defined && $.auth_password.defined {
            $request.header.field(
                Authorization => "Basic " ~ MIME::Base64.encode-str("{$.auth_login}:{$.auth_password}")
            );
        } elsif ($.access-token) {
            $request.header.field(
                Authorization => "token " ~ $.access-token
            );
        }

        if ($method ne 'GET' and $data) {
            $request.content(to-json($data));
        }

        $request.header.field(Content-Length => $request.content ?? $request.content.length !! 0);

        my $res = $.ua.request($request);
        return WebServices::GitHub::Response.new(raw => $res);
    }
}