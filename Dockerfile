FROM registry.gitlab.com/tyil/docker-perl6:debian-latest

RUN apt update
RUN apt -y install libssl-dev

COPY META6.json .
COPY bin bin
COPY lib lib

RUN zef install --deps-only .
RUN perl6 -c -Ilib bin/musashi

CMD perl6 -Ilib bin/musashi
