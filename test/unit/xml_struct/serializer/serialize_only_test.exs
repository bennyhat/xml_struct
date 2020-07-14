defmodule SerializeOnlyTest.ModuleSerializeOnly do
  use XmlStruct

  xmlstruct serialize_only: [field_one: "FIELD_ONE", field_two: "field-two"] do
    field :field_one, integer()
    field :field_two, String.t()
    field :field_three, boolean()
  end
end

defmodule SerializeOnlyTest.NestedModuleSerializeOnly do
  use XmlStruct

  xmlstruct serialize_only: [field_one: "fieldOne", field_two: "Field_Two"] do
    field :field_one, integer()
    field :field_two, [SerializeOnlyTest.ModuleSerializeOnly.t()]
    field :field_three, boolean()
  end
end

defmodule SerializeOnlyTest.FieldSerializeOnly do
  use XmlStruct

  xmlstruct do
    field :field_one, integer()
    field :field_two, [SimpleStruct.t()], serialize_only: [field_one: "F1", field_three: "fld3"]
    field :field_three, boolean()
  end
end

defmodule SerializeOnlyTest.NestedFieldSerializeOnly do
  use XmlStruct

  xmlstruct do
    field :field_one, integer()
    field :field_two, [SerializeOnlyTest.FieldSerializeOnly.t()], serialize_only: [field_one: "FORLDYWON", field_two: "FailedToo"]
    field :field_three, boolean()
  end
end

defmodule SerializeOnlyTest.NestedMixedSerializeOnly do
  use XmlStruct

  xmlstruct serialize_only: [field_two: "F2"] do
    field :field_one, integer()
    field :field_two, [SerializeOnlyTest.ModuleSerializeOnly.t()], serialize_only: [field_one: "F1", field_three: "F3"]
    field :field_three, boolean()
  end
end

defmodule XmlStruct.Serializer.SerializeOnlyTest do
  use ExUnit.Case

  describe "ModuleSerializeOnly.serialize/1" do
    test "serializes with a module-level serialize directive" do
      assert %{
        "FIELD_ONE" => 10,
        "field-two" => "stuff"
      } == SerializeOnlyTest.ModuleSerializeOnly.serialize(
        %SerializeOnlyTest.ModuleSerializeOnly{
          field_one: 10,
          field_two: "stuff",
          field_three: false
        }
      )
    end
  end

  describe "NestedModuleSerializeOnly.serialize/1" do
    test "serializes with nested module-level serialize directives" do
      assert %{
        "fieldOne" => 10,
        "Field_Two.member.1.FIELD_ONE" => 20,
        "Field_Two.member.1.field-two" => "things",
        "Field_Two.member.2.FIELD_ONE" => 30,
        "Field_Two.member.2.field-two" => "what"
      } == SerializeOnlyTest.NestedModuleSerializeOnly.serialize(
        %SerializeOnlyTest.NestedModuleSerializeOnly{
          field_one: 10,
          field_two: [
            %SerializeOnlyTest.ModuleSerializeOnly{
              field_one: 20,
              field_two: "things",
              field_three: false
            },
            %SerializeOnlyTest.ModuleSerializeOnly{
              field_one: 30,
              field_two: "what",
              field_three: true
            }
          ],
          field_three: false
        }
      )
    end
  end

  describe "FieldSerializeOnly.serialize/1" do
    test "serializes with a field-level serialize directive" do
      assert %{
        "FieldOne" => 10,
        "FieldTwo.member.1.F1" => false,
        "FieldTwo.member.1.fld3" => 20,
        "FieldTwo.member.2.F1" => true,
        "FieldTwo.member.2.fld3" => 30,
        "FieldThree" => false
      } == SerializeOnlyTest.FieldSerializeOnly.serialize(
        %SerializeOnlyTest.FieldSerializeOnly{
          field_one: 10,
          field_two: [
            %SimpleStruct{
              field_one: false,
              field_two: "things",
              field_three: 20
            },
            %SimpleStruct{
              field_one: true,
              field_two: "what",
              field_three: 30
            }
          ],
          field_three: false
        }
      )
    end
  end

  describe "NestedFieldSerializeOnly.serialize/1" do
    test "serializes with nested field-level serialize directives" do
      assert %{
        "FieldOne" => 10,
        "FieldTwo.member.1.FORLDYWON" => 15,
        "FieldTwo.member.1.FailedToo.member.1.F1" => false,
        "FieldTwo.member.1.FailedToo.member.1.fld3" => 20,
        "FieldTwo.member.1.FailedToo.member.2.F1" => true,
        "FieldTwo.member.1.FailedToo.member.2.fld3" => 30,
        "FieldThree" => false
      } == SerializeOnlyTest.NestedFieldSerializeOnly.serialize(
        %SerializeOnlyTest.NestedFieldSerializeOnly{
          field_one: 10,
          field_two: [
            %SerializeOnlyTest.FieldSerializeOnly{
              field_one: 15,
              field_two: [
                %SimpleStruct{
                  field_one: false,
                  field_two: "things",
                  field_three: 20
                },
                %SimpleStruct{
                  field_one: true,
                  field_two: "what",
                  field_three: 30
                }
              ],
              field_three: true
            }
          ],
          field_three: false
        }
      )
    end
  end

  describe "NestedMixedSerializeOnly.serialize/1" do
    test "module level serialize only overrides parent's field level serialize only" do
      assert %{
        "F2.member.1.FIELD_ONE" => 10,
        "F2.member.1.field-two" => "stuff",
        "F2.member.2.FIELD_ONE" => 20,
        "F2.member.2.field-two" => "things"
      } == SerializeOnlyTest.NestedMixedSerializeOnly.serialize(
        %SerializeOnlyTest.NestedMixedSerializeOnly{
          field_one: 10,
          field_two: [
            %SerializeOnlyTest.ModuleSerializeOnly{
              field_one: 10,
              field_two: "stuff",
              field_three: false
            },
            %SerializeOnlyTest.ModuleSerializeOnly{
              field_one: 20,
              field_two: "things",
              field_three: true
            },
          ],
          field_three: false
        }
      )
    end
  end
end
