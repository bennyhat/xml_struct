defmodule XmlStruct.Serializer.FieldAdjuster do
  import XmlStruct.Util, only: [
    recase: 2,
    triage: 1,
  ]

  def determine_desired_fields(map, type_map, opts) do
    case Map.get(opts, :serialize_only, []) do
      [] -> all_key_mappings(map, type_map, opts)
      so -> so
    end
  end

  defp all_key_mappings(map, type_map, %{tag_format: struct_tag_format}) do
    build_recased_mapping = fn key ->
      {_type, field_overrides} = Map.get(type_map, key, {nil, []})
      tag_format = Map.get(Map.new(field_overrides), :tag_format, struct_tag_format)

      {key, recase(Atom.to_string(key), tag_format)}
    end

    Map.keys(map)
    |> Enum.map(build_recased_mapping)
  end

  def keep_desired_fields(xml, %{serialize_only: serialize_only}) do
    {keep, _toss} = Map.split(xml, Keyword.keys(serialize_only))

    keep
  end

  def attach_options(xml, type_map, field_options) do
    Enum.map(xml, &attach_field_options(&1, type_map, field_options))
  end

  defp attach_field_options({k, v}, type_map, field_options) do
    {_type, field_overrides} = Map.get(type_map, k, {nil, []})

    overrides_as_map = Map.new(field_overrides)
    overrides_with_field_fallbacks = Map.merge(field_options, overrides_as_map)

    {k, v, overrides_with_field_fallbacks}
  end

  def apply_key_overrides(xml, %{serialize_only: serialize_only}) do
    Enum.map(xml, fn {k, v, o} ->
      {Keyword.get(serialize_only, k), v, o}
    end)
  end

  def apply_list_prefix_to_keys(xml) do
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

  def apply_object_prefix_to_fields(xml) do
    Enum.map(xml, &apply_object_prefix_to_field/1)
    |> List.flatten()
  end
  defp apply_object_prefix_to_field({k, v, o}) do
    case triage(v) do
      {:single, type} when type in [:struct, :map] ->
        Enum.map(v, fn {vk, vv} ->
          {format_keys(k, vk, o), vv, o}
        end)
      _ ->
        {k, v, o}
    end
  end

  defp format_keys(k, vk, %{serialize_as_object: false}), do: shift_keys(k, vk)
  defp format_keys(k, vk, _opts), do: "#{k}.#{vk}"

  defp split_key(key) do
    case String.contains?(key, ".") do
      true ->
        %{"root" => root, "child" => child} = Regex.named_captures(~r/^(?<root>.*?)\.(?<child>.*?)$/, key)
        {root, "." <> child}
      false -> {key, ""}
    end
  end

  defp shift_keys(k, vk) do
    {_struct_root, struct_child} = split_key(k)
    {field_root, field_child} = split_key(vk)

    field_root <> struct_child <> field_child
  end

  def strip_options(xml) do
    Enum.map(xml, &strip_field_options/1)
  end
  defp strip_field_options({k, v, _o}), do: {k, v}
  defp strip_field_options({v, _o}), do: v
end
