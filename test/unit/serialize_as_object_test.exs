defmodule ObjectFormatTest.FieldFormatOnly do
  use XmlStruct

  xmlstruct do
    field :nested_field_one, SimpleStruct.t(), serialize_as_object: false
    field :nested_field_two, [SimpleStruct.t()], serialize_as_object: false
    field :nested_field_three, boolean()
  end
end

defmodule ObjectFormatTest do
  use ExUnit.Case

  describe "NestedModuleFormatOnly.serialize/1" do
    test "removes parent field name and bumps child field up to parent" do
      assert %{
        "FieldOne" => 50,
        "FieldTwo" => "world",
        "FieldThree" => true,
        "FieldOne.member.1" => 15,
        "FieldTwo.member.1" => "stuff",
        "FieldThree.member.1" => false,
        "FieldOne.member.2" => 35,
        "FieldTwo.member.2" => "things",
        "FieldThree.member.2" => true,
        "NestedFieldThree" => false,
      } == ObjectFormatTest.FieldFormatOnly.serialize(
        %ObjectFormatTest.FieldFormatOnly{
          nested_field_one: %SimpleStruct{
            field_one: 50,
            field_two: "world",
            field_three: true
          },
          nested_field_two: [
            %SimpleStruct{
              field_one: 15,
              field_two: "stuff",
              field_three: false
            },
            %SimpleStruct{
              field_one: 35,
              field_two: "things",
              field_three: true
            }
          ],
          nested_field_three: false
        }
      )
    end
  end
end
