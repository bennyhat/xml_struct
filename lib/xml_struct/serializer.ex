defmodule XmlStruct.Serializer do
  def serialize(type_map, xml, overrides \\ [])

  def serialize(type_map, xml_list, overrides) when is_list(xml_list) do
    xml_list
    |> Enum.map(&serialize(type_map, &1, overrides))
    |> add_list_prefix()
  end

  def serialize(type_map, %_is_struct{} = xml, overrides) do
    serialize(type_map, Map.from_struct(xml), overrides)
  end

  def serialize(type_map, xml, [] = _overrides) when is_map(xml) do
    serialize(type_map, xml, all_key_mappings(xml))
  end

  def serialize(type_map, xml, [_ | _] = overrides) when is_map(xml) do
    xml
    |> Map.keys()
    |> keep_allowed_fields(overrides)
    |> attach_options(type_map)
    |> apply_field_name_and_value(xml, overrides)
    |> serialize_fields(type_map)
    |> List.flatten()
    |> remove_nil_or_empty_fields()
    |> Map.new()
  end

  def serialize(_type_map, atom_type, _overrides)
      when is_atom(atom_type) and not is_nil(atom_type) and not is_boolean(atom_type) do
    Atom.to_string(atom_type)
  end

  def serialize(_type_map, other_type, _overrides) do
    other_type
  end

  defp remove_nil_or_empty_fields(fields) do
    fields
    |> Enum.reject(fn
      {_k, nil} -> true
      {_k, []} -> true
      {_k, _v} -> false
      %{} -> false
    end)
  end

  defp keep_allowed_fields(fields, allowed_fields) do
    fields
    |> Enum.reject(fn field -> is_nil(Keyword.get(allowed_fields, field)) end)
  end

  defp attach_options(fields, type_map) do
    fields
    |> Enum.map(fn field -> {field, Map.get(type_map, field, {nil, []})} end)
    |> Enum.map(fn {field, {_type, options}} ->
      {
        field,
        Map.merge(
          %{serialize_only: [], serialize_as_object: true, list_prefix: "member"},
          Enum.into(options, %{})
        )
      }
    end)
  end

  defp apply_field_name_and_value(fields, xml, allowed_fields) do
    fields
    |> Enum.map(fn {field, opts} ->
      {
        Keyword.get(allowed_fields, field),
        Map.get(xml, field),
        opts
      }
    end)
  end

  defp serialize_fields(fields, type_map) do
    fields
    |> Enum.map(&serialize_field_item(&1, type_map))
  end

  defp serialize_field_item(
         {_field, [%struct{} = _element | _] = value,
          %{serialize_only: allowed_fields, serialize_as_object: false}},
         _type_map
       ) do
    apply(struct, :serialize, [value, allowed_fields])
  end

  defp serialize_field_item(
         {_field, %struct{} = value,
          %{serialize_only: allowed_fields, serialize_as_object: false}},
         _type_map
       ) do
    apply(struct, :serialize, [value, allowed_fields])
    |> Map.to_list()
  end

  defp serialize_field_item(
         {field, %struct{} = value,
          %{serialize_only: allowed_fields, serialize_as_object: true, list_prefix: _list_prefix}},
         _type_map
       ) do
    value = apply(struct, :serialize, [value, allowed_fields])

    Enum.map(value, fn {k, v} ->
      {"#{field}.#{k}", v}
    end)
  end

  defp serialize_field_item(
         {field, [%struct{} = _element | _] = value,
          %{serialize_only: allowed_fields, list_prefix: list_prefix}},
         _type_map
       )
       when is_list(value) do
    Enum.map(value, fn v ->
      apply(struct, :serialize, [v, allowed_fields])
    end)
    |> add_object_prefix(field, list_prefix)
  end

  defp serialize_field_item(
         {field, value, %{serialize_only: allowed_fields, list_prefix: _list_prefix}},
         type_map
       )
       when is_list(value) do
    Enum.map(value, fn v ->
      {field, serialize(type_map, v, allowed_fields)}
    end)
    |> add_list_prefix()
  end

  defp serialize_field_item({field, value, %{serialize_only: allowed_fields}}, type_map) do
    {field, serialize(type_map, value, allowed_fields)}
  end

  defp all_key_mappings(map) do
    build_camelized_mapping = fn key ->
      {key, Macro.camelize(Atom.to_string(key))}
    end

    Map.keys(map)
    |> Enum.map(build_camelized_mapping)
  end

  defp add_object_prefix(xml_list, field, list_prefix) do
    xml_list
    |> Enum.with_index(1)
    |> Enum.map(fn {xml, index} ->
      Enum.map(xml, fn {key, value} ->
        {"#{field}.#{list_prefix}.#{index}.#{key}", value}
      end)
    end)
    |> List.flatten()
  end

  defp add_list_prefix(xml_list, list_prefix \\ "member")

  defp add_list_prefix([element | _] = xml_struct_list, list_prefix) when is_map(element) do
    xml_struct_list
    |> Enum.with_index(1)
    |> Enum.map(fn {xml_struct, index} ->
      Enum.map(xml_struct, fn {key, value} ->
        {"#{key}.#{list_prefix}.#{index}", value}
      end)
    end)
  end

  defp add_list_prefix(simple_list, list_prefix) do
    simple_list
    |> Enum.with_index(1)
    |> Enum.map(fn {{key, value}, index} ->
      {"#{key}.#{list_prefix}.#{index}", value}
    end)
  end
end
