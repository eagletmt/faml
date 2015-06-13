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

# [./spec/render/comment_spec.rb:51](../../../spec/render/comment_spec.rb#L51)
## Input
```haml
/[[if IE]
```

## Faml (Error)
```html
Unmatched brackets in conditional comment
```

## Haml (Error)
```html
Unbalanced brackets.
```

## Hamlit
```html
<!--[[if IE]>
<![endif]-->

```

