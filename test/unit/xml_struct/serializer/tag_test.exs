defmodule XmlStruct.Serializer.TagTest do
  use ExUnit.Case

  describe "ModuleFormatCamel.serialize/1" do
    test "serializes with a module-level tag format" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "nestedFieldOne" => true,
        "nestedFieldTwo.fieldTwo" => "hello",
        "nestedFieldThree.member.1.fieldOne" => true,
        "nestedFieldThree.member.2.fieldThree" => random_integer
      } == ModuleFormatCamel.serialize(
        %ModuleFormatCamel{
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
      } == ModuleFormatKebab.serialize(
        %ModuleFormatKebab{
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
      } == ModuleFormatSnake.serialize(
        %ModuleFormatSnake{
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

  describe "ModuleFormatCamelChildModuleFormatVarious.serialize/1" do
    test "serializes with a module-level tag format" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "nestedFieldOne" => true,
        "nestedFieldThree.member.1.nested-field-two.field-three" => random_integer,
        "nestedFieldThree.member.2.nested-field-three.member.1.field-one" => false,
        "nestedFieldTwo.nested_field_two.field_two" => "hello"
      } == ModuleFormatCamelChildModuleFormatVarious.serialize(
        %ModuleFormatCamelChildModuleFormatVarious{
          nested_field_one: true,
          nested_field_two: %ModuleFormatSnake{
            nested_field_two: %SimpleStruct{
              field_two: "hello"
            }
          },
          nested_field_three: [
            %ModuleFormatKebab{
              nested_field_two: %SimpleStruct{
                field_three: random_integer
              }
            },
            %ModuleFormatKebab{
              nested_field_three: [
                %SimpleStruct{
                  field_one: false
                }
              ]
            }
          ]
        }
      )
    end
  end

  describe "ModuleFormatCamelChildFieldFormatVarious.serialize/1" do
    test "serializes with a module-level tag format" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "nestedFieldOne" => true,
        "NestedFieldThree.member.1.nested-field-two.field-three" => random_integer,
        "NestedFieldThree.member.2.nested-field-three.member.1.field-one" => false,
        "nestedFieldTwo.nested_field_two.field_two" => "hello"
      } == ModuleFormatCamelChildFieldFormatVarious.serialize(
        %ModuleFormatCamelChildFieldFormatVarious{
          nested_field_one: true,
          nested_field_two: %ModuleFormatSnake{
            nested_field_two: %SimpleStruct{
              field_two: "hello"
            }
          },
          nested_field_three: [
            %ModuleFormatKebab{
              nested_field_two: %SimpleStruct{
                field_three: random_integer
              }
            },
            %ModuleFormatKebab{
              nested_field_three: [
                %SimpleStruct{
                  field_one: false
                }
              ]
            }
          ]
        }
      )
    end
  end
end
