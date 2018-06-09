Code.require_file "test_helper.exs", __DIR__

defmodule MustacheUtilTest do
  use ExUnit.Case

  test "render simple using lists" do
    assert MustacheUtil.render("Hello, {{name}}", [name: "MustacheUtil"]) == "Hello, MustacheUtil"
  end

  test "render multi line using lists" do
    assert MustacheUtil.render("Hello\n{{name}}", [name: "MustacheUtil"]) == "Hello\nMustacheUtil"
  end

  test "render with nested context using lists" do
    assert MustacheUtil.render("{{#a}}{{#b}}MustacheUtil{{/b}}{{/a}}", [a: true, b: true]) == "MustacheUtil"
  end

  test "render nil using lists" do
    assert MustacheUtil.render("Hello, {{name}}", [name: nil]) == "Hello, "
  end
  test "render missing variable using lists" do
    assert MustacheUtil.render("Hello, {{name}}", []) == "Hello, "
  end

  test "render unescaped using lists" do
    assert MustacheUtil.render("{{{string}}}", [string: "&\'\"<>"]) == "&\'\"<>"
  end

  test "render unescaped ampersand using lists" do
    assert MustacheUtil.render("{{{string}}}", [string: "&\'\"<>"]) == "&\'\"<>"
  end

  test "render escaped using lists" do
    assert MustacheUtil.render("{{string}}", [string: "&\'\"<>"]) == "&amp;&#39;&quot;&lt;&gt;"
  end

  test "render list using lists" do
    assert MustacheUtil.render("Hello{{#names}}, {{name}}{{/names}}", [names: [[name: "MustacheUtil"], [name: "Elixir"]]]) == "Hello, MustacheUtil, Elixir"
  end

  test "render list twice using lists" do
    assert MustacheUtil.render("Hello{{#names}}, {{name}}{{/names}}! Hello{{#names}}, {{name}}{{/names}}!", [names: [[name: "MustacheUtil"], [name: "Elixir"]]]) == "Hello, MustacheUtil, Elixir! Hello, MustacheUtil, Elixir!"
  end

  test "render single value using lists" do
    assert MustacheUtil.render("Hello{{#person}}, {{name}}{{/person}}!", [person: [name: "MustacheUtil"]]) == "Hello, MustacheUtil!"
  end

  test "render empty list using lists" do
    assert MustacheUtil.render("{{#things}}something{{/things}}", [things: []]) == ""
  end

  test "render nested list using lists" do
    assert MustacheUtil.render("{{#x}}{{#y}}{{z}}{{/y}}{{/x}}", [x: [y: [z: "z"]]]) == "z"
  end

  test "render comment using lists" do
    assert MustacheUtil.render("Hello, {{! comment }}{{name}}", [name: "MustacheUtil"]) == "Hello, MustacheUtil"
  end

  test "render tags with whitespace using lists" do
    assert MustacheUtil.render("Hello, {{# names }}{{ name }}{{/ names }}", [names: [[name: "MustacheUtil"]]]) == "Hello, MustacheUtil"
  end

  test "render true section using lists" do
    assert MustacheUtil.render("Hello, {{#bool}}MustacheUtil{{/bool}}", [bool: true]) == "Hello, MustacheUtil"
  end

  test "render false section using lists" do
    assert MustacheUtil.render("Hello, {{#bool}}MustacheUtil{{/bool}}", [bool: false]) == "Hello, "
  end

  test "render inverted empty list using lists" do
    assert MustacheUtil.render("{{^things}}Empty{{/things}}", [thins: []]) == "Empty"
  end

  test "render inverted list using lists" do
    assert MustacheUtil.render("{{^things}}Empty{{/things}}", [things: ["yeah"]]) == ""
  end

  test "render inverted true section using lists" do
    assert MustacheUtil.render("Hello, {{^bool}}MustacheUtil{{/bool}}", [bool: true]) == "Hello, "
  end

  test "render inverted false section using lists" do
    assert MustacheUtil.render("Hello, {{^bool}}MustacheUtil{{/bool}}", [bool: false]) == "Hello, MustacheUtil"
  end

  test "render dotted name using lists" do
    assert MustacheUtil.render("Hello, {{cool.mustache.name}}", [cool: [mustache: [name: "MustacheUtil"]]]) == "Hello, MustacheUtil"
  end

  test "render dotted name section using lists" do
    assert MustacheUtil.render("Hello, {{#person.name}}MustacheUtil{{/person.name}}", [person: [name: true]]) == "Hello, MustacheUtil"
  end

  test "render dotted name inverted section using lists" do
    assert MustacheUtil.render("Hello, {{#person.name}}MustacheUtil{{/person.name}}", [people: [names: true]]) == "Hello, "
  end

  test "render implicit iterator using lists" do
    assert MustacheUtil.render("Hello{{#names}}, {{.}}{{/names}}!", [names: ["MustacheUtil", "Elixir"]]) == "Hello, MustacheUtil, Elixir!"
  end

  test "render lambda using lists" do
    assert MustacheUtil.render("Hello, {{name}}", [name: fn -> "MustacheUtil" end]) == "Hello, MustacheUtil"
  end

  test "render partial using lists" do
    assert MustacheUtil.render("Hello, {{>name}}", [n: "MustacheUtil"], partials: [name: "{{n}}"]) == "Hello, MustacheUtil"
  end

  test "render with boolean true" do
    template = """
    Hello {{name}}
    You have just won {{value}} dollars!
    {{#in_ca}}
    Well, {{taxed_value}} dollars, after taxes.
    {{/in_ca}}
    """

    expected = """
    Hello Chris
    You have just won 10000 dollars!

    Well, 6.0e3 dollars, after taxes.

    """

    assert MustacheUtil.render(template, %{
      name: "Chris",
      value: 10000,
      taxed_value: 10000 - (10000 * 0.4),
      in_ca: true
    }) == expected
  end

  test "render with boolean false" do
    template = """
    Hello {{name}}
    You have just won {{value}} dollars!
    {{#in_ca}}
    Well, {{taxed_value}} dollars, after taxes.
    {{/in_ca}}
    """

    expected = """
    Hello Chris
    You have just won 10000 dollars!

    """

    assert MustacheUtil.render(template, %{
      name: "Chris",
      value: 10000,
      taxed_value: 10000 - (10000 * 0.4),
      in_ca: false
    }) == expected
  end

  test "render looooong using lists" do
    template = """
    {{! ignore this line! }}
    Hello {{name}}
    {{! ignore this line! }}
    You have just won {{value}} dollars!
    {{#in_ca}}
    Well, {{taxed_value}} dollars, after taxes.
    {{/in_ca}}
    a{{! dont ignore this line! }}
    """

    expected = """

    Hello mururu

    You have just won 1000 dollars!

    Well, 50 dollars, after taxes.

    Well, 40 dollars, after taxes.

    a
    """

    assert MustacheUtil.render(template, [name: "mururu", value: 1000, in_ca: [[taxed_value: 50], [taxed_value: 40]]]) == expected
  end


  test "render simple using maps" do
    assert MustacheUtil.render("Hello, {{name}}", %{name: "MustacheUtil"}) == "Hello, MustacheUtil"
  end

  test "render multi line using maps" do
    assert MustacheUtil.render("Hello\n{{name}}", %{name: "MustacheUtil"}) == "Hello\nMustacheUtil"
  end

  test "render with nested context using maps" do
    assert MustacheUtil.render("{{#a}}{{#b}}MustacheUtil{{/b}}{{/a}}", %{a: true, b: true}) == "MustacheUtil"
  end

  test "render nil using maps" do
    assert MustacheUtil.render("Hello, {{name}}", %{name: nil}) == "Hello, "
  end
  test "render missing variable using maps" do
    assert MustacheUtil.render("Hello, {{name}}", %{}) == "Hello, "
  end

  test "render unescaped using maps" do
    assert MustacheUtil.render("{{{string}}}", %{string: "&\'\"<>"}) == "&\'\"<>"
  end

  test "render unescaped ampersand using maps" do
    assert MustacheUtil.render("{{{string}}}", %{string: "&\'\"<>"}) == "&\'\"<>"
  end

  test "render escaped using maps" do
    assert MustacheUtil.render("{{string}}", %{string: "&\'\"<>"}) == "&amp;&#39;&quot;&lt;&gt;"
  end

  test "render list using maps" do
    assert MustacheUtil.render("Hello{{#names}}, {{name}}{{/names}}", %{names: [%{name: "MustacheUtil"}, %{name: "Elixir"}]}) == "Hello, MustacheUtil, Elixir"
  end

  test "render list twice using maps" do
    assert MustacheUtil.render("Hello{{#names}}, {{name}}{{/names}}! Hello{{#names}}, {{name}}{{/names}}!", %{names: [%{name: "MustacheUtil"}, %{name: "Elixir"}]}) == "Hello, MustacheUtil, Elixir! Hello, MustacheUtil, Elixir!"
  end

  test "render single value using maps" do
    assert MustacheUtil.render("Hello{{#person}}, {{name}}{{/person}}!", %{person: %{name: "MustacheUtil"}}) == "Hello, MustacheUtil!"
  end

  test "render empty list using maps" do
    assert MustacheUtil.render("{{#things}}something{{/things}}", %{things: []}) == ""
  end

  test "render nested list using maps" do
    assert MustacheUtil.render("{{#x}}{{#y}}{{z}}{{/y}}{{/x}}", %{x: %{y: %{z: "z"}}}) == "z"
  end

  test "render comment using maps" do
    assert MustacheUtil.render("Hello, {{! comment }}{{name}}", %{name: "MustacheUtil"}) == "Hello, MustacheUtil"
  end

  test "render tags with whitespace using maps" do
    assert MustacheUtil.render("Hello, {{# names }}{{ name }}{{/ names }}", %{names: [%{name: "MustacheUtil"}]}) == "Hello, MustacheUtil"
  end

  test "render true section using maps" do
    assert MustacheUtil.render("Hello, {{#bool}}MustacheUtil{{/bool}}", %{bool: true}) == "Hello, MustacheUtil"
  end

  test "render false section using maps" do
    assert MustacheUtil.render("Hello, {{#bool}}MustacheUtil{{/bool}}", %{bool: false}) == "Hello, "
  end

  test "render inverted empty list using maps" do
    assert MustacheUtil.render("{{^things}}Empty{{/things}}", %{thins: []}) == "Empty"
  end

  test "render inverted list using maps" do
    assert MustacheUtil.render("{{^things}}Empty{{/things}}", %{things: ["yeah"]}) == ""
  end

  test "render inverted true section using maps" do
    assert MustacheUtil.render("Hello, {{^bool}}MustacheUtil{{/bool}}", %{bool: true}) == "Hello, "
  end

  test "render inverted false section using maps" do
    assert MustacheUtil.render("Hello, {{^bool}}MustacheUtil{{/bool}}", %{bool: false}) == "Hello, MustacheUtil"
  end

  test "render dotted name using maps" do
    assert MustacheUtil.render("Hello, {{cool.mustache.name}}", %{cool: %{mustache: %{name: "MustacheUtil"}}}) == "Hello, MustacheUtil"
  end

  test "render dotted name section using maps" do
    assert MustacheUtil.render("Hello, {{#person.name}}MustacheUtil{{/person.name}}", %{person: %{name: true}}) == "Hello, MustacheUtil"
  end

  test "render dotted name inverted section using maps" do
    assert MustacheUtil.render("Hello, {{#person.name}}MustacheUtil{{/person.name}}", %{people: %{names: true}}) == "Hello, "
  end

  test "render implicit iterator using maps" do
    assert MustacheUtil.render("Hello{{#names}}, {{.}}{{/names}}!", %{names: ["MustacheUtil", "Elixir"]}) == "Hello, MustacheUtil, Elixir!"
  end

  test "render lambda using maps" do
    assert MustacheUtil.render("Hello, {{name}}", %{name: fn -> "MustacheUtil" end}) == "Hello, MustacheUtil"
  end

  test "render partial using maps" do
    assert MustacheUtil.render("Hello, {{>name}}", %{n: "MustacheUtil"}, partials: %{name: "{{n}}"}) == "Hello, MustacheUtil"
  end

  test "render looooong using maps" do
    template = """
    {{! ignore this line! }}
    Hello {{name}}
    {{! ignore this line! }}
    You have just won {{value}} dollars!
    {{#in_ca}}
    Well, {{taxed_value}} dollars, after taxes.
    {{/in_ca}}
    a{{! dont ignore this line! }}
    """

    expected = """

    Hello mururu

    You have just won 1000 dollars!

    Well, 50 dollars, after taxes.

    Well, 40 dollars, after taxes.

    a
    """

    assert MustacheUtil.render(template, %{name: "mururu", value: 1000, in_ca: [%{taxed_value: 50}, %{taxed_value: 40}]}) == expected
  end
end
