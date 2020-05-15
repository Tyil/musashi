#! /usr/bin/env false

use v6.d;

use Config;
use IO::Path::XDG;
use IRC::Client;
use IRC::Client::Plugin::DiceRolls;
use IRC::Client::Plugin::NickServ;
use Log;
use Log::Level;

unit module Local::Musashi;

# Set up logger
my $*LOG = (require ::(%*ENV<RAKU_LOG_CLASS> // 'Log::Colored')).new;
$*LOG.add-output($*ERR, %*ENV<RAKU_LOG_LEVEL> // Log::Level::Info);

#| Run the musashi IRC bot.
sub MAIN () is export
{
	my IRC::Client $bot;

	# Play nice with Kubernetes
	$*ERR.out-buffer = False;
	$*OUT.out-buffer = False;

	signal(SIGTERM).tap({ .quit with $bot });

	# Load config
	my IO::Path $config-file = xdg-config-dirs()
		.map(*.add('musashi.toml'))
		.grep(*.f)
		.first
		;

	die "Missing configuration file: $config-file.absolute()." unless $config-file;

	my Config $config = Config.new.read($config-file.absolute);

	# Initialization
	$bot .= new(
		:nick($config.get("irc.nickname", "musashi"))
		:username($config.get("irc.username", "musashi"))
		:realuser($config.get("irc.realname", "Yet another tachikoma AI"))
		:host($config.get("irc.host", "irc.darenet.org"))
		:port($config.get("irc.port", 6667))
		:ssl($config.get("irc.ssl", False))
		:channels($config.get("irc.channels", "#scriptkitties"))
		:debug($config.get("debug", True))
		:!autoprefix
		:plugins(
			IRC::Client::Plugin::NickServ.new(:$config),
			IRC::Client::Plugin::DiceRolls.new(:$config),
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

	# Start
	$bot.run;
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
