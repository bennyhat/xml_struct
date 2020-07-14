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

  describe "DeeplyNestedSimpleStruct.deserialize/1" do
    test "deserializes nested structs" do
      assert %DeeplyNestedSimpleStruct{
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
              field_three: 35
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
                field_three: 20
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
                field_three: 25
              }
            ]
          }
        ]
      } == DeeplyNestedSimpleStruct.deserialize(
        """
        <DeeplyNestedSimpleStruct>
          <DeeplyNestedFieldOne>true</DeeplyNestedFieldOne>
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
                <FieldThree>35</FieldThree>
              </member>
            </SimpleStructs>
          </NestedSimpleStruct>
          <NestedSimpleStructs>
            <member>
              <NestedFieldOne>true</NestedFieldOne>
              <SimpleStruct>
                <FieldTwo>world</FieldTwo>
              </SimpleStruct>
              <SimpleStructs>
                <member>
                  <FieldOne>false</FieldOne>
                </member>
                <member>
                  <FieldThree>20</FieldThree>
                </member>
              </SimpleStructs>
            </member>
            <member>
              <NestedFieldOne>false</NestedFieldOne>
              <SimpleStruct>
                <FieldTwo>things</FieldTwo>
              </SimpleStruct>
              <SimpleStructs>
                <member>
                  <FieldOne>true</FieldOne>
                </member>
                <member>
                  <FieldThree>25</FieldThree>
                </member>
              </SimpleStructs>
            </member>
          </NestedSimpleStructs>
        </DeeplyNestedSimpleStruct>
        """
      )
    end
  end
end
