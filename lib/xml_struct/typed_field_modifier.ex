defmodule XmlStruct.TypedFieldModifier do
  def field_to_xml_field({:field, meta, [name, {{_, _, [{:__aliases__, meta, args}, :t]}, _, _}]}) do
    {:typed_field, meta, [name, {:__aliases__, meta, args}]}
  end

  def field_to_xml_field(
        {:field, meta, [name, {{_, _, [{:__aliases__, meta, args}, :t]}, _, _}, opts]}
      ) do
    {:typed_field, meta, [name, {:__aliases__, meta, args}, opts]}
  end

  def field_to_xml_field(
        {:field, meta, [name, [{{_, _, [{:__aliases__, meta, args}, :t]}, _, _}]]}
      ) do
    {:typed_field, meta, [name, {:__aliases__, meta, args}, [is_list: true]]}
  end

  def field_to_xml_field(
        {:field, meta, [name, [{{_, _, [{:__aliases__, meta, args}, :t]}, _, _}], opts]}
      ) do
    {:typed_field, meta, [name, {:__aliases__, meta, args}, opts ++ [is_list: true]]}
  end

  def field_to_xml_field({:field, meta, [name, {type, _, _}, opts]}) do
    {:typed_field, meta, [name, type, opts ++ [is_simple_type: true]]}
  end

  def field_to_xml_field({:field, meta, [name, {type, _, _}]}) do
    {:typed_field, meta, [name, type, [is_simple_type: true]]}
  end

  def field_to_xml_field({:field, meta, args}) do
    {:typed_field, meta, args}
  end

  def field_to_xml_field(node) do
    node
  end
end
