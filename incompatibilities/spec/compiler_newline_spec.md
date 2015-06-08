# [./spec/compiler_newline_spec.rb:209](../../spec/compiler_newline_spec.rb#L209)
## Input
```haml
= [__LINE__,
  __LINE__,
  __LINE__].join(' ')
%span= __LINE__

```

## Faml
```html
1 2 3
<span>4</span>

```

## Haml
```html
1 1 1
<span>4</span>

```

