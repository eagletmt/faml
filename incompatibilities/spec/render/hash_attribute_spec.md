# [./spec/render/hash_attribute_spec.rb:5](../../../spec/render/hash_attribute_spec.rb#L5)
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

# [./spec/render/hash_attribute_spec.rb:9](../../../spec/render/hash_attribute_spec.rb#L9)
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

# [./spec/render/hash_attribute_spec.rb:16](../../../spec/render/hash_attribute_spec.rb#L16)
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

# [./spec/render/hash_attribute_spec.rb:37](../../../spec/render/hash_attribute_spec.rb#L37)
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

# [./spec/render/hash_attribute_spec.rb:45](../../../spec/render/hash_attribute_spec.rb#L45)
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

# [./spec/render/hash_attribute_spec.rb:49](../../../spec/render/hash_attribute_spec.rb#L49)
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

