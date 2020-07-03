defmodule PrefixTest.ModulePrefixThing do
  use XmlStruct

  xmlstruct list_prefix: "thing" do
    field :nested_field_one, boolean()
    field :nested_field_two, SimpleStruct.t()
    field :nested_field_three, [SimpleStruct.t()]
  end
end

defmodule  PrefixTest.ModulePrefixItem do
  use XmlStruct

  xmlstruct list_prefix: "item" do
    field :deeply_nested_field_one, boolean()
    field :deeply_nested_field_two, NestedSimpleStruct.t()
    field :deeply_nested_field_three, [NestedSimpleStruct.t()]
  end
end

defmodule PrefixTest.ModulePrefixItemChildModulePrefixThing do
  use XmlStruct

  xmlstruct list_prefix: "item" do
    field :deeply_nested_field_one, boolean()
    field :deeply_nested_field_two, [NestedSimpleStruct.t()]
    field :deeply_nested_field_three, [PrefixTest.ModulePrefixThing.t()]
  end
end

defmodule PrefixTest.ModulePrefixItemChildFieldPrefixThing do
  use XmlStruct

  xmlstruct list_prefix: "item" do
    field :deeply_nested_field_one, boolean()
    field :deeply_nested_field_two, [NestedSimpleStruct.t()]
    field :deeply_nested_field_three, [NestedSimpleStruct.t()], list_prefix: "thing"
  end
end

defmodule PrefixTest.ModulePrefixItemChildFieldPrefixStuff do
  use XmlStruct

  xmlstruct list_prefix: "item" do
    field :deeply_nested_field_one, boolean()
    field :deeply_nested_field_two, [NestedSimpleStruct.t()]
    field :deeply_nested_field_three, [PrefixTest.ModulePrefixThing.t()], list_prefix: "stuff"
  end
end

