# FastHaml
[![Gem Version](https://badge.fury.io/rb/fast_haml.svg)](http://badge.fury.io/rb/fast_haml)
[![Build Status](https://travis-ci.org/eagletmt/fast_haml.svg)](https://travis-ci.org/eagletmt/fast_haml)
[![Coverage Status](https://coveralls.io/repos/eagletmt/fast_haml/badge.svg)](https://coveralls.io/r/eagletmt/fast_haml)
[![Code Climate](https://codeclimate.com/github/eagletmt/fast_haml/badges/gpa.svg)](https://codeclimate.com/github/eagletmt/fast_haml)

Faster implementation of Haml template language.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fast_haml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fast_haml

## Usage

Just replace your `gem 'haml'` with `gem 'fast_haml'` .

## Incompatibilities
There are several incompatibilities.

### Hash attributes
Hash attributes are only supported to "data" attributes.

With original haml, `%span{foo: {bar: 'baz'}}` is rendered as `<span foo-bar='baz'></span>` .
With fast_haml, it's rendered as `<span foo='{:bar=&gt;&quot;baz&quot;}'></span>` .

Only "data" attributes are converted to hyphenated attributes.

### HTML-escape by default
Even with non-Rails project, all string are HTML-escaped.

### "ugly" mode only
Only "ugly" mode in original haml is supported.

```haml
%div
  %div hello
```

is always rendered as

```html
<div>
<div>hello</div>
</div>
```

It's equivalent to haml's "ugly" mode.

### Others
If you find other incompatibility, please report it to me :-p.

## Why fast_haml is faster?
### Temple backend
I use [temple](https://github.com/judofyr/temple) to achieve faster template rendering.
It's used by [slim](https://github.com/slim-template/slim) template language & engine which is known as fast.

1. FastHaml::Parser converts source language (Haml template) to own AST (FastHaml::Ast) .
    - You can see the FastHaml::Ast by running `fast_haml parse template.haml` .
2. FastHaml::Compiler compiles FastHaml::Ast into Temple AST.
    - You can see the Temple AST by running `fast_haml temple template.haml` .
3. Temple compiles its AST into Ruby code.
    - You can see the Ruby code by running `fast_haml compile template.haml` .
    - During this process, several optimizations are performed such as Temple::Filters::MultiFlattener and Temple::Filters::StaticMerger.

### Attribute optimization
Although Haml allows arbitrary Ruby hash in the attribute syntax, most attributes are written in hash literal form.
All keys are string or symbol literals (i.e., not dynamic values) in typical case.

```haml
%div{class: some_helper_method(current_user)}
  %a{href: foo_path(@item)}= @item.name
```

There is an optimization chance if we could know the value is String.
I introduced incompatibility to expand the chance: all attribute values are converted to String by `#to_s` except for `id`, `class` and `data` .
This will enable us to avoid runtime expensive hash merging and rendering.
The runtime hash merging is implemented by C extension in fast_haml.

Internally, attributes are categolized into three types.

1. Static attributes
    - Both the key and the value are literal.
    - Compiled into string literals.
    - Fastest.
    - e.g. `%input{checked: false}`
2. Dynamic attributes
    - The key is literal but the value isn't.
    - The key is compiled into string literal. The value is interpolated at run-time.
    - Relatively fast.
    - e.g. `%input{checked: helper_method(@record)}`
3. Ruby attributes
    - Both the key and the value are non-literal expression.
    - The attributes are stringified at run-time.
    - Slow.
    - e.g. `%input{helper_method(@record)}`

## Contributing

1. Fork it ( https://github.com/eagletmt/fast_haml/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
