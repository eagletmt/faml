# [./spec/render/filters/scss_spec.rb:4](../../../../spec/render/filters/scss_spec.rb#L4)
## Input
```haml
:scss
  nav {
    ul {
      margin: 0;
      content: "hello";
    }
  }

```

## Faml
```html
<style>
nav ul {
  margin: 0;
  content: "hello"; }

</style>

```

## Haml
```html
<style>
  nav ul {
    margin: 0;
    content: "hello"; }
</style>

```

## Hamlit
```html
<style>
  nav ul {
    margin: 0;
    content: "hello"; }
</style>

```

# [./spec/render/filters/scss_spec.rb:19](../../../../spec/render/filters/scss_spec.rb#L19)
## Input
```haml
:scss
  nav {
    ul {
      margin: #{0 + 5}px;
    }
  }

```

## Faml
```html
<style>
nav ul {
  margin: 5px; }

</style>

```

## Haml
```html
<style>
  nav ul {
    margin: 5px; }
</style>

```

## Hamlit
```html
<style>
  nav ul {
    margin: 5px; }
</style>

```

