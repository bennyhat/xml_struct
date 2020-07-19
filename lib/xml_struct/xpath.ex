defmodule XmlStruct.Xpath do
  import XmlStruct.Xpath.CastingHelpers
  require XmlStruct.Util
  import XmlStruct.Util, only: [recase: 2, replace: 3]

  @default_parent_options %{
    enforce: false,
    tag_format: :pascal_case,
    list_prefix: "member"
  }

  @default_options %{
    enforce: false,
    list_prefix: "member"
  }

  def build_selectors(module, type_listing, attribute_name, options) do
    xpath_selector = xpath(module, type_listing, options)
    Module.put_attribute(module, attribute_name, xpath_selector)
  end

  def xpath(module, types, options) do
    merged_options = Map.merge(@default_parent_options, options)

    nested_paths =
      types
      |> attach_options()
      |> extract_nested_xpath(merged_options)
      |> apply_list_prefix_to_types()
      |> apply_type_transformations()
      |> apply_tag_format_overrides()
      |> apply_selector_overrides()

    [
      create_module_selector(module, merged_options)
    ] ++
      nested_paths
  end

  defp create_module_selector(_module, %{selector_override: selector_override}) do
    selector_override
  end

  defp create_module_selector(module, options) do
    SweetXml.sigil_x(to_path(module, options))
  end

  defp to_path(name, %{tag_format: tag_format}) do
    name_as_string =
      name
      |> to_string()
      |> String.split(".")
      |> List.last()

    "./" <> recase(name_as_string, tag_format)
  end

  defp attach_options(type_list) do
    Enum.map(type_list, &attach_field_options/1)
  end
  defp attach_field_options({name, type, opts}) do
    opts_as_map = Enum.into(opts, %{})
    options = Map.merge(@default_options, opts_as_map)

    {name, type, options}
  end

  defp extract_nested_xpath(type_list, options) do
    Enum.map(type_list, &extract_field_xpath(&1, options))
  end
  defp extract_field_xpath({name, type, opts}, options) do
    Code.ensure_compiled(type)

    merged_options = Map.merge(options, opts)

    case function_exported?(type, :xpath_selector, 0) do
      true ->
        output = apply(type, :xpath_selector, [merged_options])
        {name, type, determine_casting(output, type, opts), opts}

      false ->
        {name, type,
         SweetXml.sigil_x(to_path(name, merged_options), determine_casting(type, opts)), opts}
    end
  end

  defp apply_type_transformations(type_list) do
    Enum.map(type_list, &apply_type_transformation/1)
  end
  defp apply_type_transformation({name, type, selector, %{is_simple_type: true} = opts}) do
    case type do
      :integer ->
        {name, selector |> SweetXml.transform_by(&safe_to_integer/1), opts}

      :boolean ->
        {name, selector |> SweetXml.transform_by(&safe_to_boolean/1), opts}

      _ ->
        {name, selector |> SweetXml.transform_by(&safe_to_atom/1), opts}
    end
  end

  defp apply_type_transformation({name, type, selector, %{enforce: false} = opts}) do
    case type do
      String -> {name, selector |> SweetXml.transform_by(&safe_to_string/1), opts}
      :boolean -> {name, selector |> SweetXml.transform_by(&safe_to_boolean/1), opts}
      _ -> {name, selector, opts}
    end
  end

  defp apply_type_transformation({name, type, selector, opts}) do
    case type do
      :boolean -> {name, selector |> SweetXml.transform_by(&String.to_atom/1), opts}
      _ -> {name, selector, opts}
    end
  end

  defp apply_list_prefix_to_types(type_list) do
    Enum.map(type_list, &apply_list_prefix_to_type/1)
  end
  defp apply_list_prefix_to_type({name, type, selector, %{is_list: true} = opts}) do
    {name, type, as_xml_list(selector, opts), opts}
  end

  defp apply_list_prefix_to_type({name, type, selector, opts}) do
    {name, type, as_xml_element(selector, opts), opts}
  end

  defp apply_selector_overrides(type_list) do
    Enum.map(type_list, &apply_selector_override/1)
  end

  defp recase_selector(selector, tag_format) do
    replace(selector, :path, fn path ->
      split_path = path
      |> to_string()
      |> String.split("/")

      # TODO - clean this crap up
      case split_path do
        [root, field] ->
          formatted_field = recase(field, tag_format)
          [root, formatted_field]
          |> Enum.join("/")
          |> to_charlist()
        [root, field | rest] ->
          formatted_field = recase(field, tag_format)
          [root, formatted_field, rest]
          |> Enum.join("/")
          |> to_charlist()
      end
    end)
  end

  defp apply_tag_format_overrides(type_list) do
    Enum.map(type_list, &apply_tag_format_override/1)
  end
  defp apply_tag_format_override({name, [field_selector | nested_selectors], %{tag_format: tag_format} = options}) do
    {name, [recase_selector(field_selector, tag_format)] ++ nested_selectors, options}
  end
  defp apply_tag_format_override(field), do: field

  defp apply_selector_override({name, [_ | nested_selectors], %{selector_override: override}}),
    do: {name, [override] ++ nested_selectors}

  defp apply_selector_override({name, _, %{selector_override: override}}), do: {name, override}
  defp apply_selector_override({name, selectors, _opts}), do: {name, selectors}

  defp as_xml_list([main_selector | nested_selectors], %{list_prefix: list_prefix}) do
    main_selector_as_list =
      main_selector
      |> Map.update(:path, "", fn path ->
        pluralize(path) ++ '/' ++ String.to_charlist(list_prefix)
      end)

    [main_selector_as_list] ++ nested_selectors
  end

  defp as_xml_list(single_selector, %{list_prefix: list_prefix}) do
    single_selector
    |> Map.update(:path, "", fn path ->
      path ++ '/' ++ String.to_charlist(list_prefix) ++ '/text()'
    end)
  end

  defp as_xml_element([_main_selector | _nested_selectors] = selectors, _opts) do
    selectors
  end

  defp as_xml_element(single_selector, _opts) do
    single_selector
    |> Map.update(:path, "", fn path -> path ++ '/text()' end)
  end

  def adjust_root_selector([%SweetXpath{path: './' ++ rest} = root_selector | nested_selectors]) do
    adjusted_root_selector = Map.put(root_selector, :path, '/' ++ rest)

    {adjusted_root_selector, nested_selectors}
  end

  def adjust_root_selector([root_selector | nested_selectors]),
    do: {root_selector, nested_selectors}

  defp pluralize(phrase) do
    phrase
    |> to_string()
    |> Inflectorex.Regexps.pluralize()
    |> String.to_charlist()
  end
end
