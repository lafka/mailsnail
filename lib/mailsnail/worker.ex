defmodule Mailsnail.Worker do
  use Toniq.Worker

  require Logger

  alias Mailsnail.Msg
  alias Mailsnail.Template

  def perform(%Msg{} = msg) do
    templates = Template.expand msg.template

    msg = Enum.reduce templates, msg, fn({k, v}, acc) ->
      newval = Template.proxy(v).(msg)

      Map.put(acc, k, newval)
    end

    body = []
      |> maybe_add(:html, msg.html)
      |> maybe_add(:text, msg.text)

    subject = String.strip msg.subject || ""

    {:ok, _} = :email.send msg.to, msg.from, subject, body
    :ok
  rescue e ->
    Logger.error """
    failed to send email: #{inspect e}

    #{Exception.format_stacktrace}
    """
    raise e
  end

  defp maybe_add(acc, _k, nil), do: acc
  defp maybe_add(acc, k, v), do: [{k, v} | acc]
end
