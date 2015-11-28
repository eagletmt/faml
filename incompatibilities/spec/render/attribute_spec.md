# [./spec/render/attribute_spec.rb:53](../../../spec/render/attribute_spec.rb#L53)
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

# [./spec/render/attribute_spec.rb:71](../../../spec/render/attribute_spec.rb#L71)
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

# [./spec/render/attribute_spec.rb:71](../../../spec/render/attribute_spec.rb#L71)
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

# [./spec/render/attribute_spec.rb:85](../../../spec/render/attribute_spec.rb#L85)
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

# [./spec/render/attribute_spec.rb:92](../../../spec/render/attribute_spec.rb#L92)
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

# [./spec/render/attribute_spec.rb:92](../../../spec/render/attribute_spec.rb#L92)
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

# [./spec/render/attribute_spec.rb:92](../../../spec/render/attribute_spec.rb#L92)
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

# [./spec/render/attribute_spec.rb:106](../../../spec/render/attribute_spec.rb#L106)
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

# [./spec/render/attribute_spec.rb:110](../../../spec/render/attribute_spec.rb#L110)
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

# [./spec/render/attribute_spec.rb:114](../../../spec/render/attribute_spec.rb#L114)
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

# [./spec/render/attribute_spec.rb:118](../../../spec/render/attribute_spec.rb#L118)
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

# [./spec/render/attribute_spec.rb:124](../../../spec/render/attribute_spec.rb#L124)
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

# [./spec/render/attribute_spec.rb:124](../../../spec/render/attribute_spec.rb#L124)
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

# [./spec/render/attribute_spec.rb:124](../../../spec/render/attribute_spec.rb#L124)
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

# [./spec/render/attribute_spec.rb:124](../../../spec/render/attribute_spec.rb#L124)
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

# [./spec/render/attribute_spec.rb:124](../../../spec/render/attribute_spec.rb#L124)
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

# [./spec/render/attribute_spec.rb:124](../../../spec/render/attribute_spec.rb#L124)
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

# [./spec/render/attribute_spec.rb:143](../../../spec/render/attribute_spec.rb#L143)
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

