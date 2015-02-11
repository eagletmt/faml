# FastHaml
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

## Contributing

1. Fork it ( https://github.com/eagletmt/fast_haml/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
