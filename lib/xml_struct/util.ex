defmodule XmlStruct.Util do
  def recase(name, :pascal_case), do: Recase.to_pascal(name)
  def recase(name, :camel_case), do: Recase.to_camel(name)
  def recase(name, :kebab_case), do: Recase.to_kebab(name)
  def recase(name, :snake_case), do: Recase.to_snake(name)

  def remove_nil_or_empty_fields(fields) do
    fields
    |> Enum.reject(fn
      {_k, nil} -> true
      {_k, []} -> true
      {_k, _v} -> false
      nil -> true
      _v -> false
    end)
  end

  def triage(%_struct{}), do: {:single, :struct}
  def triage(map) when is_map(map), do: {:single, :map}
  def triage([%_struct{} | _]), do: {:list, :struct}
  def triage([map | _]) when is_map(map), do: {:list, :map}
  def triage(v) when is_list(v), do: {:list, :other_type}
  def triage(_), do: {:single, :other_type}

  def replace(map, key, function) do
    case Map.fetch(map, key) do
      {:ok, value} -> Map.put(map, key, function.(value))
      :error -> map
    end
  end
end
