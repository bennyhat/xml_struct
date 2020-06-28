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

defmodule XmlStructTest do
  use ExUnit.Case
  doctest XmlStruct

  describe "SimpleStruct.serialize/1" do
    test "creates a camelized map that can easily be converted to JSON" do
      random_integer = Faker.random_between(1, 10)
      assert %{
        "FieldOne" => true,
        "FieldTwo" => "hello",
        "FieldThree" => random_integer
      } == SimpleStruct.serialize(
        %SimpleStruct{
          field_one: true,
          field_two: "hello",
          field_three: random_integer
        }
      )
    end

    test "omits nil fields" do
      assert %{
        "FieldOne" => true,
        "FieldTwo" => "hello"
      } == SimpleStruct.serialize(
        %SimpleStruct{
          field_one: true,
          field_two: "hello",
          field_three: nil
        }
      )
    end
  end

  describe "NestedSimpleStruct.serialize/1" do
    test "brings all leaf level fields up to top level (producing weird results)" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "NestedFieldOne" => true,
        "NestedFieldThree.member.1.FieldOne" => false,
        "NestedFieldThree.member.2.FieldThree" => random_integer,
        "NestedFieldTwo.FieldTwo" => "goodbye"} == NestedSimpleStruct.serialize(
        %NestedSimpleStruct{
          nested_field_one: true,
          nested_field_two: %SimpleStruct{
            field_two: "goodbye"
          },
          nested_field_three: [
            %SimpleStruct{
              field_one: false
            },
            %SimpleStruct{
              field_three: random_integer
            }
          ]
        }
      )
    end
  end

  describe "DeeplyNestedSimpleStruct.serialize/1" do
    test "serializes nested structs as objects" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "DeeplyNestedFieldOne" => true,
        "DeeplyNestedFieldThree.member.1.NestedFieldOne" => true,
        "DeeplyNestedFieldThree.member.1.NestedFieldThree.member.1.FieldOne" => false,
        "DeeplyNestedFieldThree.member.1.NestedFieldThree.member.2.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.member.1.NestedFieldTwo.FieldTwo" => "world",
        "DeeplyNestedFieldThree.member.2.NestedFieldOne" => false,
        "DeeplyNestedFieldThree.member.2.NestedFieldThree.member.1.FieldOne" => true,
        "DeeplyNestedFieldThree.member.2.NestedFieldThree.member.2.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.member.2.NestedFieldTwo.FieldTwo" => "things",
        "DeeplyNestedFieldTwo.NestedFieldOne" => true,
        "DeeplyNestedFieldTwo.NestedFieldThree.member.1.FieldOne" => false,
        "DeeplyNestedFieldTwo.NestedFieldThree.member.2.FieldThree" => random_integer,
        "DeeplyNestedFieldTwo.NestedFieldTwo.FieldTwo" => "goodbye"} == DeeplyNestedSimpleStruct.serialize(
        %DeeplyNestedSimpleStruct{
          deeply_nested_field_one: true,
          deeply_nested_field_two: %NestedSimpleStruct{
            nested_field_one: true,
            nested_field_two: %SimpleStruct{
              field_two: "goodbye"
            },
            nested_field_three: [
              %SimpleStruct{
                field_one: false
              },
              %SimpleStruct{
                field_three: random_integer
              }
            ]
          },
          deeply_nested_field_three: [
            %NestedSimpleStruct{
              nested_field_one: true,
              nested_field_two: %SimpleStruct{
                field_two: "world"
              },
              nested_field_three: [
                %SimpleStruct{
                  field_one: false
                },
                %SimpleStruct{
                  field_three: random_integer
                }
              ]
            },
            %NestedSimpleStruct{
              nested_field_one: false,
              nested_field_two: %SimpleStruct{
                field_two: "things"
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
          ]
        }
      )
    end
  end
end
