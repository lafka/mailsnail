defmodule Mailsnail.Template do

  @type t :: types

  @type typealias :: atom
  @type template :: String.t
  @type proxy :: (%Mailsnail.Msg{} -> String.t)

  @type types :: {:path, Path.t}
                 | {:alias, typealias}
                 | {:string, template}
                 | {:fun, proxy}


  @spec valid?(t) :: boolean
  def valid?({:fun, fun}), do: is_function(fun, 1)
  def valid?({:path, path}), do: File.exists?(path)
  def valid?({:alias, a}), do: nil !== aliases[a]
  def valid?({:string, buf}), do: is_binary(buf)

  defp aliases, do: Application.get_env(:mailsnail, :aliases)

  @doc """
  Expand a template list to non-alias members
  """
  @spec expand([{k :: atom, types}] | types) :: [{k :: atom, types}]
  def expand({:string, "" <> buf} = e), do: e
  def expand({:alias, a}) do
    case aliases[a] do
      nil -> {:error, {:notfound, {:alias, a}}}
      ret when is_list(ret) -> expand ret
    end
  end
  def expand(items) when is_list(items) do
    Enum.map items, fn
      ({k, {:alias, a}}) -> {k, aliases[a]}
      ({_k, {:string, "" <> _buf}} = e) -> e
      ({_k, {:fun, f}} = e) when is_function(f, 1) -> e
      ({_k, {:path, _p}} = e) -> e
    end
  end


  @doc """
  Create a template function
  """
  @spec proxy(t) :: proxy
  def proxy({:fun, f}) when is_function(f, 1), do: f
  def proxy({:path, "" <> path}), do: proxy({:string, File.read!(path)})
  def proxy({:string, "" <> buf}) do
    fn(%Mailsnail.Msg{doc: doc}) ->
      try do
        EEx.eval_string buf, doc: doc
      rescue e ->
        raise """
        failed to compile template
          error: #{inspect e}
          template: #{buf}
        """
      end
    end
  end
  def proxy({:alias, a}) do
    case aliases[a] do
      {:alias, b} -> {:error, {:redirect, {:alias, a, b}}}
      nil -> {:error, {:notfound, {:alias, a}}}
      whatever -> proxy(whatever)
    end
  end
end
