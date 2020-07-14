defmodule XmlStruct.Serializer do
  import XmlStruct.Util, only: [
    remove_nil_or_empty_fields: 1,
    triage: 1,
  ]

  import XmlStruct.Serializer.FieldAdjuster, only: [
    determine_desired_fields: 3,
    keep_desired_fields: 2,
    attach_options: 3,
    apply_key_overrides: 2,
    apply_list_prefix_to_keys: 1,
    apply_object_prefix_to_fields: 1,
    strip_options: 1,
  ]

  @default_struct_options %{
    tag_format: :pascal_case,
    list_prefix: "member",
    serialize_only: [],
    serialize_as_object: true
  }

  @struct_options_to_reset %{
    serialize_only: [],
    serialize_as_object: true
  }

  def serialize(type_map, xml_list, opts \\ %{})
  def serialize(type_map, %_is_struct{} = xml, opts) do
    serialize(type_map, Map.from_struct(xml), opts)
  end
  def serialize(type_map, map, opts) when is_map(map) do
    struct_options = Map.merge(@default_struct_options, opts)
    desired_fields = determine_desired_fields(map, type_map, struct_options)
    struct_options = Map.put(struct_options, :serialize_only, desired_fields)
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
    |> List.flatten()
    |> strip_options()
    |> remove_nil_or_empty_fields()
    |> Map.new()
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
end
