# [./spec/render/filters/cdata_spec.rb:4](../../../../spec/render/filters/cdata_spec.rb#L4)
## Input
```haml
:cdata
  hello
  #{'world'}
  <span>hello</span>

```

## Faml, Haml
```html
<![CDATA[
    hello
    world
    <span>hello</span>
]]>

```

## Hamlit (Error)
```html
Filter "cdata" is not defined.
```

