defmodule XmlStruct do
  alias XmlStruct
  alias XmlStruct.Deserializer
  alias XmlStruct.Field
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
    quote do
      import SweetXml
      import XmlStruct

      alias XmlStruct
      alias XmlStruct.Deserializer
      alias XmlStruct.Field
      alias XmlStruct.Serializer
      alias XmlStruct.Struct
      alias XmlStruct.Xpath

      Module.register_attribute(__MODULE__, :type_listing, accumulate: true)
      Module.register_attribute(__MODULE__, :type_mapping, accumulate: true)
      Module.register_attribute(__MODULE__, :xpath_selectors, accumulate: false)

      unquote(Macro.prewalk(block, &Field.field_to_xml_field/1))
      typedstruct(unquote(opts), do: unquote(block))

      Xpath.build_selectors(
        __MODULE__,
        @type_listing,
        :xpath_selectors,
        Enum.into(unquote(opts), %{})
      )

      use Accessible

      def serialize(%__MODULE__{} = xml_struct) do
        Serializer.serialize(Enum.into(@type_mapping, %{}), xml_struct)
      end

      def serialize(xml, allowed_fields) do
        Serializer.serialize(Enum.into(@type_mapping, %{}), xml, allowed_fields)
      end

      def deserialize(xml) do
        selectors = Xpath.adjust_root_selector(@xpath_selectors)

        Deserializer.deserialize(__MODULE__, selectors, xml)
        |> new()
      end

      def new(map) do
        Struct.new(__MODULE__, Enum.into(@type_mapping, %{}), map)
      end

      def xpath_selector() do
        Xpath.xpath(__MODULE__, @type_listing, Enum.into(unquote(opts), %{}))
      end

      def xpath_selectors() do
        @xpath_selectors
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
