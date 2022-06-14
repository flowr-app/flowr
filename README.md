# Flowr

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Development

### Local development

#### Prerequisites

- Install [asdf](https://asdf-vm.com)
- Install [PostgreSQL](https://www.postgresql.org)

#### Setup tne development environment

1. Run `$ asdf install` to install Elixir, Erlang and Node.js.
2. Run `$ mix deps.get` to install dependencies.
3. Run `$ mix ecto.setup` to bootstrap your database.
4. Run `$ npm install ` to install Node.js dependencies.
5. Start Phoenix endpoint with `$ mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Development in Dev Container

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Install [VSCode](https://code.visualstudio.com) and [Remote Container extension](https://github.com/Microsoft/vscode-remote-release)
3. Run the DevContainer in VSCode

## Deployment

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
