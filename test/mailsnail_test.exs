defmodule MailsnailTest do
  use ExUnit.Case
  doctest Mailsnail

  test "send email" do
    Toniq.JobEvent.subscribe

    job = Mailsnail.send %{
      to: to = "test@client.com",
      from: from = "test@provider.com",
      subject: subject = "Hello",
      html: html = "html",
      text: text = "plain"
    }

    receive do
      {:finished, ^job}  -> :ok
    after
      5000 -> throw :timeout
    end

    Toniq.JobEvent.unsubscribe

    last = :email_adapter_mailsnail_mock.last()
    assert last[:to] == {to, to}
    assert last[:from] == {from, from}
    assert last[:subject] == subject
    assert last[:message] == [{"html", html}, {"text", text}]
  end

  test "send email (genserver)" do
    Toniq.JobEvent.subscribe

    job = GenServer.call Mailsnail.Server, {:send, %{
      to: to = "test@client.com",
      from: from = "test@provider.com",
      subject: subject = "Hello",
      html: html = "html",
      text: text = "plain"
    }}

    receive do
      {:finished, ^job}  -> :ok
    after
      5000 -> throw :timeout
    end

    Toniq.JobEvent.unsubscribe

    last = :email_adapter_mailsnail_mock.last()
    assert last[:to] == {to, to}
    assert last[:from] == {from, from}
    assert last[:subject] == subject
    assert last[:message] == [{"html", html}, {"text", text}]
  end
end
