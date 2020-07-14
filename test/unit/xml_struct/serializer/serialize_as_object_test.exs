defmodule ObjectFormatTest.FieldFormatOnly do
  use XmlStruct

  xmlstruct do
    field :nested_field_one, SimpleStruct.t(), serialize_as_object: false
    field :nested_field_two, [SimpleStruct.t()], serialize_as_object: false
    field :nested_field_three, boolean()
  end
end

defmodule ObjectFormatTest.FieldFormatOnlyCascade do
  use XmlStruct

  xmlstruct do
    field :root_field_one, NestedSimpleStruct.t(), serialize_as_object: false
    field :root_field_two, [NestedSimpleStruct.t()], serialize_as_object: false
    field :root_field_three, boolean()
  end
end

defmodule ObjectFormatTest.NestedFieldFormatOnlyCascade do
  use XmlStruct

  xmlstruct do
    field :root_field_one, DeeplyNestedSimpleStruct.t(), serialize_as_object: false
    field :root_field_two, [DeeplyNestedSimpleStruct.t()], serialize_as_object: false
    field :root_field_three, boolean()
  end
end

defmodule XmlStruct.Serializer.ObjectFormatTest do
  use ExUnit.Case

  describe "FieldFormatOnly.serialize/1" do
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

  describe "FieldFormatOnlyCascade.serialize/1" do
    test "does not cascade into children who don't specify it further (arrays)" do
      assert %{
        "NestedFieldOne" => false,
        "NestedFieldTwo.FieldOne" => true,
        "NestedFieldTwo.FieldTwo" => "ham",
        "NestedFieldTwo.FieldThree" => 25,
        "NestedFieldOne.member.1" => true,
        "NestedFieldTwo.member.1.FieldOne" => false,
        "NestedFieldTwo.member.1.FieldTwo" => "hello",
        "NestedFieldTwo.member.1.FieldThree" => 35,
        "NestedFieldThree.member.1.member.1.FieldOne" => 65,
        "NestedFieldThree.member.1.member.1.FieldTwo" => "world",
        "NestedFieldThree.member.1.member.1.FieldThree" => true,
        "NestedFieldThree.member.1.member.2.FieldOne" => 45,
        "NestedFieldThree.member.1.member.2.FieldTwo" => "goodbye",
        "NestedFieldThree.member.1.member.2.FieldThree" => false,
        "RootFieldThree" => false
      } == ObjectFormatTest.FieldFormatOnlyCascade.serialize(
        %ObjectFormatTest.FieldFormatOnlyCascade{
          root_field_one: %NestedSimpleStruct{
            nested_field_one: false,
            nested_field_two: %SimpleStruct{
              field_one: true,
              field_two: "ham",
              field_three: 25
            }
          },
          root_field_two: [
            %NestedSimpleStruct{
              nested_field_one: true,
              nested_field_two: %SimpleStruct{
                field_one: false,
                field_two: "hello",
                field_three: 35
              },
              nested_field_three: [
                %SimpleStruct{
                  field_one: 65,
                  field_two: "world",
                  field_three: true
                },
                %SimpleStruct{
                  field_one: 45,
                  field_two: "goodbye",
                  field_three: false
                }
              ]
            }
          ],
          root_field_three: false
        }
      )
    end

    test "does not cascade into children who don't specify it further (single value)" do
      assert %{
        "DeeplyNestedFieldOne" => false,
        "DeeplyNestedFieldTwo.NestedFieldOne" => true,
        "DeeplyNestedFieldTwo.NestedFieldTwo" => "turkey",
        "DeeplyNestedFieldTwo.NestedFieldThree.member.1.FieldOne" => true,
        "DeeplyNestedFieldTwo.NestedFieldThree.member.1.FieldTwo" => "thing",
        "DeeplyNestedFieldTwo.NestedFieldThree.member.1.FieldThree" => 85,
        "DeeplyNestedFieldThree.member.1.FieldOne" => false,
        "DeeplyNestedFieldThree.member.1.FieldTwo" => "test",
        "DeeplyNestedFieldThree.member.1.FieldThree" => 45,
        "DeeplyNestedFieldOne.member.1" => true,
        "DeeplyNestedFieldTwo.member.1.NestedFieldOne" => false,
        "DeeplyNestedFieldTwo.member.1.NestedFieldTwo" => "ham",
        "DeeplyNestedFieldTwo.member.1.NestedFieldThree.member.1.FieldOne" => false,
        "DeeplyNestedFieldTwo.member.1.NestedFieldThree.member.1.FieldTwo" => "stuff",
        "DeeplyNestedFieldTwo.member.1.NestedFieldThree.member.1.FieldThree" => 75,
        "DeeplyNestedFieldThree.member.1.member.1.FieldOne" => true,
        "DeeplyNestedFieldThree.member.1.member.1.FieldTwo" => "suite",
        "DeeplyNestedFieldThree.member.1.member.1.FieldThree" => 15,
        "RootFieldThree" => false
      } == ObjectFormatTest.NestedFieldFormatOnlyCascade.serialize(
        %ObjectFormatTest.NestedFieldFormatOnlyCascade{
          root_field_one: %DeeplyNestedSimpleStruct{
            deeply_nested_field_one: false,
            deeply_nested_field_two: %NestedSimpleStruct{
              nested_field_one: true,
              nested_field_two: "turkey",
              nested_field_three: [
                %SimpleStruct{
                  field_one: true,
                  field_two: "thing",
                  field_three: 85
                }
              ]
            },
            deeply_nested_field_three: [
              %SimpleStruct{
                field_one: false,
                field_two: "test",
                field_three: 45
              }
            ]
          },
          root_field_two: [
            %DeeplyNestedSimpleStruct{
              deeply_nested_field_one: true,
              deeply_nested_field_two: %NestedSimpleStruct{
                nested_field_one: false,
                nested_field_two: "ham",
                nested_field_three: [
                  %SimpleStruct{
                    field_one: false,
                    field_two: "stuff",
                    field_three: 75
                  }
                ]
              },
              deeply_nested_field_three: [
                %SimpleStruct{
                  field_one: true,
                  field_two: "suite",
                  field_three: 15
                }
              ]
            }
          ],
          root_field_three: false
        }
      )
    end
  end
end
