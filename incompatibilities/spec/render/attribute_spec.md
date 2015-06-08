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

# [./spec/render/attribute_spec.rb:75](../../../spec/render/attribute_spec.rb#L75)
## Input
```haml
%span{class: "x\"y'z"} hello
```

## Faml
```html
<span class='x&quot;y&#39;z'>hello</span>

```

## Haml
```html
<span class='x"y&#x0027;z'>hello</span>

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

## Haml
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

## Haml
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

## Haml
```html
<span foo-bar='3'>hello</span>

```

# [./spec/render/attribute_spec.rb:246](../../../spec/render/attribute_spec.rb#L246)
## Input
```haml
%span(foo=1 bar="ba\"z") hello
```

## Faml
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

## Faml
```html
<span bar='ba&#39;z' foo='1'>hello</span>

```

## Haml
```html
<span bar="ba'z" foo='1'>hello</span>

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

## Haml
```html
<span a='1' b='1'></span>

```

