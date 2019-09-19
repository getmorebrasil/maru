alias Maru.Builder.Description

defmodule Description.DSLs do
  @doc """
  Define description for current endpoint.
  """
  defmacro desc(desc) do
    quote do
      @desc %{summary: unquote(desc)}
    end
  end

  @doc """
  Define description with a block for current endpoint.
  """
  defmacro desc(desc, do: block) do
    quote do
      @desc %{summary: unquote(desc)}
      import Description.DSLs
      import Description.DSLs, except: [desc: 1, desc: 2]
      unquote(block)
      import Description.DSLs, only: [desc: 1, desc: 2]
    end
  end

  @doc """
  Define detail of description.
  """
  defmacro detail(detail) do
    quote do
      @desc put_in(@desc, [:detail], unquote(detail))
    end
  end

  @doc """
  Define response of description.
  """
  defmacro responses(do: block) do
    quote do
      @desc put_in(@desc, [:responses], [])
      unquote(block)
    end
  end

  @doc """
  Define status within response.
  """
  defmacro status(code, options) do
    desc = Keyword.get(options, :desc)
    status = %{code: code, description: desc} |> Macro.escape()

    quote do
      @desc update_in(@desc, [:responses], &(&1 ++ [unquote(status)]))
    end
  end

  @doc """
  Define model for current endpoint.
  """
  defmacro model(name, do: block) do
    quote do
      @desc put_in(@desc, [:model], %{name: unquote(name), fields: []})
      unquote(block)
    end
  end

  @doc """
  Define field for endpoint model.
  """
  defmacro field(name, options) do
    field = case options do
      [type: type]   -> %{name: name, type: type}
      [model: model] -> %{name: name, model: model}
    end
    |> Macro.escape()

    quote do
      @desc update_in(@desc, [:model], &(%{name: &1.name, fields: &1.fields ++ [unquote(field)]}))
    end
  end

  @doc """
  Define tag for endpoint model.
  """
  defmacro tag(tag) do
    quote do
      @desc put_in(@desc, [:tag], unquote(tag))
    end
  end
end
