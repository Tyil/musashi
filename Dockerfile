FROM registry.gitlab.com/tyil/docker-perl6:debian-dev-latest

RUN apt update
RUN apt -y install libssl-dev

WORKDIR /app

COPY META6.json .
COPY bin bin
COPY lib lib

ENV PERL6LIB="/app/lib"
ENV RAKU_LOG_CLASS="Log::JSON"

RUN zef install --deps-only --/test .
RUN zef install Log::JSON
RUN raku -c bin/musashi

CMD [ "bin/musashi" ]
