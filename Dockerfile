FROM elixir:latest

RUN mix local.hex --force \
    && mix archive.install --force hex phx_new \
    && apt-get update \
    && curl -sL https://deb.nodesource.com/setup_lts.x | bash \
    && apt-get install -y apt-utils \
    && apt-get install -y nodejs \
    && apt-get install -y build-essential \
    && apt-get install -y inotify-tools \
    && mix local.rebar --force

RUN mkdir /app
WORKDIR /app

EXPOSE 4000

CMD ["mix"]

