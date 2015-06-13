# [./spec/render/attribute_spec.rb:23](../../../spec/render/attribute_spec.rb#L23)
## Input
```haml
%span{"foo": 'bar'}
```

## Faml, Haml
```html
<span foo='bar'></span>

```

## Hamlit (Error)
```html
Hamlit::SyntaxError
```

# [./spec/render/attribute_spec.rb:23](../../../spec/render/attribute_spec.rb#L23)
## Input
```haml
- x = 'bar'
%span{"foo": x}
```

## Faml, Haml
```html
<span foo='bar'></span>

```

## Hamlit (Error)
```html
Hamlit::SyntaxError
```

# [./spec/render/attribute_spec.rb:23](../../../spec/render/attribute_spec.rb#L23)
## Input
```haml
%span{'foo': 'bar'}
```

## Faml, Haml
```html
<span foo='bar'></span>

```

## Hamlit (Error)
```html
Hamlit::SyntaxError
```

# [./spec/render/attribute_spec.rb:23](../../../spec/render/attribute_spec.rb#L23)
## Input
```haml
- x = 'bar'
%span{'foo': x}
```

## Faml, Haml
```html
<span foo='bar'></span>

```

## Hamlit (Error)
```html
Hamlit::SyntaxError
```

# [./spec/render/attribute_spec.rb:52](../../../spec/render/attribute_spec.rb#L52)
## Input
```haml
- h1 = {class: 'c1', id: ['id1', 'id3']}
- h2 = {class: [{}, 'c2'], id: 'id2'}
%span#main.content{h1, h2} hello

```

## Faml, Haml
```html
<span class='c1 c2 content {}' id='main_id1_id3_id2'>hello</span>

```

## Hamlit
```html
<span class='c1 content c2 {}' id='main_id1_id3_id2'>hello</span>

```

# [./spec/render/attribute_spec.rb:65](../../../spec/render/attribute_spec.rb#L65)
## Input
```haml
%span.foo{class: "foo bar"}
```

## Faml, Haml
```html
<span class='bar foo'></span>

```

## Hamlit
```html
<span class='foo bar foo'></span>

```

# [./spec/render/attribute_spec.rb:71](../../../spec/render/attribute_spec.rb#L71)
## Input
```haml
%span.#foo{id: :bar} hello
```

## Faml
```html
<span id='foo_bar'>hello</span>

```

## Haml (Error)
```html
Illegal element: classes and ids must have values.
```

## Hamlit (Error)
```html
Expected to scan (?-mix:[a-zA-Z0-9_-]+) but got nil
```

# [./spec/render/attribute_spec.rb:75](../../../spec/render/attribute_spec.rb#L75)
## Input
```haml
%span{class: "x\"y'z"} hello
```

## Faml, Hamlit
```html
<span class='x&quot;y&#39;z'>hello</span>

```

## Haml
```html
<span class='x"y&#x0027;z'>hello</span>

```

# [./spec/render/attribute_spec.rb:92](../../../spec/render/attribute_spec.rb#L92)
## Input (with options={:format=>:xhtml})
```haml
- foo = true
%span{foo: foo, bar: 1} hello
```

## Faml, Haml
```html
<span bar='1' foo='foo'>hello</span>

```

## Hamlit
```html
<span bar='1' foo='true'>hello</span>

```

# [./spec/render/attribute_spec.rb:92](../../../spec/render/attribute_spec.rb#L92)
## Input (with options={:format=>:xhtml})
```haml
- h = {foo: true, bar: 1}
%span{h} hello
```

## Faml, Haml
```html
<span bar='1' foo='foo'>hello</span>

```

## Hamlit
```html
<span foo bar='1'>hello</span>

```

# [./spec/render/attribute_spec.rb:99](../../../spec/render/attribute_spec.rb#L99)
## Input
```haml
%span{foo: {bar: 1+2}} hello
```

## Faml
```html
<span foo='{:bar=&gt;3}'>hello</span>

```

## Haml, Hamlit
```html
<span foo-bar='3'>hello</span>

```

# [./spec/render/attribute_spec.rb:103](../../../spec/render/attribute_spec.rb#L103)
## Input
```haml
- attrs = { foo: 1, bar: { hoge: :fuga }, baz: true }
%span{attrs} hello

```

## Faml
```html
<span bar='{:hoge=&gt;:fuga}' baz foo='1'>hello</span>

```

## Haml
```html
<span bar-hoge='fuga' baz foo='1'>hello</span>

```

## Hamlit
```html
<span foo='1' bar-hoge='fuga' baz>hello</span>

```

# [./spec/render/attribute_spec.rb:117](../../../spec/render/attribute_spec.rb#L117)
## Input
```haml
- data = { foo: 1 }
%span{foo: {bar: "x#{1}y"}} hello

```

## Faml
```html
<span foo='{:bar=&gt;&quot;x1y&quot;}'>hello</span>

```

## Haml, Hamlit
```html
<span foo-bar='x1y'>hello</span>

```

# [./spec/render/attribute_spec.rb:124](../../../spec/render/attribute_spec.rb#L124)
## Input
```haml
%span{foo: {bar: 1+2}} hello
```

## Faml
```html
<span foo='{:bar=&gt;3}'>hello</span>

```

## Haml, Hamlit
```html
<span foo-bar='3'>hello</span>

```

