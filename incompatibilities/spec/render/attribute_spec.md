# [./spec/render/attribute_spec.rb:44](../../../spec/render/attribute_spec.rb#L44)
## Input
```haml
- h1 = { foo: 'should be overwritten' }
- h2 = { foo: nil }
%a{h1, h2}

```

## Faml, Haml
```html
<a></a>

```

## Hamlit
```html
<a foo='should be overwritten'></a>

```

# [./spec/render/attribute_spec.rb:52](../../../spec/render/attribute_spec.rb#L52)
## Input
```haml
- h = {foo: 1, 'foo' => 2}
%span{h}
```

## Faml, Haml
```html
<span foo='2'></span>

```

## Hamlit
```html
<span foo='1' foo='2'></span>

```

# [./spec/render/attribute_spec.rb:58](../../../spec/render/attribute_spec.rb#L58)
## Input
```haml
%span{foo: "x\"y'z"}hello
```

## Faml, Hamlit
```html
<span foo='x&quot;y&#39;z'>hello</span>

```

## Haml
```html
<span foo='x"y&#x0027;z'>hello</span>

```

# [./spec/render/attribute_spec.rb:58](../../../spec/render/attribute_spec.rb#L58)
## Input
```haml
- v = "x\"y'z"
%span{foo: v}hello
```

## Faml, Hamlit
```html
<span foo='x&quot;y&#39;z'>hello</span>

```

## Haml
```html
<span foo='x"y&#x0027;z'>hello</span>

```

# [./spec/render/attribute_spec.rb:58](../../../spec/render/attribute_spec.rb#L58)
## Input
```haml
- h = {foo: "x\"y'z"}
%span{h}hello
```

## Faml, Hamlit
```html
<span foo='x&quot;y&#39;z'>hello</span>

```

## Haml
```html
<span foo='x"y&#x0027;z'>hello</span>

```

# [./spec/render/attribute_spec.rb:75](../../../spec/render/attribute_spec.rb#L75)
## Input (with options={:format=>:xhtml})
```haml
- v = true
%span{foo: v}hello
```

## Faml, Haml
```html
<span foo='foo'>hello</span>

```

## Hamlit
```html
<span foo='true'>hello</span>

```

# [./spec/render/attribute_spec.rb:75](../../../spec/render/attribute_spec.rb#L75)
## Input (with options={:format=>:xhtml})
```haml
- h = {foo: true}
%span{h}hello
```

## Faml, Haml
```html
<span foo='foo'>hello</span>

```

## Hamlit
```html
<span foo>hello</span>

```

# [./spec/render/attribute_spec.rb:89](../../../spec/render/attribute_spec.rb#L89)
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

# [./spec/render/attribute_spec.rb:96](../../../spec/render/attribute_spec.rb#L96)
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

# [./spec/render/attribute_spec.rb:96](../../../spec/render/attribute_spec.rb#L96)
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

# [./spec/render/attribute_spec.rb:96](../../../spec/render/attribute_spec.rb#L96)
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

# [./spec/render/attribute_spec.rb:110](../../../spec/render/attribute_spec.rb#L110)
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

# [./spec/render/attribute_spec.rb:114](../../../spec/render/attribute_spec.rb#L114)
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

# [./spec/render/attribute_spec.rb:118](../../../spec/render/attribute_spec.rb#L118)
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

# [./spec/render/attribute_spec.rb:122](../../../spec/render/attribute_spec.rb#L122)
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

# [./spec/render/attribute_spec.rb:128](../../../spec/render/attribute_spec.rb#L128)
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

# [./spec/render/attribute_spec.rb:128](../../../spec/render/attribute_spec.rb#L128)
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

# [./spec/render/attribute_spec.rb:128](../../../spec/render/attribute_spec.rb#L128)
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

# [./spec/render/attribute_spec.rb:128](../../../spec/render/attribute_spec.rb#L128)
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

# [./spec/render/attribute_spec.rb:128](../../../spec/render/attribute_spec.rb#L128)
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

# [./spec/render/attribute_spec.rb:128](../../../spec/render/attribute_spec.rb#L128)
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

# [./spec/render/attribute_spec.rb:147](../../../spec/render/attribute_spec.rb#L147)
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

