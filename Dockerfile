# Etapa 1: Build
FROM elixir:1.18.4-otp-27-alpine AS build

RUN apk add --no-cache build-base git

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY . .
RUN mix deps.get --only prod
RUN mix deps.compile
RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix release

# Etapa 2: Runtime
FROM elixir:1.18.4-otp-27-alpine AS runtime

WORKDIR /app

# Dependências do Erlang/ERTS
RUN apk add --no-cache openssl ncurses-libs erlang

# Copia release do build stage
COPY --from=build /app/_build/prod/rel/hermes ./hermes

# Ajusta permissões
RUN chown -R nobody:nogroup /app
USER nobody

WORKDIR /app/hermes

CMD ["./bin/hermes", "start"]
