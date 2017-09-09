#! /usr/bin/false

use v6.c;

use Bailador;
use IRC::Client;
use JSON::Fast;

class Musashi::Github does IRC::Client::Plugin
{
	has $.config;

	method irc-connected ($)
	{
		Thread.start({
			post "/" => sub {
				my %body = from-json(request.body);
				my $user = "tyil";
				my $commits = %body<size>;
				my $branch = "master";
				my $old = %body<before>;
				my $new = %body<head>;

				$.irc.send(
					:where("#scriptkitties")
					:text("$user pushed $commits new commits to $branch ($old..$new)")
					:notice
				);
			}

			baile($!config.get("github.endpoint.port", 8000));
		});
	}
}
