# [./spec/render/attribute_spec.rb:49](../../../spec/render/attribute_spec.rb#L49)
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

# [./spec/render/attribute_spec.rb:62](../../../spec/render/attribute_spec.rb#L62)
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

# [./spec/render/attribute_spec.rb:68](../../../spec/render/attribute_spec.rb#L68)
## Input
```haml
%span{class: []}
```

## Faml
```html
<span></span>

```

## Haml, Hamlit
```html
<span class=''></span>

```

# [./spec/render/attribute_spec.rb:72](../../../spec/render/attribute_spec.rb#L72)
## Input
```haml
%span{class: [1, nil, false, true]}
```

## Faml, Haml
```html
<span class='1 true'></span>

```

## Hamlit
```html
<span class='1  false true'></span>

```

# [./spec/render/attribute_spec.rb:72](../../../spec/render/attribute_spec.rb#L72)
## Input
```haml
- v = [1, nil, false, true]
%span{class: v}
```

## Faml, Haml
```html
<span class='1 true'></span>

```

## Hamlit
```html
<span class='1  false true'></span>

```

# [./spec/render/attribute_spec.rb:72](../../../spec/render/attribute_spec.rb#L72)
## Input
```haml
- h = { class: [1, nil, false, true] }
%span{h}
```

## Faml, Haml
```html
<span class='1 true'></span>

```

## Hamlit
```html
<span class='1  false true'></span>

```

# [./spec/render/attribute_spec.rb:82](../../../spec/render/attribute_spec.rb#L82)
## Input
```haml
%span{id: []}
```

## Faml
```html
<span></span>

```

## Haml, Hamlit
```html
<span id=''></span>

```

# [./spec/render/attribute_spec.rb:86](../../../spec/render/attribute_spec.rb#L86)
## Input
```haml
%span{id: [1, nil, false, true]}
```

## Faml, Haml
```html
<span id='1_true'></span>

```

## Hamlit
```html
<span id='1__false_true'></span>

```

# [./spec/render/attribute_spec.rb:86](../../../spec/render/attribute_spec.rb#L86)
## Input
```haml
- v = [1, nil, false, true]
%span{id: v}
```

## Faml, Haml
```html
<span id='1_true'></span>

```

## Hamlit
```html
<span id='1__false_true'></span>

```

# [./spec/render/attribute_spec.rb:86](../../../spec/render/attribute_spec.rb#L86)
## Input
```haml
- h = { id: [1, nil, false, true] }
%span{h}
```

## Faml, Haml
```html
<span id='1_true'></span>

```

## Hamlit
```html
<span id='1__false_true'></span>

```

# [./spec/render/attribute_spec.rb:92](../../../spec/render/attribute_spec.rb#L92)
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

# [./spec/render/attribute_spec.rb:110](../../../spec/render/attribute_spec.rb#L110)
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

# [./spec/render/attribute_spec.rb:110](../../../spec/render/attribute_spec.rb#L110)
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

# [./spec/render/attribute_spec.rb:165](../../../spec/render/attribute_spec.rb#L165)
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

# [./spec/render/attribute_spec.rb:173](../../../spec/render/attribute_spec.rb#L173)
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

# [./spec/render/attribute_spec.rb:177](../../../spec/render/attribute_spec.rb#L177)
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

# [./spec/render/attribute_spec.rb:195](../../../spec/render/attribute_spec.rb#L195)
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

# [./spec/render/attribute_spec.rb:202](../../../spec/render/attribute_spec.rb#L202)
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

# [./spec/render/attribute_spec.rb:202](../../../spec/render/attribute_spec.rb#L202)
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

# [./spec/render/attribute_spec.rb:202](../../../spec/render/attribute_spec.rb#L202)
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

# [./spec/render/attribute_spec.rb:216](../../../spec/render/attribute_spec.rb#L216)
## Input
```haml
%span[Faml::TestStruct.new(123)] hello
```

## Faml, Haml
```html
<span class='faml_test_struct' id='faml_test_struct_123'>hello</span>

```

## Hamlit
```html
<span>[Faml::TestStruct.new(123)] hello</span>

```

# [./spec/render/attribute_spec.rb:220](../../../spec/render/attribute_spec.rb#L220)
## Input
```haml
%span[Faml::TestStruct.new(123), :hello] hello
```

## Faml, Haml
```html
<span class='hello_faml_test_struct' id='hello_faml_test_struct_123'>hello</span>

```

## Hamlit
```html
<span>[Faml::TestStruct.new(123), :hello] hello</span>

```

# [./spec/render/attribute_spec.rb:224](../../../spec/render/attribute_spec.rb#L224)
## Input
```haml
%span[Faml::TestRefStruct.new(123)] hello
```

## Faml, Haml
```html
<span class='faml_test' id='faml_test_123'>hello</span>

```

## Hamlit
```html
<span>[Faml::TestRefStruct.new(123)] hello</span>

```

# [./spec/render/attribute_spec.rb:228](../../../spec/render/attribute_spec.rb#L228)
## Input
```haml
%span#baz[Faml::TestStruct.new(123)]{id: "foo"} hello
```

## Faml, Haml
```html
<span class='faml_test_struct' id='baz_foo_faml_test_struct_123'>hello</span>

```

## Hamlit
```html
<span id='baz'>[Faml::TestStruct.new(123)]{id: "foo"} hello</span>

```

# [./spec/render/attribute_spec.rb:234](../../../spec/render/attribute_spec.rb#L234)
## Input
```haml
%span{foo: 1}(foo=2)
```

## Faml, Haml
```html
<span foo='1'></span>

```

## Hamlit
```html
<span foo='1' foo='2'></span>

```

# [./spec/render/attribute_spec.rb:234](../../../spec/render/attribute_spec.rb#L234)
## Input
```haml
%span(foo=2){foo: 1}
```

## Faml, Haml
```html
<span foo='1'></span>

```

## Hamlit
```html
<span foo='2' foo='1'></span>

```

# [./spec/render/attribute_spec.rb:234](../../../spec/render/attribute_spec.rb#L234)
## Input
```haml
- v = 2
%span{foo: v-1}(foo=v)
```

## Faml, Haml
```html
<span foo='1'></span>

```

## Hamlit
```html
<span foo='1' foo='2'></span>

```

# [./spec/render/attribute_spec.rb:234](../../../spec/render/attribute_spec.rb#L234)
## Input
```haml
- v = 2
%span(foo=v){foo: v-1}
```

## Faml, Haml
```html
<span foo='1'></span>

```

## Hamlit
```html
<span foo='2' foo='1'></span>

```

# [./spec/render/attribute_spec.rb:234](../../../spec/render/attribute_spec.rb#L234)
## Input
```haml
- h = {foo: 1}
%span{h}(foo=2)
```

## Faml, Haml
```html
<span foo='1'></span>

```

## Hamlit
```html
<span foo='1' foo='2'></span>

```

# [./spec/render/attribute_spec.rb:234](../../../spec/render/attribute_spec.rb#L234)
## Input
```haml
- h = {foo: 1}
%span(foo=2){h}
```

## Faml, Haml
```html
<span foo='1'></span>

```

## Hamlit
```html
<span foo='1' foo='2'></span>

```

# [./spec/render/attribute_spec.rb:253](../../../spec/render/attribute_spec.rb#L253)
## Input
```haml
%span{id: 1}(id=2)
```

## Faml, Haml
```html
<span id='2_1'></span>

```

## Hamlit
```html
<span id='1_2'></span>

```

