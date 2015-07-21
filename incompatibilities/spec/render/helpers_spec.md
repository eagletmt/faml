# [./spec/render/helpers_spec.rb:4](../../../spec/render/helpers_spec.rb#L4)
## Input
```haml
%span!= preserve "hello\nworld !"
```

## Faml, Haml
```html
<span>hello&#x000A;world !</span>

```

## Hamlit (Error)
```html
undefined method `preserve' for #<Object:0x00000002ca2b08>
```

