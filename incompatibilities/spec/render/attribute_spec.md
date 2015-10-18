# [./spec/render/attribute_spec.rb:48](../../../spec/render/attribute_spec.rb#L48)
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

# [./spec/render/attribute_spec.rb:61](../../../spec/render/attribute_spec.rb#L61)
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

# [./spec/render/attribute_spec.rb:67](../../../spec/render/attribute_spec.rb#L67)
## Input
```haml
%span{class: []}
```

## Faml, Haml
```html
<span></span>

```

## Hamlit
```html
<span class=''></span>

```

# [./spec/render/attribute_spec.rb:75](../../../spec/render/attribute_spec.rb#L75)
## Input
```haml
%span{id: []}
```

## Faml, Haml
```html
<span></span>

```

## Hamlit
```html
<span id=''></span>

```

# [./spec/render/attribute_spec.rb:79](../../../spec/render/attribute_spec.rb#L79)
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

# [./spec/render/attribute_spec.rb:147](../../../spec/render/attribute_spec.rb#L147)
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

# [./spec/render/attribute_spec.rb:155](../../../spec/render/attribute_spec.rb#L155)
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

# [./spec/render/attribute_spec.rb:159](../../../spec/render/attribute_spec.rb#L159)
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

# [./spec/render/attribute_spec.rb:177](../../../spec/render/attribute_spec.rb#L177)
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

# [./spec/render/attribute_spec.rb:184](../../../spec/render/attribute_spec.rb#L184)
## Input
```haml
%span{"foo\0bar" => "hello"}
```

## Faml, Haml
```html
<span foo<0x00>bar='hello'></span>

```

## Hamlit
```html
<span foo\0bar='hello'></span>

```

# [./spec/render/attribute_spec.rb:184](../../../spec/render/attribute_spec.rb#L184)
## Input
```haml
- val = "hello"
%span{"foo\0bar" => val}

```

## Faml, Haml
```html
<span foo<0x00>bar='hello'></span>

```

## Hamlit
```html
<span foo\0bar='hello'></span>

```

# [./spec/render/attribute_spec.rb:184](../../../spec/render/attribute_spec.rb#L184)
## Input
```haml
- key = "foo\0bar"
- val = "hello"
%span{key => val}

```

## Faml, Haml
```html
<span foo<0x00>bar='hello'></span>

```

## Hamlit (Error)
```html
(eval):3: syntax error, unexpected =>
...::Temple::Utils.escape_html((=> val))); _buf << ("'></span>\...
...                               ^
```

