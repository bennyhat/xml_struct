defmodule XmlStruct.Deserializer do
  def deserialize(_module, {root_selector, nested_selectors}, xml) do
    SweetXml.xpath(xml, root_selector, nested_selectors)
  end
end
