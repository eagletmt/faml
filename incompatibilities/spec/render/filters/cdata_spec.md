# [./spec/render/filters/cdata_spec.rb:5](../../../../spec/render/filters/cdata_spec.rb#L5)
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
uninitialized constant Hamlit::Compiler::Error
```

