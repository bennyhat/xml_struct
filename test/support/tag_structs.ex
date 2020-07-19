defmodule ModuleFormatCamel do
  use XmlStruct

  xmlstruct tag_format: :camel_case do
    field :nested_field_one, boolean()
    field :nested_field_two, SimpleStruct.t()
    field :nested_field_three, [SimpleStruct.t()]
  end
end

defmodule ModuleFormatKebab do
  use XmlStruct

  xmlstruct tag_format: :kebab_case do
    field :nested_field_one, boolean()
    field :nested_field_two, SimpleStruct.t()
    field :nested_field_three, [SimpleStruct.t()]
  end
end

defmodule ModuleFormatSnake do
  use XmlStruct

  xmlstruct tag_format: :snake_case do
    field :nested_field_one, boolean()
    field :nested_field_two, SimpleStruct.t()
    field :nested_field_three, [SimpleStruct.t()]
  end
end

defmodule ModuleFormatCamelChildModuleFormatVarious do
  use XmlStruct

  xmlstruct tag_format: :camel_case do
    field :nested_field_one, boolean()
    field :nested_field_two, ModuleFormatSnake.t()
    field :nested_field_three, [ModuleFormatKebab.t()]
  end
end

defmodule ModuleFormatCamelChildFieldFormatVarious do
  use XmlStruct

  xmlstruct tag_format: :camel_case do
    field :nested_field_one, boolean()
    field :nested_field_two, NestedSimpleStruct.t(), tag_format: :pascal_case
    field :nested_field_three, [ModuleFormatKebab.t()], tag_format: :pascal_case
  end
end
