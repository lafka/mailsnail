defmodule Mailsnail.Worker do
  use Toniq.Worker

  alias Mailsnail.Msg
  alias Mailsnail.Template

  def perform(%Msg{} = msg) do
    templates = is_atom(msg.template) && Template.proxy(msg.template) || msg.template
    msg = Enum.reduce templates, msg, fn({k, v}, acc) ->
      {:ok, newval} = Template.proxy(v).(msg)

      Map.put(acc, k, newval)
    end

    body = []
      |> maybe_add(:html, msg.html)
      |> maybe_add(:text, msg.text)

    {:ok, _} = :email.send msg.to, msg.from, msg.subject, body
    :ok
  end

  defp maybe_add(acc, _k, nil), do: acc
  defp maybe_add(acc, k, v), do: [{k, v} | acc]
end
