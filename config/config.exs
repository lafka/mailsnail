use Mix.Config

config :mailsnail,
  aliases: [ ],
  metrics: nil

config :toniq, redis_url: "redis://[fd00::1:efa5:d5fb]:6379/0"
config :email, adapter: :mock

import_config "#{Mix.env}.exs"
