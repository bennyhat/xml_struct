defmodule XmlStruct.Deserializer.TagTest do
  use ExUnit.Case

  describe "ModuleFormatCamel.deserialize/1" do
    test "" do
      assert %ModuleFormatCamel{
        nested_field_one: true,
        nested_field_two: %SimpleStruct{
          field_one: false,
          field_two: "stuff",
          field_three: 10
        },
        nested_field_three: [
          %SimpleStruct{
            field_one: true,
            field_two: "more",
            field_three: 15
          },
          %SimpleStruct{
            field_one: false,
            field_two: "thingy",
            field_three: 25
          },
        ]
      } == ModuleFormatCamel.deserialize(
        """
        <moduleFormatCamel>
          <nestedFieldOne>true</nestedFieldOne>
          <simpleStruct>
            <fieldOne>false</fieldOne>
            <fieldTwo>stuff</fieldTwo>
            <fieldThree>10</fieldThree>
          </simpleStruct>
          <simpleStructs>
            <member>
              <fieldOne>true</fieldOne>
              <fieldTwo>more</fieldTwo>
              <fieldThree>15</fieldThree>
            </member>
            <member>
              <fieldOne>false</fieldOne>
              <fieldTwo>thingy</fieldTwo>
              <fieldThree>25</fieldThree>
            </member>
          </simpleStructs>
        </moduleFormatCamel>
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
end