defmodule PrefixTest do
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
    test "serializes nested structs as objects" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "NestedFieldOne" => true,
        "NestedFieldTwo.FieldTwo" => "goodbye",
        "NestedFieldThree.member.1.FieldOne" => false,
        "NestedFieldThree.member.2.FieldThree" => random_integer
      } == NestedSimpleStruct.serialize(
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
        "DeeplyNestedFieldTwo.NestedFieldOne" => true,
        "DeeplyNestedFieldTwo.NestedFieldThree.member.1.FieldOne" => false,
        "DeeplyNestedFieldTwo.NestedFieldThree.member.2.FieldThree" => random_integer,
        "DeeplyNestedFieldTwo.NestedFieldTwo.FieldTwo" => "goodbye",
        "DeeplyNestedFieldThree.member.1.NestedFieldOne" => true,
        "DeeplyNestedFieldThree.member.1.NestedFieldThree.member.1.FieldOne" => false,
        "DeeplyNestedFieldThree.member.1.NestedFieldThree.member.2.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.member.1.NestedFieldTwo.FieldTwo" => "world",
        "DeeplyNestedFieldThree.member.2.NestedFieldOne" => false,
        "DeeplyNestedFieldThree.member.2.NestedFieldThree.member.1.FieldOne" => true,
        "DeeplyNestedFieldThree.member.2.NestedFieldThree.member.2.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.member.2.NestedFieldTwo.FieldTwo" => "things"
      } == DeeplyNestedSimpleStruct.serialize(
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

  describe "PrefixTest.ModulePrefix.serialize/1" do
    test "serializes with a module-wide list prefix" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "DeeplyNestedFieldOne" => true,
        "DeeplyNestedFieldTwo.item.1.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.item.1.NestedFieldOne" => true,
        "DeeplyNestedFieldThree.item.1.NestedFieldThree.item.1.FieldOne" => false,
        "DeeplyNestedFieldThree.item.1.NestedFieldThree.item.2.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.item.1.NestedFieldTwo.FieldTwo" => "world",
        "DeeplyNestedFieldThree.item.2.NestedFieldOne" => false,
        "DeeplyNestedFieldThree.item.2.NestedFieldThree.item.1.FieldOne" => true,
        "DeeplyNestedFieldThree.item.2.NestedFieldThree.item.2.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.item.2.NestedFieldTwo.FieldTwo" => "things"
      } == PrefixTest.ModulePrefixItem.serialize(
        %PrefixTest.ModulePrefixItem{
          deeply_nested_field_one: true,
          deeply_nested_field_two: [
            %SimpleStruct{
              field_three: random_integer
            }
          ],
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

    test "does not override lower level settings" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "DeeplyNestedFieldOne" => true,
        "DeeplyNestedFieldTwo.item.1.NestedFieldOne" => true,
        "DeeplyNestedFieldTwo.item.1.NestedFieldThree.thing.1.FieldOne" => false,
        "DeeplyNestedFieldTwo.item.1.NestedFieldThree.thing.2.FieldThree" => random_integer,
        "DeeplyNestedFieldTwo.item.1.NestedFieldTwo.FieldTwo" => "goodbye",
        "DeeplyNestedFieldThree.item.1.NestedFieldOne" => true,
        "DeeplyNestedFieldThree.item.1.NestedFieldThree.thing.1.FieldOne" => false,
        "DeeplyNestedFieldThree.item.1.NestedFieldThree.thing.2.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.item.1.NestedFieldTwo.FieldTwo" => "world",
        "DeeplyNestedFieldThree.item.2.NestedFieldOne" => false,
        "DeeplyNestedFieldThree.item.2.NestedFieldThree.thing.1.FieldOne" => true,
        "DeeplyNestedFieldThree.item.2.NestedFieldThree.thing.2.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.item.2.NestedFieldTwo.FieldTwo" => "things"
      } == PrefixTest.ModulePrefixItemChildModulePrefixThing.serialize(
        %PrefixTest.ModulePrefixItemChildModulePrefixThing{
          deeply_nested_field_one: true,
          deeply_nested_field_two: [
            %PrefixTest.ModulePrefixThing{
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
          ],
          deeply_nested_field_three: [
            %PrefixTest.ModulePrefixThing{
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
            %PrefixTest.ModulePrefixThing{
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

  describe "PrefixTest.ModulePrefixItemChildFieldPrefixThing.serialize/1" do
    test "serializes with a field-level list prefix" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "DeeplyNestedFieldOne" => true,
        "DeeplyNestedFieldTwo.item.1.NestedFieldOne" => true,
        "DeeplyNestedFieldTwo.item.1.NestedFieldThree.item.1.FieldOne" => false,
        "DeeplyNestedFieldTwo.item.1.NestedFieldThree.item.2.FieldThree" => random_integer,
        "DeeplyNestedFieldTwo.item.1.NestedFieldTwo.FieldTwo" => "goodbye",
        "DeeplyNestedFieldThree.thing.1.NestedFieldOne" => true,
        "DeeplyNestedFieldThree.thing.1.NestedFieldThree.thing.1.FieldOne" => false,
        "DeeplyNestedFieldThree.thing.1.NestedFieldThree.thing.2.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.thing.1.NestedFieldTwo.FieldTwo" => "world",
        "DeeplyNestedFieldThree.thing.2.NestedFieldOne" => false,
        "DeeplyNestedFieldThree.thing.2.NestedFieldThree.thing.1.FieldOne" => true,
        "DeeplyNestedFieldThree.thing.2.NestedFieldThree.thing.2.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.thing.2.NestedFieldTwo.FieldTwo" => "things"
      } == PrefixTest.ModulePrefixItemChildFieldPrefixThing.serialize(
        %PrefixTest.ModulePrefixItemChildFieldPrefixThing{
          deeply_nested_field_one: true,
          deeply_nested_field_two: [
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
          ],
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

    test "does not override lower module level settings" do
      random_integer = Faker.random_between(1, 10)

      assert %{
        "DeeplyNestedFieldOne" => true,
        "DeeplyNestedFieldTwo.item.1.NestedFieldOne" => true,
        "DeeplyNestedFieldTwo.item.1.NestedFieldThree.thing.1.FieldOne" => false,
        "DeeplyNestedFieldTwo.item.1.NestedFieldThree.thing.2.FieldThree" => random_integer,
        "DeeplyNestedFieldTwo.item.1.NestedFieldTwo.FieldTwo" => "goodbye",
        "DeeplyNestedFieldThree.stuff.1.NestedFieldOne" => true,
        "DeeplyNestedFieldThree.stuff.1.NestedFieldThree.thing.1.FieldOne" => false,
        "DeeplyNestedFieldThree.stuff.1.NestedFieldThree.thing.2.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.stuff.1.NestedFieldTwo.FieldTwo" => "world",
        "DeeplyNestedFieldThree.stuff.2.NestedFieldOne" => false,
        "DeeplyNestedFieldThree.stuff.2.NestedFieldThree.thing.1.FieldOne" => true,
        "DeeplyNestedFieldThree.stuff.2.NestedFieldThree.thing.2.FieldThree" => random_integer,
        "DeeplyNestedFieldThree.stuff.2.NestedFieldTwo.FieldTwo" => "things"
      } == PrefixTest.ModulePrefixItemChildFieldPrefixStuff.serialize(
        %PrefixTest.ModulePrefixItemChildFieldPrefixStuff{
          deeply_nested_field_one: true,
          deeply_nested_field_two: [
            %PrefixTest.ModulePrefixThing{
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
          ],
          deeply_nested_field_three: [
            %PrefixTest.ModulePrefixThing{
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
            %PrefixTest.ModulePrefixThing{
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
