#! /usr/bin/env perl6

use v6.c;

use Config;
use IRC::Client;
use Musashi::Social;

my Str @config-locations = [
	"/etc/musashi.toml",
	"/usr/local/etc/musashi.toml",
	"%*ENV<XDG_CONFIG_HOME>/musashi.toml",
	"%*ENV<HOME>/.config/musashi.toml",
];

my Str $pidfile;

signal(SIGINT).tap: {
	cleanup-pidfile;
	exit;
};

sub MAIN
{
	# Load config
	my Config $config = Config.new;

	if (!$config.read(@config-locations, :skip-not-found)) {
		say "No usable config files supplied in any of the scanned locations:";

		for @config-locations {
			say "  $_";
		}

		die;
	}

	# Check pidfile
	$pidfile = $config.get("pidfile", "/dev/null");

	if ($pidfile ne "/dev/null") {
		if ($pidfile.IO.e) {
			my Str $pid = slurp $pidfile;

			say "Musashi is already running as $pid. If this is in error, remove";
			say "the pidfile at $pidfile";

			die;
		}

		# Write pidfile
		spurt $pidfile, $*PID;
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

	# Clean up
	cleanup-pidfile;
}

sub cleanup-pidfile()
{
	if ($pidfile eq "/dev/null") {
		return;
	}

	unlink $pidfile;
}
