#! /usr/bin/false

use v6.c;

use IRC::Client;
use JSON::Fast;

class Musashi::Github does IRC::Client::Plugin
{
	has $.config;

	method irc-connected ($)
	{
		start {
			use Bailador;

			post "/" => sub {
				my %body = from-json(request.body);
				my $user = %body<pusher><name>;
				my $commits = %body<commits>.elems;
				my $repo = %body<repository><name>;
				my $branch = %body<ref>.Str.subst("refs/heads", "");
				my $old = %body<before>.Str.substr(0, 7);
				my $new = %body<after>.Str.substr(0, 7);
				my $commitString = "commit";

				if ($commits != 1) {
					$commitString ~= "s";
				}

				$.irc.send(
					:where("#scriptkitties")
					:text("$user pushed $commits new $commitString to {$repo}{$branch} ($old..$new)")
					:notice
				);

				"";
			}

			# Set the Bailador config
			set("host", $!config.get("github.webhook.host", "0.0.0.0"));
			set("port", $!config.get("github.webhook.port", 8000));

			# Start up Bailador
			baile;
		};
	}
}
