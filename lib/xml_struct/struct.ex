defmodule XmlStruct.Struct do
  def new(module, type_mapping, list) when is_list(list) do
    Enum.map(list, &new(module, type_mapping, &1))
  end

  def new(module, type_mapping, map) when is_map(map) do
    filled_map =
      map
      |> Enum.reject(fn {_k, v} ->
        is_nil(v)
      end)
      |> Enum.map(&nested_new(&1, type_mapping))
      |> Enum.into(%{})

    struct!(module, filled_map)
  end

  defp nested_new({name, nil}, _type_mapping) do
    {name, nil}
  end

  defp nested_new({name, value}, type_mapping) do
    {type, _opts} = Map.get(type_mapping, name)

    Code.ensure_compiled(type)

    if function_exported?(type, :new, 1) do
      newed_value = apply(type, :new, [value])

      {name, newed_value}
    else
      {name, value}
    end
  end
end
