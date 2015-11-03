defmodule Mailsnail.Msg do
  defstruct [
    to: nil,
    from: nil,
    subject: nil,
    html: nil,
    text: nil,
    template: [],
    doc: [],
  ]

  @type t :: %__MODULE__{
    to: entity,
    from: entity,
    subject: subject,
    html: String.t,
    text: String.t,
    template: [{:subject, subject} | {:text | :html, String.t}],
    doc: [{atom, any}]
  }

  @type subject :: String.t
  @type email :: String.t | nil
  @type name :: String.t | nil
  @type entity :: {name, email}
end
