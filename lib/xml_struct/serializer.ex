defmodule XmlStruct.Serializer do
  @default_parent_options %{
    tag_format: :pascal_case,
    list_prefix: "member"
  }

  @default_child_options %{
    serialize_only: [],
    serialize_as_object: true
  }

  def serialize(type_map, xml_list, opts \\ %{})
  def serialize(type_map, xml_list, opts) when is_list(xml_list) do
    xml_list
    |> Enum.map(&serialize(type_map, &1, opts))
    |> add_list_prefix()
  end

  def serialize(type_map, %_is_struct{} = xml, opts) do
    serialize(type_map, Map.from_struct(xml), opts)
  end

  def serialize(type_map, xml, %{serialize_only: [_|_]} = opts) when is_map(xml) do
    options = Map.merge(@default_parent_options, opts)
    serialize_only = Map.get(opts, :serialize_only)

    xml
    |> Map.keys()
    |> keep_allowed_fields(serialize_only)
    |> attach_options(type_map, options)
    |> apply_field_name_and_value(xml, serialize_only)
    |> serialize_fields(type_map)
    |> List.flatten()
    |> remove_nil_or_empty_fields()
    |> Map.new()
  end

  def serialize(type_map, xml, opts) when is_map(xml) do
    opts_with_serialize_only = opts
    |> Map.put(:serialize_only, all_key_mappings(xml))

    serialize(type_map, xml, opts_with_serialize_only)
  end

  def serialize(_type_map, atom_type, _opts)
      when is_atom(atom_type) and not is_nil(atom_type) and not is_boolean(atom_type) do
    Atom.to_string(atom_type)
  end

  def serialize(_type_map, other_type, _opts) do
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

  defp keep_allowed_fields(fields, serialize_only) do
    fields
    |> Enum.reject(fn field -> is_nil(Keyword.get(serialize_only, field)) end)
  end

  defp attach_options(fields, type_map, opts) do
    fields
    |> Enum.map(fn field -> {field, Map.get(type_map, field, {nil, []})} end)
    |> Enum.map(fn {field, {_type, options}} ->
      {
        field,
        Map.merge(opts, @default_child_options)
        |> Map.merge(Enum.into(options, %{}))
      }
    end)
  end

  defp apply_field_name_and_value(fields, xml, serialize_only) do
    fields
    |> Enum.map(fn {field, opts} ->
      {
        Keyword.get(serialize_only, field),
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
          %{serialize_as_object: false} = opts},
         _type_map
       ) do
    apply(struct, :serialize, [value, parent_options(opts)])
  end

  defp serialize_field_item(
         {_field, %struct{} = value,
          %{serialize_as_object: false} = opts},
         _type_map
       ) do
    apply(struct, :serialize, [value, parent_options(opts)])
    |> Map.to_list()
  end

  defp serialize_field_item(
         {field, %struct{} = value,
          %{serialize_as_object: true, list_prefix: _list_prefix} = opts},
         _type_map
       ) do
    value = apply(struct, :serialize, [value, parent_options(opts)])

    Enum.map(value, fn {k, v} ->
      {"#{field}.#{k}", v}
    end)
  end

  defp serialize_field_item(
         {field, [%struct{} = _element | _] = value,
          %{list_prefix: list_prefix} = opts},
         _type_map
       )
       when is_list(value) do
    Enum.map(value, fn v ->
      apply(struct, :serialize, [v, parent_options(opts)])
    end)
    |> add_object_prefix(field, list_prefix)
  end

  defp serialize_field_item(
         {field, value, %{list_prefix: _list_prefix} = opts},
         type_map
       )
       when is_list(value) do

    Enum.map(value, fn v ->
      {field, serialize(type_map, v, parent_options(opts))}
    end)
    |> add_list_prefix()
  end

  defp serialize_field_item({field, value, opts}, type_map) do
    {field, serialize(type_map, value, parent_options(opts))}
  end

  defp parent_options(opts) do
    {parent_options, _}  = Map.split(opts, Map.keys(@default_parent_options))
    %{serialize_only: serialize_only} = opts

    Map.merge(parent_options, %{serialize_only: serialize_only})
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
