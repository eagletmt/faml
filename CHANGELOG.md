## 0.7.0 (2015-11-30)
- Rewrite AttributeBuilder in C++
    - It improves performance,  memory usage, and readability

## 0.6.5 (2015-11-28)
- Delete falsey values after merging all attributes
    - `%span(foo=true){foo: false}` now renders `<span></span>`, because old attributes have priority even if the value is falsey.
    - https://github.com/eagletmt/faml/pull/43
- Fix duplicated attribute in dynamic attribute
    - `%span{foo: 1, 'foo' => 1+1}` now renders `<span foo='2'></span>` correctly
    - https://github.com/eagletmt/faml/pull/45

## 0.6.4 (2015-11-28)
- Flatten `id` and `class` attributes
    - https://github.com/eagletmt/faml/pull/41

## 0.6.3 (2015-11-22)
- Remove duplicated class in Ruby attribute case
    - `%span.foo{h}` where `h = { class: 'foo bar' }` now renders `<span class='bar foo'></span>` .
    - `%span.foo{class: 'foo bar'}` renders `<span class='bar foo'></span>` since v0.2.12 .

## 0.6.2 (2015-11-22)
- Fix data-id and data-class attribute
    - https://github.com/eagletmt/faml/pull/39
    - It's regression in v0.6.1

## 0.6.1 (2015-11-21)
- Fix handling duplicated old attributes and new attributes
    - https://github.com/eagletmt/faml/pull/37
    - `%span{class: 1}(class: 2)` now renders `<span class='1 2'></span>` . `class` and `id` are correctly merged.
    - `%span{foo: 1}(foo: 2)` now renders `<span foo='1'></span>` . Old attributes has priority over new attributes.

## 0.6.0 (2015-11-21)
- Disable Faml::Helpers by default
    - https://github.com/eagletmt/faml/pull/35
    - Set `Faml::Engine.options[:extend_helpers] = true` to enable `preserve` helper method

## 0.5.1 (2015-11-18)
- Fix id ordering of object reference
    - https://github.com/eagletmt/faml/issues/33

## 0.5.0 (2015-11-17)
- Support object reference syntax
    - https://github.com/eagletmt/faml/pull/32

## 0.4.2 (2015-11-16)
- Fix CLI slow startup
    - https://github.com/eagletmt/faml/issues/21

## 0.4.1 (2015-11-16)
- Fix "end" insertion for `rescue` and `ensure` cases
    - It's regression in v0.4.0

## 0.4.0 (2015-11-15)
- Fix "end" insertion for empty else clause
    = https://github.com/eagletmt/faml/pull/31
    - It also requires haml_parser v0.2.0 or above.

## 0.3.6 (2015-11-06)
- Fix attribute escape on forward slashes
    - https://github.com/eagletmt/faml/pull/30
    - It's regression in v0.3.2

## 0.3.5 (2015-10-19)
- Fix empty class or id rendering
    - It's a regression in v0.3.4.
- Ignore falsey elements in class or id array
    - For compatibility with haml
    - `%span{class: [1, nil, false, true]}` now renders `<span class='1 true'></span>` .

## 0.3.4 (2015-10-19)
- Support array, rational and complex literal optimization
    - Now `%div{class: %w[foo bar], data: { foo: 1i, bar: 2r }}` is compiled into string literal.
- Remove `Kernel#eval` from compiler
- Improve `faml stats` subcommand
    - Show more detailed attribute information
    - Fix several bugs

## 0.3.3 (2015-10-07)
- Improve `Faml::AttributeBuilder.build` performance
    - Optimize string conversions
- Fix handling true/false/nil values in data attribute
- Add `stats` subcommand
    - Currently, it shows AST ratio and element attribute's ratio.

## 0.3.2 (2015-09-24)
- Fix illegal constant name
- Use `require_relative` if possible
    - It improves loading performance a little especially when there's long
      `$LOAD_PATH` by Bundler.
- Improve `Faml::AttributeBuilder.build` performance
    - Call `escape_html` C-API (vmg/houdini) directly.
    - Avoid `String#gsub` for performance
- Allow NUL characters in attribute keys
    - You should not include NUL characters, of course.

## 0.3.1 (2015-09-20)
- Improve `Faml::AttributeBuilder.build` performance
    - Reduce String allocations

## 0.3.0 (2015-09-13)
- Move Haml parser and AST definition to haml_parser
    - https://github.com/eagletmt/haml_parser
    - Remove `faml parse` subcommand

