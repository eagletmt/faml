# [./spec/compiler_newline_spec.rb:210](../../spec/compiler_newline_spec.rb#L210)
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

## Haml, Hamlit
```html
1 1 1
<span>4</span>

```

