#! /usr/bin/false

use v6.c;

use IRC::Client;

unit class Local::Musashi::Social does IRC::Client::Plugin;

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
