defmodule Mailsnail do
  alias Mailsnail.Msg

  @keys Map.keys(%Msg{})

  @doc """
  Enqueue a message for sending
  """
  @spec send(%Msg{}) :: :ok
  def send(%{} = message) do
    unless [] = extra = Enum.reject Map.keys(message), &(Enum.member? @keys, &1) do
      raise %ArgumentError{message: "invalid keys #{Enum.join(extra, ", ")}"}
    end

    # make sure templates exists
    for {k, v} <- message[:template] || [] do
      cond do
        not k in [:subject, :html, :text] ->
          raise %ArgumentError{message: "invalid template '#{k}"}

        is_binary(v) and not Mailsnail.Template.exists?(v) ->
          raise %ArgumentError{message: "no such template '#{v}"}

        true ->
          true
      end
    end

    Toniq.enqueue Mailsnail.Worker, %Msg{
      to: message[:to],
      from: message[:from],
      subject: message[:subject],
      html: message[:html],
      text: message[:text],
      template: message[:template] || [],
      doc: message[:doc] || []
    }
  end
end
