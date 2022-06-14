ARG MIX_ENV="prod"

# --- build ---
FROM hexpm/elixir:1.13.4-erlang-25.0.1-alpine-3.16.0 as build

# install build dependencies
RUN apk add --no-cache build-base git python3 curl

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Dependencies sometimes use compile-time configuration. Copying
# these compile-time config files before we compile dependencies
# ensures that any relevant config changes will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/$MIX_ENV.exs config/
RUN mix deps.compile

# --- assets-build ---
FROM node:16.5.0 as assets-build

WORKDIR /app
COPY --from=build /app ./

COPY priv priv
COPY assets assets
RUN npm install --prefix ./assets

FROM build as build2

WORKDIR /app
COPY --from=assets-build /app ./

RUN mix assets.deploy

# compile and build the release
COPY lib lib
RUN mix compile
# changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix release

# --- app ---
# Start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM alpine:3.14.0 AS app
RUN apk add --no-cache libstdc++ openssl ncurses-libs

ARG MIX_ENV
ENV USER="elixir"

WORKDIR "/home/${USER}/app"
# Creates an unprivileged user to be used exclusively to run the Phoenix app
RUN \
  addgroup \
  -g 1000 \
  -S "${USER}" \
  && adduser \
  -s /bin/sh \
  -u 1000 \
  -G "${USER}" \
  -h /home/elixir \
  -D "${USER}" \
  && su "${USER}"

# Everything from this line onwards will run in the context of the unprivileged user.
USER "${USER}"

COPY --from=build2 --chown="elixir":"elixir" /app/_build/"${MIX_ENV}"/rel/flowr ./

ENTRYPOINT ["bin/flowr"]

# Usage:
#  * build: sudo docker image build -t elixir/flowr .
#  * shell: sudo docker container run --rm -it --entrypoint "" -p 127.0.0.1:4000:4000 elixir/flowr sh
#  * run:   sudo docker container run --rm -it -p 127.0.0.1:4000:4000 --name my_app elixir/flowr
#  * exec:  sudo docker container exec -it flowr sh
#  * logs:  sudo docker container logs --follow --tail 100 flowr
CMD ["start"]
