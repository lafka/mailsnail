use Mix.Config

config :mailsnail,
  aliases: [
    "user-registration": [
      html:    :"user-registration.html",
      text:    :"user-registration.text",
      subject: :"user-registration.subject"
    ],

    "user-registration.html":    "./templates/user-registration.html.eex",
    "user-registration.text":    "./templates/user-registration.html.eex",
    "user-registration.subject": "./templates/user-registration.subject.eex",

    "forgot-password": [
      html:    :"forgot-password.html",
      text:    :"forgot-password.text",
      subject: :"forgot-password.subject"
    ],

    "forgot-password.html":    "./templates/forgot-password.html.eex",
    "forgot-password.text":    "./templates/forgot-password.html.eex",
    "forgot-password.subject": "./templates/forgot-password.subject.eex",
  ]

config :toniq, redis_url: "redis://[fd00::1:efa5:d5fb]:6379/0"
config :email, adapter: :mock

import_config "#{Mix.env}.exs"
