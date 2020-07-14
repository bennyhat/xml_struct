defmodule XmlStruct.Deserializer.BasicStructTest do
  use ExUnit.Case

  describe "SimpleStruct.deserialize/1" do
    test "turns a conventially defined chunk of XML into a struct" do
      assert %SimpleStruct{
        field_one: true,
        field_two: "hello",
        field_three: 15
      } == SimpleStruct.deserialize(
        """
        <SimpleStruct>
          <FieldOne>true</FieldOne>
          <FieldTwo>hello</FieldTwo>
          <FieldThree>15</FieldThree>
        </SimpleStruct>
        """
      )
    end

    test "omits missing fields" do
      assert %SimpleStruct{
        field_one: false,
        field_three: 25
      } == SimpleStruct.deserialize(
        """
        <SimpleStruct>
          <FieldOne>false</FieldOne>
          <FieldThree>25</FieldThree>
        </SimpleStruct>
        """
      )
    end
  end

  describe "NestedSimpleStruct.deserialize/1" do
    test "deserializes nested structs" do
      assert %NestedSimpleStruct{
        nested_field_one: true,
        nested_field_two: %SimpleStruct{
          field_two: "goodbye"
        },
        nested_field_three: [
          %SimpleStruct{
            field_one: false
          },
          %SimpleStruct{
            field_three: 25
          }
        ]
      } == NestedSimpleStruct.deserialize(
        """
        <NestedSimpleStruct>
          <NestedFieldOne>true</NestedFieldOne>
          <SimpleStruct>
            <FieldTwo>goodbye</FieldTwo>
          </SimpleStruct>
          <SimpleStructs>
            <member>
              <FieldOne>false</FieldOne>
            </member>
            <member>
              <FieldThree>25</FieldThree>
            </member>
          </SimpleStructs>
        </NestedSimpleStruct>
        """
      )
    end
  end

  # describe "DeeplyNestedSimpleStruct.serialize/1" do
  #   test "serializes nested structs as objects" do
  #     random_integer = Faker.random_between(1, 10)

  #     assert %{
  #       "DeeplyNestedFieldOne" => true,
  #       "DeeplyNestedFieldTwo.NestedFieldOne" => true,
  #       "DeeplyNestedFieldTwo.NestedFieldThree.member.1.FieldOne" => false,
  #       "DeeplyNestedFieldTwo.NestedFieldThree.member.2.FieldThree" => random_integer,
  #       "DeeplyNestedFieldTwo.NestedFieldTwo.FieldTwo" => "goodbye",
  #       "DeeplyNestedFieldThree.member.1.NestedFieldOne" => true,
  #       "DeeplyNestedFieldThree.member.1.NestedFieldThree.member.1.FieldOne" => false,
  #       "DeeplyNestedFieldThree.member.1.NestedFieldThree.member.2.FieldThree" => random_integer,
  #       "DeeplyNestedFieldThree.member.1.NestedFieldTwo.FieldTwo" => "world",
  #       "DeeplyNestedFieldThree.member.2.NestedFieldOne" => false,
  #       "DeeplyNestedFieldThree.member.2.NestedFieldThree.member.1.FieldOne" => true,
  #       "DeeplyNestedFieldThree.member.2.NestedFieldThree.member.2.FieldThree" => random_integer,
  #       "DeeplyNestedFieldThree.member.2.NestedFieldTwo.FieldTwo" => "things"
  #     } == DeeplyNestedSimpleStruct.serialize(
  #       %DeeplyNestedSimpleStruct{
  #         deeply_nested_field_one: true,
  #         deeply_nested_field_two: %NestedSimpleStruct{
  #           nested_field_one: true,
  #           nested_field_two: %SimpleStruct{
  #             field_two: "goodbye"
  #           },
  #           nested_field_three: [
  #             %SimpleStruct{
  #               field_one: false
  #             },
  #             %SimpleStruct{
  #               field_three: random_integer
  #             }
  #           ]
  #         },
  #         deeply_nested_field_three: [
  #           %NestedSimpleStruct{
  #             nested_field_one: true,
  #             nested_field_two: %SimpleStruct{
  #               field_two: "world"
  #             },
  #             nested_field_three: [
  #               %SimpleStruct{
  #                 field_one: false
  #               },
  #               %SimpleStruct{
  #                 field_three: random_integer
  #               }
  #             ]
  #           },
  #           %NestedSimpleStruct{
  #             nested_field_one: false,
  #             nested_field_two: %SimpleStruct{
  #               field_two: "things"
  #             },
  #             nested_field_three: [
  #               %SimpleStruct{
  #                 field_one: true
  #               },
  #               %SimpleStruct{
  #                 field_three: random_integer
  #               }
  #             ]
  #           }
  #         ]
  #       }
  #     )
  #   end
  # end
end
