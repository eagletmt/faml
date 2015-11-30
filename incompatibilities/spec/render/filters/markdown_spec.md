# [./spec/render/filters/markdown_spec.rb:5](../../../../spec/render/filters/markdown_spec.rb#L5)
## Input
```haml
:markdown
  # hello
world

```

## Faml, Haml
```html
<h1>hello</h1>
world

```

## Hamlit
```html
<h1>hello</h1>

world

```

# [./spec/render/filters/markdown_spec.rb:13](../../../../spec/render/filters/markdown_spec.rb#L13)
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

## Haml, Hamlit
```html
<h1>hello</h1>

world

```

