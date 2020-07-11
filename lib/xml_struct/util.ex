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
      %{} -> false
    end)
  end

  def strip_options(xml) do
    Enum.map(xml, &strip_field_options/1)
  end
  def strip_field_options({k, v, _o}), do: {k, v}
  def strip_field_options({v, _o}), do: v

  def triage(%_struct{}), do: {:single, :struct}
  def triage(map) when is_map(map), do: {:single, :map}
  def triage([%_struct{} | _]), do: {:list, :struct}
  def triage([map | _]) when is_map(map), do: {:list, :map}
  def triage(v) when is_list(v), do: {:list, :other_type}
  def triage(_), do: {:single, :other_type}
end
