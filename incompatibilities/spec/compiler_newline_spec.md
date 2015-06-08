# [./spec/compiler_newline_spec.rb:171](../../spec/compiler_newline_spec.rb#L171)
## Input
```haml
%span(a=1
  b=2)
= __LINE__

```

## Faml, Haml
```html
<span a='1' b='2'></span>
3

```

## Hamlit
```html
<span a='1' b='2'></span>
2

```

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

## Hamlit
```html
1 1 1
<span>2</span>

```

