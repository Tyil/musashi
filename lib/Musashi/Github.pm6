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
				my $branch = %body<ref>.subst("refs/head", "");
				my $old = %body<before>.substr(0, 7);
				my $new = %body<head>.substr(0, 7);

				$.irc.send(
					:where("#scriptkitties")
					:text("$user pushed $commits new commits to $repo/$branch ($old..$new)")
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
