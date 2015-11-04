use Mix.Config

Code.eval_file "./test/mailsnail_mock.exs"

config :email, adapter: :mailsnail_mock

config :mailsnail, aliases: [
  test: [
    html:    {:alias, :"test.html.eex"},
    text:    {:alias, :"test.text.eex"},
    subject: {:alias, :"test.subject.eex"},
  ],

  "test.html.eex":     {:path, Path.join([__DIR__, "..", "test", "templates", "test.html.eex"])},
  "test.text.eex":     {:path, Path.join([__DIR__, "..", "test", "templates", "test.text.eex"])},
  "test.subject.eex":  {:path, Path.join([__DIR__, "..", "test", "templates", "test.subject.eex"])}
]
