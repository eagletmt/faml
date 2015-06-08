# [./spec/render/filters/sass_spec.rb:4](../../../../spec/render/filters/sass_spec.rb#L4)
## Input
```haml
:sass
  nav
    ul
      margin: 0
      content: "hello"

```

## Faml
```html
<style>
nav ul {
  margin: 0;
  content: "hello"; }
</style>

```

## Haml, Hamlit
```html
<style>
  nav ul {
    margin: 0;
    content: "hello"; }
</style>

```

# [./spec/render/filters/sass_spec.rb:17](../../../../spec/render/filters/sass_spec.rb#L17)
## Input
```haml
:sass
  nav
    ul
      margin: #{0 + 5}px

```

## Faml
```html
<style>
nav ul {
  margin: 5px; }
</style>

```

## Haml, Hamlit
```html
<style>
  nav ul {
    margin: 5px; }
</style>

```

