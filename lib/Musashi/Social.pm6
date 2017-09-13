#! /usr/bin/false

use v6.c;

use IRC::Client;

class Musashi::Social does IRC::Client::Plugin
{
	multi method irc-privmsg-channel($e where /^hi$/)
	{
		$e.reply: "Hi {$e.nick}!"
	}

	multi method irc-privmsg-channel($e where /^o\/$/)
	{
		$e.reply: "\\o"
	}

	multi method irc-privmsg-channel($e where /^[good]?morn[ing]?$/)
	{
		$e.reply: "And a good morning to you too, {$e.nick}"
	}
}
