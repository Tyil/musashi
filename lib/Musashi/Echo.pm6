#! /usr/bin/false

use v6.c;

use IRC::Client;

class Musashi::Echo does IRC::Client::Plugin
{
	method irc-to-me($e)
	{
		"You said {$e.text}"
	}
}
