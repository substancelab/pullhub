# Pullhub

## Run app

```sh
brew install elixir
mix local.hex
mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

mix deps.get
mix ecto.create && mix.ecto migrate

npm install

mix phoenix.server`
```


## Deployment

```sh
git push heroku
```

## Setup production heroku server

```sh
# Create a Heroku instance for your project
heroku apps:create my_heroku_app

# Set and add the buildpacks for your Heroku app
heroku buildpacks:set https://github.com/HashNuke/heroku-buildpack-elixir
heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static
heroku buildpacks:add https://github.com/heroku/heroku-buildpack-ruby

# Deploy
git push heroku master
```
