# Mailsnail

Provides a extremely simple mechanism to offload emails to a remote service.

## Requirements

 * Redis server, as defined in `config/config.exs`
 * Mailgun credentials, as defined in `config/config.exs`


## Usage

```
# As genserver call

:ok = GenServer.call Mailsnail.Server, {:send, %{
	to: "test@mail.co",
	from: {"mail@company.co", "Company Name"},
	subject: "I Like ducks!",
	html: "Heres a <img href=\"of-duck\" />",
	text: "No ducks here"
}}

# As library call

Mailsnail.send %{
	to: "test@mail.co",
	from: {"mail@company.co", "Company Name"},
	subject: "I Like ducks!",
	html: "Heres a <img href=\"of-duck\" />",
	text: "No ducks here"
}

## With substitution support

Mailsnail.send %{
	....
	html: {:string, "There are <%= length(dock.ducks) %> here"},
	doc: [ducks: []]
}

## And some other varians

Mailsnail.send %{
	....
	template: [html: {:path, "./tpl/duck-counter.html.eex"},
	           text: {:alias, :duckcounter}, # stored in config
	           subject: fn(%Msg{doc: doc}) -> "#{length(doc[:ducks])} ducks!" end],
	doc: [ducks: []]
}
```


## Add some metrics!

```
logmetrics = fn
	(%Msg{template: {:alias, a}}, status) ->
		 :influx_udp.write "mails",
			 %{"type" => a},
			 %{"host" => node, "status" => status}
	(%Msg{}, status) ->
		 :influx_udp.write "mails",
			 %{"type" => "custom"},
			 %{"host" => node, "status" => status}
end

...
config :mailsnail, metrics: logmetrics
...
```
