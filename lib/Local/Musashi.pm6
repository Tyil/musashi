#! /usr/bin/env false

use v6.d;

use Config;
use IO::Glob;
use IO::Path::XDG;
use IRC::Client;
use IRC::Client::Plugin::DiceRolls;
use IRC::Client::Plugin::NickServ;
use Log;
use Log::Level;

unit module Local::Musashi;

#| Run the musashi IRC bot.
unit sub MAIN (
) is export {
	# Set up logger
	my $*LOG;

	if (%*ENV<RAKU_LOG_CLASS>:exists) {
		$*LOG = (require ::(%*ENV<RAKU_LOG_CLASS>)).new;
		$*LOG.add-output($*OUT, %*ENV<RAKU_LOG_LEVEL> // Log::Level::Info);
	}

	# Create $bot early to use it in traps
	my IRC::Client $bot;

	# Play nice with Kubernetes
	$*ERR.out-buffer = False;
	$*OUT.out-buffer = False;

	# Trap signals
	signal(SIGTERM).tap({ .quit with $bot });

	# Load config
	my IO::Path $config-file = xdg-config-dirs()
		.map(*.add('musashi.toml'))
		.grep(*.f)
		.first
		;

	die "Missing configuration file: $config-file.absolute()." unless $config-file;

	my $*CONFIG = Config.new.read($config-file.absolute);

	if (!$*CONFIG.get('irc.opers')) {
		.warning('No opers defined in irc.opers') with $*LOG;
	}

	# Set up database connection
	my $*DB;

	given ($*CONFIG.get('database.driver', '').fc) {
		when 'postgresql' {
			require DB::Pg;

			my $conninfo = %(
				host => $*CONFIG.get('database.host', 'localhost'),
				dbname => $*CONFIG.get('database.database', 'musashi'),
				user => $*CONFIG.get('database.user', ~$*USER),
				password => $*CONFIG.get('database.password'),
				port => $*CONFIG.get('database.port', 5432),
			).pairs.grep(*.value).map({ "{$_.key}={$_.value}" }).join(' ');

			.info("Using Postgres database ($conninfo)") with $*LOG;

			$*DB = DB::Pg.new(:$conninfo);
		}
		default {
			.warning("Invalid database driver") with $*LOG;
		}
	}

	# Prepare plugins
	my @plugins = (
		IRC::Client::Plugin::NickServ.new(config => $*CONFIG),
		IRC::Client::Plugin::DiceRolls.new(config => $*CONFIG),

		# Musashi-specific behaviour
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

			#| Allow reloading configuration while the bot is
			#| running.
			multi method irc-to-me (
				$event where 'reload',
			) {
				if (!self!is-oper($event.usermask)) {
					return "I'm sorry, I can't let you do that";
				}

				.info('Reloading configuration') with $*LOG;
				$*CONFIG.=read($config-file.absolute);

				for @plugins -> $plugin {
					next unless $plugin.^can('reload-config');

					.info("Reloading plugin $plugin") with $*LOG;
					$plugin.reload-config($*CONFIG);
				}

				'Reloaded configuration!';
			}

			#| Check if a usermask has oper privileges for the bot.
			method !is-oper (
				Str() $usermask,
				--> Bool:D
			) {
				for $*CONFIG.get('irc.opers', []).List -> $oper {
					return True if $usermask ~~ glob($oper);
				}

				False;
			}
		},
	);

	# Set up the bot
	$bot .= new(
		:nick($*CONFIG.get("irc.nickname", "musashi"))
		:username($*CONFIG.get("irc.username", "musashi"))
		:realuser($*CONFIG.get("irc.realname", "Yet another tachikoma AI"))
		:host($*CONFIG.get("irc.host", "irc.darenet.org"))
		:port($*CONFIG.get("irc.port", 6667))
		:ssl($*CONFIG.get("irc.ssl", False))
		:channels($*CONFIG.get("irc.channels", "#scriptkitties"))
		:debug($*CONFIG.get("debug", True))
		:!autoprefix
		:@plugins
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
