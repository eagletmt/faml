# [./spec/render/filters/markdown_spec.rb:12](../../../../spec/render/filters/markdown_spec.rb#L12)
## Input
```haml
:markdown
  # #{'hello'}
world

```

## Faml
```html
<h1>hello</h1>
world

```

## Haml
```html
<h1>hello</h1>

world

```

