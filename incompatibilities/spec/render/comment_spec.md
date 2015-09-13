# [./spec/render/comment_spec.rb:31](../../../spec/render/comment_spec.rb#L31)
## Input
```haml
/ [if IE] hello
```

## Faml, Haml
```html
<!--[if IE]> hello <![endif]-->

```

## Hamlit
```html
<!--[if IE] hello>
<![endif]-->

```

