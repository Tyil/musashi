# Musashi

Musashi is the channel bot for [Scriptkitties](http://scriptkitties.church/), a
community that can be found in `#scriptkitties` on
[Freenode](https://freenode.net/).

## Configuration

Before you can use the bot, you will need to write some configuration. Musashi
checks `$XDG_CONFIG_HOME/musashi.toml`. A basic configuration file to get you
started would be:

    debug = true

    [bot]
    nickname = "musashi"
    username = "musashi"

    [irc]
    host = "chat.freenode.net"
    port = 6697
    ssl  = true
    channels = [
      "#scriptkitties-musashi"
    ]

## Running the bot

There are multiple ways to run the bot. You can download the source and run it
directly from the repository, which is by far the most convenient when
developing. However, for running in production, you may prefer using the Docker
image.

### From the repository

To run Musashi straight from her repository, you will need to clone it, install
dependencies and then run the `musashi` program.

    cd -- "$(mktemp)"  # or just cd to any other directory
    git clone https://gitlab.com/skitties/musashi.git .

    zef install --deps-only .

    perl6 -Ilib bin/musashi

### From Docker

Every commit, a new Docker image is built through GitLab CI. These images can
be found in the related registry, `registry.gitlab.com/skitties/musashi`. Every
commit made to master will update the `latest` tag.

You will need to mount a configuration file into the Docker image to make the
bot work correctly.

    docker run -it \
      -v "$XDG_CONFIG_HOME/musashi.toml:/root/.config/musashi.toml" \
      registry.gitlab.com/skitties/musashi:latest

## License

This project is distributed under the terms of the GNU Affero General Public
License 3.0.
