defmodule XmlStruct.Util do
  def recase(name, :pascal_case), do: Recase.to_pascal(name)
  def recase(name, :camel_case), do: Recase.to_camel(name)
  def recase(name, :kebab_case), do: Recase.to_kebab(name)
  def recase(name, :snake_case), do: Recase.to_snake(name)
end
