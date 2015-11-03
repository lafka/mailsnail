# Mailsnail

Provides a extremely simple mechanism to offload emails to a remote service.

## Requirements

 * Redis server, as defined in `config/config.exs`
 * Mailgun credentials, as defined in `config/config.exs`


## Usage

```
# As genserver call

:ok = GenServer.call Mailsnail, {:send, %{
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
	html: "There are <%= length(ducks) %> here",
	doc: [ducks: []]
}

## And stored templates even

Mailsnail.send %{
	....
	template: [html: "./tpl/duck-counter.html.eex",
						 text: "./tpl/duck-counter.plain.eex",
						 subject: aFunctionOrFile],
	doc: [ducks: []]
}
```
