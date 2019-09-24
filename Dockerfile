FROM registry.gitlab.com/tyil/docker-perl6:debian-dev-latest

RUN apt update
RUN apt -y install libssl-dev

WORKDIR /app

COPY META6.json .
COPY bin bin
COPY lib lib

ENV PERL6LIB=/app/lib

RUN zef install --deps-only --/test .
RUN perl6 -c bin/musashi

CMD [ "bin/musashi" ]
