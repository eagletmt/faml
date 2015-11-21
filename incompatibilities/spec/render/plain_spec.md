# [./spec/render/plain_spec.rb:9](../../../spec/render/plain_spec.rb#L9)
## Input
```haml
%span foo\\#{1 + 2}bar

```

## Faml, Haml
```html
<span>foo\3bar</span>

```

## Hamlit
```html
<span>foo\\3bar</span>

```

