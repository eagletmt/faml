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

# [./spec/render/attribute_spec.rb:84](../../../spec/render/attribute_spec.rb#L84)
## Input
```haml
%span{disabled: true, bar: 1} hello
```

## Faml, Haml
```html
<span bar='1' disabled>hello</span>

```

## Hamlit
```html
<span disabled bar='1'>hello</span>

```

# [./spec/render/attribute_spec.rb:90](../../../spec/render/attribute_spec.rb#L90)
## Input
```haml
%span{foo: true, bar: 1} hello
```

## Faml
```html
<span bar='1' foo='true'>hello</span>

```

## Haml, Hamlit
```html
<span bar='1' foo>hello</span>

```

# [./spec/render/attribute_spec.rb:101](../../../spec/render/attribute_spec.rb#L101)
## Input (with options={:format=>:xhtml})
```haml
%span{disabled: true, bar: 1} hello
```

## Faml, Haml
```html
<span bar='1' disabled='disabled'>hello</span>

```

## Hamlit
```html
<span disabled bar='1'>hello</span>

```

# [./spec/render/attribute_spec.rb:101](../../../spec/render/attribute_spec.rb#L101)
## Input (with options={:format=>:xhtml})
```haml
- disabled = true
%span{disabled: disabled, bar: 1} hello
```

## Faml, Haml
```html
<span bar='1' disabled='disabled'>hello</span>

```

## Hamlit
```html
<span disabled bar='1'>hello</span>

```

# [./spec/render/attribute_spec.rb:101](../../../spec/render/attribute_spec.rb#L101)
## Input (with options={:format=>:xhtml})
```haml
- h = {disabled: true, bar: 1}
%span{h} hello
```

## Faml, Haml
```html
<span bar='1' disabled='disabled'>hello</span>

```

## Hamlit
```html
<span disabled bar='1'>hello</span>

```

# [./spec/render/attribute_spec.rb:109](../../../spec/render/attribute_spec.rb#L109)
## Input (with options={:format=>:xhtml})
```haml
%span{foo: true, bar: 1} hello
```

## Faml
```html
<span bar='1' foo='true'>hello</span>

```

## Haml, Hamlit
```html
<span bar='1' foo='foo'>hello</span>

```

# [./spec/render/attribute_spec.rb:109](../../../spec/render/attribute_spec.rb#L109)
## Input (with options={:format=>:xhtml})
```haml
- foo = true
%span{foo: foo, bar: 1} hello
```

## Faml, Hamlit
```html
<span bar='1' foo='true'>hello</span>

```

## Haml
```html
<span bar='1' foo='foo'>hello</span>

```

# [./spec/render/attribute_spec.rb:109](../../../spec/render/attribute_spec.rb#L109)
## Input (with options={:format=>:xhtml})
```haml
- h = {foo: true, bar: 1}
%span{h} hello
```

## Faml
```html
<span bar='1' foo='true'>hello</span>

```

## Haml
```html
<span bar='1' foo='foo'>hello</span>

```

## Hamlit
```html
<span foo bar='1'>hello</span>

```

# [./spec/render/attribute_spec.rb:117](../../../spec/render/attribute_spec.rb#L117)
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

# [./spec/render/attribute_spec.rb:121](../../../spec/render/attribute_spec.rb#L121)
## Input
```haml
- attrs = { foo: 1, bar: { hoge: :fuga }, baz: true }
%span{attrs} hello

```

## Faml
```html
<span bar='{:hoge=&gt;:fuga}' baz='true' foo='1'>hello</span>

```

## Haml
```html
<span bar-hoge='fuga' baz foo='1'>hello</span>

```

## Hamlit
```html
<span foo='1' bar-hoge='fuga' baz>hello</span>

```

# [./spec/render/attribute_spec.rb:135](../../../spec/render/attribute_spec.rb#L135)
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

# [./spec/render/attribute_spec.rb:142](../../../spec/render/attribute_spec.rb#L142)
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

# [./spec/render/attribute_spec.rb:175](../../../spec/render/attribute_spec.rb#L175)
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

# [./spec/render/attribute_spec.rb:184](../../../spec/render/attribute_spec.rb#L184)
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

# [./spec/render/attribute_spec.rb:192](../../../spec/render/attribute_spec.rb#L192)
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

# [./spec/render/attribute_spec.rb:196](../../../spec/render/attribute_spec.rb#L196)
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

# [./spec/render/attribute_spec.rb:204](../../../spec/render/attribute_spec.rb#L204)
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

# [./spec/render/attribute_spec.rb:230](../../../spec/render/attribute_spec.rb#L230)
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

# [./spec/render/attribute_spec.rb:238](../../../spec/render/attribute_spec.rb#L238)
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

# [./spec/render/attribute_spec.rb:255](../../../spec/render/attribute_spec.rb#L255)
## Input
```haml
%span(foo bar=1) hello
```

## Faml
```html
<span bar='1' foo='true'>hello</span>

```

## Haml
```html
<span bar='1' foo>hello</span>

```

## Hamlit
```html
<span = foo>hello</span>

```

# [./spec/render/attribute_spec.rb:259](../../../spec/render/attribute_spec.rb#L259)
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

# [./spec/render/attribute_spec.rb:264](../../../spec/render/attribute_spec.rb#L264)
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

# [./spec/render/attribute_spec.rb:264](../../../spec/render/attribute_spec.rb#L264)
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

# [./spec/render/attribute_spec.rb:273](../../../spec/render/attribute_spec.rb#L273)
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

# [./spec/render/attribute_spec.rb:277](../../../spec/render/attribute_spec.rb#L277)
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

# [./spec/render/attribute_spec.rb:289](../../../spec/render/attribute_spec.rb#L289)
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

