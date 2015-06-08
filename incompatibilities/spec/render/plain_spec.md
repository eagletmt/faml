# [./spec/render/plain_spec.rb:8](../../../spec/render/plain_spec.rb#L8)
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

