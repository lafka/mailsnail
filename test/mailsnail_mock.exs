defmodule :email_adapter_mailsnail_mock do
  @behaviour :email_adapter

  @table __MODULE__

  require Logger

  def start, do: start([])
  def start(_) do
    {:ok, pid} = Agent.start_link fn -> [] end
    true = Process.register pid, __MODULE__

    {:ok, pid}
  end

  def stop(agent), do: Agent.stop(agent)

  def send(_, {_nT, _eT} = to, {_nF, _eF} = sender, subject, message, opt) do
    Logger.debug "#{inspect sender} -> #{inspect to} :: #{inspect subject}"
    Agent.update __MODULE__, &([ [from: sender, to: to, subject: subject, message: message, opt: opt] | &1] )
    {:ok, :mock}
  end

  def sendt, do: Agent.get(__MODULE__, &(&1))
  def last, do: Agent.get(__MODULE__, &(hd(&1)))

  def clear, do: Agent.update(__MODULE__, fn(_) -> [] end)
end

