use Mix.Config

config :mailsnail,
  aliases: [ ],
  metrics: nil

#config :toniq, redis_url: nil
#config :toniq, redis_connection: {:poolboy, :transaction, [:redis]}
config :email, adapter: :mock

import_config "#{Mix.env}.exs"