## 0.2.16 (2015-08-05)
- Fix incompatibility to tilt 2.x
    - https://github.com/eagletmt/faml/issues/23

## 0.2.15 (2015-06-14)
- Improve compatibility of tilt filter indentations
- Raise error when ids or classes don't have values

## 0.2.14 (2015-06-11)
- Check indent size consistency for compatibility with Haml
- Intentionally prohibit indentations with hard tabs

## 0.2.13 (2015-04-14)
- Fix attribute rendering in non-html format when the value is true
- Fix Faml::Engine constructor to allow user to set options via `Faml::Engine.options`

## 0.2.12 (2015-04-12)
- Remove duplicated class values
    - For compatibility
- Add `version` subcommand
- Add `--format` option to cli

## 0.2.11 (2015-04-07)
- Keep code newlines within multiline in HTML-style attribute list
    - https://github.com/eagletmt/faml/issues/19

## 0.2.10 (2015-04-06)
- Keep code newlines within Ruby multiline

## 0.2.9 (2015-04-04)
- Keep code newlines with multiline
    - https://github.com/eagletmt/faml/issues/18
- Disable haml multiline syntax within filter
- Fix `__LINE__` and `__FILE__` in attribute lists

## 0.2.8 (2015-04-02)
- Allow empty silent script body
    - For compatibility with haml
    - https://github.com/eagletmt/faml/issues/16
- Fix parse error at multiline in attribute list
    - https://github.com/eagletmt/faml/issues/15

## 0.2.7 (2015-03-31)
- Improve backtrace of compile time errors
- Annotate Faml::Ast with filename and line number (internal)
- Fix error with tilt 1.x.

## 0.2.6 (2015-03-31)
- Fix dependency on temple
- Improve backtrace when syntax error is raised
    - https://github.com/eagletmt/faml/issues/13

## 0.2.5 (2015-03-30)
- Fix parser when parsing attributes in `{'foo': 'bar'}` form
    - The syntax was introduced in Ruby 2.2.

## 0.2.4 (2015-03-26)
- Fix parser when parsing `>` or `<` after attribute lists
    - `%div{foo: :bar} <br>` was incorrectly parsed as `%div{foo: :bar}< br>` .

## 0.2.3 (2015-03-25)
- Always escape texts in :escape filter
    - It was not escaped when used in Rails
- `preserve` helper returns html_safe string in Rails
    - For compatibility with haml's Haml::Helpers::XssMods

## 0.2.2 (2015-03-23)
- Fix attribute rendering when the key is in `:'foo-bar'` form
- Provide `preserve` method in view contexts
    - For compatibility with haml's Haml::Helpers

## 0.2.1 (2015-03-23)
- Allow double rmnl
    - simply ignore the second rmnl

## 0.2.0 (2015-03-19)
- Rename from fast_haml to faml
- Allow .faml extension

## 0.1.10 (2015-03-19)
- Fix ruby filter to not generate newlines
- Support markdown filter

## 0.1.9 (2015-03-18)
- Refactor script parser (internal)
- Fix newline generation with filters
- Support sass, scss and coffee filter

## 0.1.8 (2015-03-17)
- Fix whitespace removal (`<` and `>`) behavior
    - Internally, new instructions `mknl` and `rmnl` are added.

## 0.1.7 (2015-03-16)
- Fix attribute rendering with falsey values
    - https://github.com/eagletmt/faml/pull/11

## 0.1.6 (2015-03-11)
- Fix render error with comment-only script
    - https://github.com/eagletmt/faml/issues/6
- Fix parsing error at multiline attributes
    - https://github.com/eagletmt/faml/issues/7

## 0.1.5 (2015-03-01)
- Fix minor newline generation bug with Haml comment

## 0.1.4 (2015-02-28)
- Fix newline generation around empty lines
    - Internal: introduce Ast::Empty and remove LineCounter

## 0.1.3 (2015-02-27)
- Fix internal compiler error when `>` is used
- Fix newline generation at Ast::Element case

## 0.1.2 (2015-02-24)
- Keep newlines for better backtrace (#4)

## 0.1.1 (2015-02-23)
- Fix attribute parsing with `%span {foo}` or `%span (foo)` cases.
- Fix comparison with statically-compilable class attributes like `%span.foo{class: bar}` .

## 0.1.0 (2015-02-23)
- Initial release
