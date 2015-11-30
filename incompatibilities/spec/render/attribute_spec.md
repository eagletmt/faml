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
<a foo=''></a>

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
%span{foo: true}hello
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
<span foo='true'>hello</span>

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
<span class='faml_test_ref_struct' id='faml_test_ref_struct_123'>hello</span>

```

