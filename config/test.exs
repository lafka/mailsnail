use Mix.Config

Code.eval_file "./test/mailsnail_mock.exs"

config :email, adapter: :mailsnail_mock
