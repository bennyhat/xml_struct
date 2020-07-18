defmodule XmlStruct.Deserializer.TagTest do
  use ExUnit.Case

  describe "ModuleFormatCamel.deserialize/1" do
    test "deserializes xml with tags in camel case" do
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
  end

  describe "ModuleFormatKebab.deserialize/1" do
    test "deserializes xml with tags in kebab case" do
      assert %ModuleFormatKebab{
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
      } == ModuleFormatKebab.deserialize(
        """
        <module-format-kebab>
          <nested-field-one>true</nested-field-one>
          <simple-struct>
            <field-one>false</field-one>
            <field-two>stuff</field-two>
            <field-three>10</field-three>
          </simple-struct>
          <simple-structs>
            <member>
              <field-one>true</field-one>
              <field-two>more</field-two>
              <field-three>15</field-three>
            </member>
            <member>
              <field-one>false</field-one>
              <field-two>thingy</field-two>
              <field-three>25</field-three>
            </member>
          </simple-structs>
        </module-format-kebab>
        """
      )
    end
  end

  describe "ModuleFormatSnake.deserialize/1" do
    test "deserializes xml with tags in kebab case" do
      assert %ModuleFormatSnake{
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
      } == ModuleFormatSnake.deserialize(
        """
        <module_format_snake>
          <nested_field_one>true</nested_field_one>
          <simple_struct>
            <field_one>false</field_one>
            <field_two>stuff</field_two>
            <field_three>10</field_three>
          </simple_struct>
          <simple_structs>
            <member>
              <field_one>true</field_one>
              <field_two>more</field_two>
              <field_three>15</field_three>
            </member>
            <member>
              <field_one>false</field_one>
              <field_two>thingy</field_two>
              <field_three>25</field_three>
            </member>
          </simple_structs>
        </module_format_snake>
        """
      )
    end
  end

  describe "ModuleFormatCamelChildModuleFormatVarious.deserialize/1" do
    test "deserializes with a module-level tag format" do
      assert %ModuleFormatCamelChildModuleFormatVarious{
        nested_field_one: true,
        nested_field_two: %ModuleFormatSnake{
          nested_field_two: %SimpleStruct{
            field_two: "hello"
          },
          nested_field_three: [] # TODO - change this
        },
        nested_field_three: [
          %ModuleFormatKebab{
            nested_field_two: %SimpleStruct{
              field_three: 15
            },
            nested_field_three: [] # TODO - change this
          },
          %ModuleFormatKebab{
            nested_field_three: [
              %SimpleStruct{
                field_one: false
              }
            ]
          }
        ]
      } == ModuleFormatCamelChildModuleFormatVarious.deserialize(
        """
        <moduleFormatCamelChildModuleFormatVarious>
          <nestedFieldOne>true</nestedFieldOne>
          <module_format_snake>
            <simple_struct>
              <field_two>hello</field_two>
            </simple_struct>
          </module_format_snake>
          <module-format-kebabs>
            <member>
              <simple-struct>
                <field-three>15</field-three>
              </simple-struct>
            </member>
            <member>
              <simple-structs>
                <member>
                  <field-one>false</field-one>
                </member>
              </simple-structs>
            </member>
          </module-format-kebabs>
        </moduleFormatCamelChildModuleFormatVarious>
        """
      )
    end
  end

  describe "ModuleFormatCamelChildFieldFormatVarious.deserialize/1" do
    test "deserializes with a module-level tag format and field format children" do
      assert %ModuleFormatCamelChildFieldFormatVarious{
        nested_field_one: true,
        nested_field_two: %ModuleFormatSnake{
          nested_field_two: %SimpleStruct{
            field_two: "hello"
          },
          nested_field_three: [] # TODO - change this
        },
        nested_field_three: [
          %ModuleFormatKebab{
            nested_field_two: %SimpleStruct{
              field_three: 35
            },
            nested_field_three: [] # TODO - change this
          },
          %ModuleFormatKebab{
            nested_field_three: [
              %SimpleStruct{
                field_one: false
              }
            ]
          }
        ]
      } == ModuleFormatCamelChildFieldFormatVarious.deserialize(
        """
        <moduleFormatCamelChildFieldFormatVarious>
          <nestedFieldOne>true</nestedFieldOne>
          <module_format_snake>
            <simple_struct>
              <field_two>hello</field_two>
            </simple_struct>
          </module_format_snake>
          <ModuleFormatKebabs>
            <member>
              <simple-struct>
                <field-three>35</field-three>
              </simple-struct>
            </member>
            <member>
              <simple-structs>
                <member>
                  <field-one>false</field-one>
                </member>
              </simple-structs>
            </member>
          </ModuleFormatKebabs>
        </moduleFormatCamelChildFieldFormatVarious>
        """
      )
    end
  end
end
