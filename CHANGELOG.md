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
