# [./spec/render/filters/markdown_spec.rb:13](../../../../spec/render/filters/markdown_spec.rb#L13)
## Input
```haml
:markdown
  # #{'hello'}
world

```

## Faml, Hamlit
```html
<h1>hello</h1>
world

```

## Haml
```html
<h1>hello</h1>

world

```

