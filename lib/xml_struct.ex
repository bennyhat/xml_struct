defmodule XmlStruct do
  alias XmlStruct
  alias XmlStruct.Deserializer
  alias XmlStruct.TypedFieldModifier
  alias XmlStruct.Serializer
  alias XmlStruct.Struct
  alias XmlStruct.Xpath

  defmacro __using__(_) do
    quote do
      use TypedStruct
      import XmlStruct, only: [xmlstruct: 1, xmlstruct: 2]
    end
  end

  defmacro xmlstruct(opts \\ [], do: block) do
    options_as_map = Macro.escape(Enum.into(opts, %{}))

    quote do
      import SweetXml
      import XmlStruct

      alias XmlStruct
      alias XmlStruct.Deserializer
      alias XmlStruct.TypedFieldModifier
      alias XmlStruct.Serializer
      alias XmlStruct.Struct
      alias XmlStruct.Xpath

      Module.register_attribute(__MODULE__, :type_listing, accumulate: true)
      Module.register_attribute(__MODULE__, :type_mapping, accumulate: true)
      Module.register_attribute(__MODULE__, :xpath_selectors, accumulate: false)

      unquote(Macro.prewalk(block, &TypedFieldModifier.field_to_xml_field/1))
      typedstruct(unquote(opts), do: unquote(block))

      Xpath.build_selectors(
        __MODULE__,
        @type_listing,
        :xpath_selectors,
        unquote(options_as_map)
      )

      use Accessible

      def serialize(xml, parent_options \\ %{}) do
        type_mappings_as_map = Map.new(@type_mapping)

        Serializer.serialize(type_mappings_as_map, xml, merge_with_module_options(parent_options))
      end

      def deserialize(xml) do
        selectors = Xpath.adjust_root_selector(@xpath_selectors)

        Deserializer.deserialize(__MODULE__, selectors, xml)
        |> new()
      end

      def new(map) do
        type_mappings_as_map = Enum.into(@type_mapping, %{})

        Struct.new(__MODULE__, type_mappings_as_map, map)
      end

      def xpath_selectors() do
        @xpath_selectors
      end

      def xpath_selector(parent_options \\ %{}) do
        Xpath.xpath(__MODULE__, @type_listing, merge_with_module_options(parent_options))
      end

      defp merge_with_module_options(parent_options) do
        explicit_options = unquote(options_as_map)
        Map.merge(parent_options, explicit_options)
      end
    end
  end

  defmacro typed_field(name, type, opts \\ []) do
    quote do
      XmlStruct.__build_field__(
        __MODULE__,
        unquote(name),
        unquote(type),
        unquote(opts)
      )
    end
  end

  def __build_field__(mod, name, type, opts) when is_atom(name) do
    Module.put_attribute(mod, :type_listing, {name, type, opts})
    Module.put_attribute(mod, :type_mapping, {name, {type, opts}})
  end
end
