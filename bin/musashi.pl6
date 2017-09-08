#! /usr/bin/env perl6

use v6.c;

use Config;
use IRC::Client;
use Musashi::Social;

sub MAIN
{
	# Load config
	my Config $config = Config.new;

	my Str @config-locations = [
		"/etc/musashi.toml",
		"/usr/local/etc/musashi.toml",
		"%*ENV<XDG_CONFIG_HOME>/musashi.toml",
		"%*ENV<HOME>/.config/musashi.toml",
	];

	if (!$config.read(@config-locations, :skip-not-found)) {
		say "No usable config files supplied in any of the scanned locations:";

		for @config-locations {
			say "  $_";
		}

		die;
	}

	# Start bot
	.run with IRC::Client.new(
		:nick($config.get("bot.nickname", "musashi"))
		:username($config.get("bot.username", "musashi"))
		:realuser($config.get("bot.realname", "Yet another tachikoma AI"))
		:host($config.get("irc.host", "irc.darenet.org"))
		:port($config.get("irc.port", 6667))
		:ssl($config.get("irc.ssl", False))
		:channels($config.get("irc.channels", "#scriptkitties"))
		:debug($config.get("debug", True))
		:plugins(
			Musashi::Social.new
		)
	);
}
