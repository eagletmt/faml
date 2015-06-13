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

# [./spec/render/comment_spec.rb:55](../../../spec/render/comment_spec.rb#L55)
## Input
```haml
/ hehehe
  %span hello

```

## Faml (Error)
```html
Illegal nesting: nesting within a html comment that already has content is illegal.
```

## Haml (Error)
```html
Illegal nesting: nesting within a tag that already has content is illegal.
```

## Hamlit
```html
<!-- hehehe -->

```

