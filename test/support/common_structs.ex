defmodule SimpleStruct do
  use XmlStruct

  xmlstruct do
    field :field_one, boolean()
    field :field_two, String.t()
    field :field_three, integer()
  end
end

defmodule NestedSimpleStruct do
  use XmlStruct

  xmlstruct do
    field :nested_field_one, boolean()
    field :nested_field_two, SimpleStruct.t()
    field :nested_field_three, [SimpleStruct.t()]
  end
end

defmodule DeeplyNestedSimpleStruct do
  use XmlStruct

  xmlstruct do
    field :deeply_nested_field_one, boolean()
    field :deeply_nested_field_two, NestedSimpleStruct.t()
    field :deeply_nested_field_three, [NestedSimpleStruct.t()]
  end
end
