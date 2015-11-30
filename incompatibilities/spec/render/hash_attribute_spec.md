# [./spec/render/hash_attribute_spec.rb:5](../../../spec/render/hash_attribute_spec.rb#L5)
## Input
```haml
%span{foo: {bar: 1+2}} hello
```

## Faml, Hamlit
```html
<span foo='{:bar=&gt;3}'>hello</span>

```

## Haml
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
<span bar='{:hoge=&gt;:fuga}' baz='true' foo='1'>hello</span>

```

# [./spec/render/hash_attribute_spec.rb:16](../../../spec/render/hash_attribute_spec.rb#L16)
## Input
```haml
- data = { foo: 1 }
%span{foo: {bar: "x#{1}y"}} hello

```

## Faml, Hamlit
```html
<span foo='{:bar=&gt;&quot;x1y&quot;}'>hello</span>

```

## Haml
```html
<span foo-bar='x1y'>hello</span>

```

