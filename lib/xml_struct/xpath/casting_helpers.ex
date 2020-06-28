defmodule XmlStruct.Xpath.CastingHelpers do
  def determine_casting([main_selector | nested_selectors], _, %{enforce: false, is_list: true}) do
    updated_selector =
      main_selector
      |> Map.put(:is_optional, true)
      |> Map.put(:is_list, true)

    [updated_selector] ++ nested_selectors
  end

  def determine_casting([main_selector | nested_selectors], _, %{is_list: true}) do
    updated_selector =
      main_selector
      |> Map.put(:is_list, true)

    [updated_selector] ++ nested_selectors
  end

  def determine_casting([main_selector | nested_selectors], _, %{enforce: false}) do
    [Map.put(main_selector, :is_optional, true)] ++ nested_selectors
  end

  def determine_casting(xpath, _, _), do: xpath
  def determine_casting(:integer, %{enforce: true, is_list: true}), do: 'sl'
  def determine_casting(:integer, %{enforce: false, is_list: true}), do: 'slo'
  def determine_casting(:integer, %{enforce: true}), do: 's'
  def determine_casting(:integer, %{enforce: false}), do: 'so'
  def determine_casting(:float, %{enforce: true, is_list: true}), do: 'fl'
  def determine_casting(:float, %{enforce: false, is_list: true}), do: 'flo'
  def determine_casting(:float, %{enforce: true}), do: 'f'
  def determine_casting(:float, %{enforce: false}), do: 'fo'
  def determine_casting(_, %{enforce: true, is_list: true}), do: 'sl'
  def determine_casting(_, %{enforce: false, is_list: true}), do: 'slo'
  def determine_casting(_, %{enforce: true}), do: 's'
  def determine_casting(_, %{enforce: false}), do: 'so'

  def safe_to_atom(nil), do: nil
  def safe_to_atom(""), do: nil
  def safe_to_atom(value), do: String.to_atom(value)
  def safe_to_string(""), do: nil
  def safe_to_string(value), do: value
  def safe_to_integer(""), do: nil
  def safe_to_integer(value) when is_integer(value), do: value

  def safe_to_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      :error -> nil
      {parsed, _unparsed} -> parsed
    end
  end

  def safe_to_boolean(nil), do: nil
  def safe_to_boolean(""), do: nil

  def safe_to_boolean(value) do
    value
    |> String.downcase()
    |> String.to_atom()
  end
end
