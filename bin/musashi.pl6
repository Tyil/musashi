#! /usr/bin/env perl6

use v6.c;

use Config;
use IRC::Client;
use Musashi::Social;

sub MAIN
{
	say "Starting musashi";

	# Load config
	my $config = Config.new();

	my $config-read = $config.read([
		"/etc/musashic.toml",
		"/usr/local/etc/musashi.toml",
		"%*ENV<XDG_CONFIG_HOME>/musashi.toml",
		"%*ENV<HOME>/.config/musashi.toml"
	], :skip-not-found);

	if (!$config-read) {
		die "No usable config files supplied";
	}

	# Start bot
	.run with IRC::Client.new(
		:nick($config.get("bot.nickname", "musashi"))
		:username($config.get("bot.username", "musashi"))
		:realuser($config.get("bot.realname", "Yet another tachikoma AI"))
		:host($config.get("irc.host", "irc.darenet.org"))
		:channels($config.get("irc.channels", "#scriptkitties"))
		:debug($config.get("debug", True))
		:plugins(
			Musashi::Social.new
		)
	);
}
