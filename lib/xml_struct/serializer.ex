defmodule XmlStruct.Serializer do
  @default_struct_options %{
    tag_format: :pascal_case,
    list_prefix: "member",
    serialize_only: [],
    serialize_as_object: true
  }

  @struct_options_to_reset %{
    serialize_only: []
  }

  def serialize(type_map, xml_list, opts \\ %{})
  def serialize(type_map, xml_list, opts) when is_list(xml_list) do
    xml_list
    |> Enum.map(&serialize(type_map, &1, opts))
  end

  def serialize(type_map, %_is_struct{} = xml, opts) do
    serialize(type_map, Map.from_struct(xml), opts)
  end

  def serialize(type_map, map, %{serialize_only: [_|_]} = opts) when is_map(map) do
    struct_options = Map.merge(@default_struct_options, opts)
    field_options = Map.merge(struct_options, @struct_options_to_reset)

    map_with_field_options_applied =
      map
      |> keep_desired_fields(struct_options)
      |> attach_options(type_map, field_options)
      |> apply_key_overrides(struct_options)

    map_with_field_options_applied
    |> serialize_values(type_map)
    |> apply_list_prefix_to_keys()
    |> apply_object_prefix_to_fields()
    |> remove_keys_if_desired()
    |> List.flatten()
    |> strip_options()
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

  defp serialize_struct(%struct_type{} = struct_item, options_to_pass_down) do
    struct_type.serialize(struct_item, options_to_pass_down)
  end

  defp serialize_values(fields, type_map) do
    fields
    |> Enum.map(&serialize_value(&1, type_map))
  end

  defp serialize_value({k, v, o}, type_map) do
    serialized_value =
      case triage(v) do
        {:single, :struct} ->
          serialize_struct(v, o)
        {:single, _} ->
          serialize(type_map, v, o)
        {:list, :struct} ->
          Enum.map(v, &serialize_struct(&1, o))
        {:list, _} ->
          Enum.map(v, &serialize(type_map, &1, o))
      end

    {k, serialized_value, o}
  end

  defp all_key_mappings(map) do
    build_camelized_mapping = fn key ->
      {key, Macro.camelize(Atom.to_string(key))}
    end

    Map.keys(map)
    |> Enum.map(build_camelized_mapping)
  end

  defp keep_desired_fields(xml, %{serialize_only: serialize_only}) do
    {keep, _toss} = Map.split(xml, Keyword.keys(serialize_only))

    keep
  end

  defp attach_options(xml, type_map, field_options) do
    Enum.map(xml, &attach_field_options(&1, type_map, field_options))
  end

  defp attach_field_options({k, v}, type_map, field_options) do
    {_type, field_overrides} = Map.get(type_map, k, {nil, []})

    overrides_as_map = Map.new(field_overrides)
    overrides_with_field_fallbacks = Map.merge(field_options, overrides_as_map)

    {k, v, overrides_with_field_fallbacks}
  end

  defp apply_key_overrides(xml, %{serialize_only: serialize_only}) do
    Enum.map(xml, fn {k, v, o} ->
      {Keyword.get(serialize_only, k), v, o}
    end)
  end

  defp apply_list_prefix_to_keys(xml) do
    Enum.map(xml, &apply_list_prefix_to_key/1)
    |> List.flatten()
  end
  defp apply_list_prefix_to_key({k, v, %{list_prefix: lp} = o}) do
    handle_index = fn {vi, i} ->
      {"#{k}.#{lp}.#{i}", vi, o}
    end

    case triage(v) do
      {:list, _} ->
        Enum.with_index(v, 1)
        |> Enum.map(handle_index)
      _ ->
        {k, v, o}
    end
  end

  defp apply_object_prefix_to_fields(xml) do
    Enum.map(xml, &apply_object_prefix_to_field/1)
    |> List.flatten()
  end
  defp apply_object_prefix_to_field({k, v, o}) do
    case triage(v) do
      {:single, type} when type in [:struct, :map] ->
        Enum.map(v, fn {vk, vv} ->
          {"#{k}.#{vk}", vv, o}
        end)
      _ ->
        {k, v, o}
    end
  end

  defp remove_keys_if_desired(xml) do
    Enum.map(xml, &remove_key/1)
  end

  defp remove_key({k, v, %{serialize_as_object: true} = o}), do: {k, v, o}
  defp remove_key({_k, v, %{serialize_as_object: false} = o}), do: {v, o}

  defp strip_options(xml) do
    Enum.map(xml, &strip_field_options/1)
  end
  defp strip_field_options({k, v, _o}), do: {k, v}
  defp strip_field_options({v, _o}), do: {v}

  defp remove_nil_or_empty_fields(fields) do
    fields
    |> Enum.reject(fn
      {_k, nil} -> true
      {_k, []} -> true
      {_k, _v} -> false
      %{} -> false
    end)
  end

  defp triage(%_struct{}), do: {:single, :struct}
  defp triage(map) when is_map(map), do: {:single, :map}
  defp triage([%_struct{} | _]), do: {:list, :struct}
  defp triage([map | _]) when is_map(map), do: {:list, :map}
  defp triage(v) when is_list(v), do: {:list, :other_type}
  defp triage(_), do: {:single, :other_type}
end
