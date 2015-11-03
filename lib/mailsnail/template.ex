defmodule Mailsnail.Template do

  @type t :: Path.t | proxy
  @type proxy :: (%Mailsnail.Msg{} -> String.t)


  @spec exists?(t) :: boolean
  def exists?(template) when is_function(template), do: true
  def exists?("" <> template), do: File.exists?(template)

  @doc """
  Create a template function
  """
  @spec proxy(t) :: proxy | [{atom, t}]
  def proxy(template) when is_list(template), do: template
  def proxy(template) when is_function(template), do: template
  def proxy("" <> template) do
    buf = File.read! template

    fn(%Mailsnail.Msg{doc: doc}) ->
      EEx.eval_string buf, doc
    end
  end
  def proxy(tplalias) when is_atom(tplalias) do
    aliases = Application.get_env :mailsnail, :aliases

    case aliases[tplalias] do
      nil -> raise ArgumentError, message: "no such template alias: #{tplalias}"
      tpl when not is_atom(tpl) -> proxy tpl
    end
  end
end
