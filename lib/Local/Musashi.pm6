#! /usr/bin/env false

use v6.d;

use Config;
use IO::Path::XDG;
use IRC::Client::Plugin::Ignore;
use IRC::Client::Plugin::NickServ;
use IRC::Client;

unit module Local::Musashi;

#| Run the musashi IRC bot.
sub MAIN () is export
{
	my IO::Path $musashi-toml = xdg-config-home.add("musashi.toml");
	die "Missing configuration file: $musashi-toml.absolute()." unless $musashi-toml.f;

	# Load config
	my Config $config = Config.new.read($musashi-toml.absolute);

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
		:!autoprefix
		:plugins(
			IRC::Client::Plugin::Ignore.new(:$config),
			IRC::Client::Plugin::NickServ.new(:$config),
			class {
				multi method irc-privmsg-channel($e where /^hi$/)
				{
					"Hi {$e.nick}!"
				}

				multi method irc-privmsg-channel($ where /^o\/$/)
				{
					"\\o"
				}

				multi method irc-privmsg-channel($e where /^[good]?morn[ing]?$/)
				{
					"And a good morning to you too, {$e.nick}"
				}

				multi method irc-privmsg-channel($e where /black/)
				{
					$e.text.subst("black", "african-american")
				}
			},
		)
	);
}

=begin pod

=NAME    Local::Musashi
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 0.0.1

=head1 Synopsis

=head1 Description

=head1 Examples

=head1 See also

=end pod

# vim: ft=perl6 noet
