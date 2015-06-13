# [./spec/render/plain_spec.rb:8](../../../spec/render/plain_spec.rb#L8)
## Input
```haml
%span foo\\#{1 + 2}bar

```

## Faml, Haml
```html
<span>foo\3bar</span>

```

## Hamlit
```html
<span>foo\\3bar</span>

```

# [./spec/render/plain_spec.rb:21](../../../spec/render/plain_spec.rb#L21)
## Input
```haml
hello
  world

```

## Faml (Error)
```html
nesting within plain text is illegal
```

## Haml (Error)
```html
Illegal nesting: nesting within plain text is illegal.
```

## Hamlit
```html
hello

```

