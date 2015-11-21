# [./spec/render/helpers_spec.rb:5](../../../spec/render/helpers_spec.rb#L5)
## Input (with options={:extend_helpers=>true})
```haml
%span!= preserve "hello\nworld !"
```

## Faml, Haml
```html
<span>hello&#x000A;world !</span>

```

## Hamlit (Error)
```html
undefined method `preserve' for #<Object:0x000000047293c8>
```