# [./spec/render/attribute_spec.rb:157](../../../spec/render/attribute_spec.rb#L157)
## Input
```haml
%span{foo: 1
, bar: 2} hello

```

## Faml (Error)
```html
Unmatched brace
```

## Haml (Error)
```html
Unbalanced brackets.
```

## Hamlit
```html
<span bar='2' foo='1'>hello</span>

```

# [./spec/render/attribute_spec.rb:166](../../../spec/render/attribute_spec.rb#L166)
## Input
```haml
%span{data: {foo: 1, bar: 'baz', :hoge => :fuga, k1: { k2: 'v3' }}} hello
```

## Faml, Haml
```html
<span data-bar='baz' data-foo='1' data-hoge='fuga' data-k1-k2='v3'>hello</span>

```

## Hamlit
```html
<span data-foo='1' data-bar='baz' data-hoge='fuga' data-k1-k2='v3'>hello</span>

```

# [./spec/render/attribute_spec.rb:174](../../../spec/render/attribute_spec.rb#L174)
## Input
```haml
%span{data: {foo: 1, bar: 2+3}} hello
```

## Faml, Haml
```html
<span data-bar='5' data-foo='1'>hello</span>

```

## Hamlit
```html
<span data-foo='1' data-bar='5'>hello</span>

```

# [./spec/render/attribute_spec.rb:178](../../../spec/render/attribute_spec.rb#L178)
## Input
```haml
- data = { foo: 1, bar: 2 }
%span{data: data} hello

```

## Faml, Haml
```html
<span data-bar='2' data-foo='1'>hello</span>

```

## Hamlit
```html
<span data-foo='1' data-bar='2'>hello</span>

```

# [./spec/render/attribute_spec.rb:186](../../../spec/render/attribute_spec.rb#L186)
## Input
```haml
%span{b: __LINE__,
  a: __LINE__}

```

## Faml, Haml
```html
<span a='2' b='1'></span>

```

## Hamlit
```html
<span a='1' b='1'></span>

```

# [./spec/render/attribute_spec.rb:212](../../../spec/render/attribute_spec.rb#L212)
## Input
```haml
%span{data: {foo: 1,
  bar: 2}}
  %span hello

```

## Faml, Haml
```html
<span data-bar='2' data-foo='1'>
<span>hello</span>
</span>

```

## Hamlit
```html
<span data-foo='1' data-bar='2'>
<span>hello</span>
</span>

```

# [./spec/render/attribute_spec.rb:220](../../../spec/render/attribute_spec.rb#L220)
## Input
```haml
%span(foo=1

bar=3) hello

```

## Faml, Haml
```html
<span bar='3' foo='1'>hello</span>

```

## Hamlit
```html
<span foo='3'>hello</span>

```

# [./spec/render/attribute_spec.rb:237](../../../spec/render/attribute_spec.rb#L237)
## Input
```haml
%span(foo bar=1) hello
```

## Faml, Haml
```html
<span bar='1' foo>hello</span>

```

## Hamlit
```html
<span = foo>hello</span>

```

# [./spec/render/attribute_spec.rb:241](../../../spec/render/attribute_spec.rb#L241)
## Input
```haml
%span(foo=1 bar='baz#{1 + 2}') hello
```

## Faml, Haml
```html
<span bar='baz3' foo='1'>hello</span>

```

## Hamlit
```html
<span bar='baz#{1 + 2}' foo='1'>hello</span>

```

# [./spec/render/attribute_spec.rb:246](../../../spec/render/attribute_spec.rb#L246)
## Input
```haml
%span(foo=1 bar="ba\"z") hello
```

## Faml, Hamlit
```html
<span bar='ba&quot;z' foo='1'>hello</span>

```

## Haml
```html
<span bar='ba"z' foo='1'>hello</span>

```

# [./spec/render/attribute_spec.rb:246](../../../spec/render/attribute_spec.rb#L246)
## Input
```haml
%span(foo=1 bar='ba\'z') hello
```

## Faml, Hamlit
```html
<span bar='ba&#39;z' foo='1'>hello</span>

```

## Haml
```html
<span bar="ba'z" foo='1'>hello</span>

```

# [./spec/render/attribute_spec.rb:255](../../../spec/render/attribute_spec.rb#L255)
## Input
```haml
%span(foo=1 3.14=3) hello
```

## Faml (Error)
```html
Invalid attribute list (missing attributename)
```

## Haml (Error)
```html
Invalid attribute list: "(foo=1 3.14=3)".
```

## Hamlit
```html
<span 3.14 foo='1'>hello</span>

```

# [./spec/render/attribute_spec.rb:259](../../../spec/render/attribute_spec.rb#L259)
## Input
```haml
%span(foo=1 bar=) hello
```

## Faml (Error)
```html
Invalid attribute list (invalid variable name)
```

## Haml (Error)
```html
Invalid attribute list: "(foo=1 bar=)".
```

## Hamlit
```html
<span bar foo='1'>hello</span>

```

# [./spec/render/attribute_spec.rb:271](../../../spec/render/attribute_spec.rb#L271)
## Input
```haml
%span(b=__LINE__
  a=__LINE__)

```

## Faml
```html
<span a='2' b='1'></span>

```

## Haml, Hamlit
```html
<span a='1' b='1'></span>

```

