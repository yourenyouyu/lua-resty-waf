use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

my $pwd = cwd();

our $HttpConfig = qq{
	lua_package_path "$pwd/lib/?.lua;;";
	lua_package_cpath "$pwd/lib/?.lua;;";
};

repeat_each(3);
plan tests => repeat_each() * 3 * blocks() ;

no_shuffle();
run_tests();

__DATA__

=== TEST 1: URI_ARGS collections variable (single element)
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		content_by_lua_block {
			local collections = ngx.ctx.lua_resty_waf.collections

			ngx.say(collections.URI_ARGS["foo"])
		}
	}
--- request
GET /t?foo=bar
--- error_code: 200
--- response_body
bar
--- no_error_log
[error]

=== TEST 2: URI_ARGS collections variable (multiple elements)
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		content_by_lua_block {
			local collections = ngx.ctx.lua_resty_waf.collections

			ngx.say(collections.URI_ARGS["foo"])
		}
	}
--- request
GET /t?foo=bar&foo=baz
--- error_code: 200
--- response_body
barbaz
--- no_error_log
[error]

=== TEST 3: URI_ARGS collections variable (non-existent element)
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		content_by_lua_block {
			local collections = ngx.ctx.lua_resty_waf.collections

			ngx.say(collections.URI_ARGS["foo"])
		}
	}
--- request
GET /t?frob=qux
--- error_code: 200
--- response_body
nil
--- no_error_log
[error]

=== TEST 4: URI_ARGS collections variable (type verification)
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		content_by_lua_block {
			local collections = ngx.ctx.lua_resty_waf.collections

			ngx.say(type(collections.URI_ARGS))
		}
	}
--- request
GET /t
--- error_code: 200
--- response_body
table
--- no_error_log
[error]

