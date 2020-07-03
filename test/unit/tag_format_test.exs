defmodule TagTest.ModuleFormatCamel do
  use XmlStruct

  xmlstruct tag_format: :camel_case do
    field :nested_field_one, boolean()
    field :nested_field_two, SimpleStruct.t()
    field :nested_field_three, [SimpleStruct.t()]
  end
end

defmodule TagTest.ModuleFormatKebab do
  use XmlStruct

  xmlstruct tag_format: :kebab_case do
    field :nested_field_one, boolean()
    field :nested_field_two, SimpleStruct.t()
    field :nested_field_three, [SimpleStruct.t()]
  end
end

defmodule TagTest.ModuleFormatSnake do
  use XmlStruct

  xmlstruct tag_format: :snake_case do
    field :nested_field_one, boolean()
    field :nested_field_two, SimpleStruct.t()
    field :nested_field_three, [SimpleStruct.t()]
  end
end

defmodule TagTest do
  use ExUnit.Case

  describe "ModuleFormatCamel.serialize/1" do
    test "serializes with a module-level tag format" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "nestedFieldOne" => true,
        "nestedFieldTwo.fieldTwo" => "hello",
        "nestedFieldThree.member.1.fieldOne" => true,
        "nestedFieldThree.member.2.fieldThree" => random_integer
      } == TagTest.ModuleFormatCamel.serialize(
        %TagTest.ModuleFormatCamel{
          nested_field_one: true,
          nested_field_two: %SimpleStruct{
            field_two: "hello"
          },
          nested_field_three: [
            %SimpleStruct{
              field_one: true
            },
            %SimpleStruct{
              field_three: random_integer
            }
          ]
        }
      )
    end
  end

  describe "ModuleFormatKebab.serialize/1" do
    test "serializes with a module-level tag format" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "nested-field-one" => true,
        "nested-field-two.field-two" => "hello",
        "nested-field-three.member.1.field-one" => true,
        "nested-field-three.member.2.field-three" => random_integer
      } == TagTest.ModuleFormatKebab.serialize(
        %TagTest.ModuleFormatKebab{
          nested_field_one: true,
          nested_field_two: %SimpleStruct{
            field_two: "hello"
          },
          nested_field_three: [
            %SimpleStruct{
              field_one: true
            },
            %SimpleStruct{
              field_three: random_integer
            }
          ]
        }
      )
    end
  end

  describe "ModuleFormatSnake.serialize/1" do
    test "serializes with a module-level tag format" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "nested_field_one" => true,
        "nested_field_two.field_two" => "hello",
        "nested_field_three.member.1.field_one" => true,
        "nested_field_three.member.2.field_three" => random_integer
      } == TagTest.ModuleFormatSnake.serialize(
        %TagTest.ModuleFormatSnake{
          nested_field_one: true,
          nested_field_two: %SimpleStruct{
            field_two: "hello"
          },
          nested_field_three: [
            %SimpleStruct{
              field_one: true
            },
            %SimpleStruct{
              field_three: random_integer
            }
          ]
        }
      )
    end
  end
end
