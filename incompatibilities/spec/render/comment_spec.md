# [./spec/render/comment_spec.rb:32](../../../spec/render/comment_spec.rb#L32)
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

