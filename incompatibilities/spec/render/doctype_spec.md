# [./spec/render/doctype_spec.rb:9](../../../spec/render/doctype_spec.rb#L9)
## Input
```haml
!!! xml
```

## Faml
```html


```

## Haml
```html

```

## Hamlit (Error)
```html
Invalid xml directive in html mode
```

# [./spec/render/doctype_spec.rb:58](../../../spec/render/doctype_spec.rb#L58)
## Input
```haml
!!!
  hello

```

## Faml (Error)
```html
nesting within a header command is illegal
```

## Haml (Error)
```html
Illegal nesting: nesting within a header command is illegal.
```

## Hamlit
```html
<!DOCTYPE html>

```

