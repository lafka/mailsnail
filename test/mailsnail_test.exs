defmodule MailsnailTest do
  use ExUnit.Case
  doctest Mailsnail

  setup_all do
    Toniq.JobPersistence.failed_jobs |> Enum.each &Toniq.JobPersistence.delete_failed_job/1
    Toniq.JobPersistence.incoming_jobs |> Enum.each &Toniq.JobPersistence.remove_from_incoming_jobs/1

    :email_adapter_mailsnail_mock.clear()
    :ok
  end

  test "send email" do
    Toniq.JobEvent.subscribe

    job = Mailsnail.send %{
      to: to = "test@client.com",
      from: from = "test@provider.com",
      subject: subject = "Hello",
      html: html = "html",
      text: text = "plain"
    }

    :ok = await job
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

    :ok = await job
    Toniq.JobEvent.unsubscribe

    last = :email_adapter_mailsnail_mock.last()
    assert last[:to] == {to, to}
    assert last[:from] == {from, from}
    assert last[:subject] == subject
    assert last[:message] == [{"html", html}, {"text", text}]
  end


  test "email template: string" do
    Toniq.JobEvent.subscribe

    job = Mailsnail.send %{
      to: "test@client.com",
      from: "test@provider.com",
      template: [subject: {:string, "hello <%= doc[:replacement] %>"}],
      doc: [replacement: "you"]
    }

    :ok = await job
    Toniq.JobEvent.unsubscribe

    last = :email_adapter_mailsnail_mock.last()
    assert last[:subject] == "hello you"
  end

  test "email template: path & alias" do
    Toniq.JobEvent.subscribe

    job = Mailsnail.send %{
      to: "test@client.com",
      from: "test@provider.com",
      template: [html: {:alias, :"test.html.eex"},
                 text: {:path, Path.join([__DIR__, "templates", "test.text.eex"])}],
      doc: [replacement: re = "something"]
    }

    :ok = await job
    Toniq.JobEvent.unsubscribe

    last = :email_adapter_mailsnail_mock.last()
    assert last[:message] == [{"html", "html #{re}\n"}, {"text", "text #{re}\n"}]
  end

  test "email template: group" do
    Toniq.JobEvent.subscribe

    job = Mailsnail.send %{
      to: "test@client.com",
      from: "test@provider.com",
      template: {:alias, :test},
      doc: [replacement: re = "something"]
    }

    :ok = await job
    Toniq.JobEvent.unsubscribe

    last = :email_adapter_mailsnail_mock.last()
    assert last[:subject] == "subject #{re}"
    assert last[:message] == [{"html", "html #{re}\n"}, {"text", "text #{re}\n"}]
  end

  test "metrics" do
    Toniq.JobEvent.subscribe
    {:ok, counter} = Agent.start_link fn() -> 0 end

    Application.put_env :mailsnail, :metrics, fn(_, _status) -> Agent.update(counter, &(&1 + 1)) end

    job = Mailsnail.send %{ subject: "test", to: "test@client.com", from: "test@provider.com", text: "hello" }
    :ok = await job
    assert 1 = Agent.get counter, &(&1)

    job = Mailsnail.send %{ to: "test@client.com", from: "test@provider.com", text: "hello" }
    :ok = await job
    assert 2 = Agent.get counter, &(&1)

    Application.put_env :mailsnail, :metrics, nil
  end

  defp await(job) do
    receive do
      {:finished, ^job}  -> :ok
    after
      5000 -> :timeout
    end
  end
end
