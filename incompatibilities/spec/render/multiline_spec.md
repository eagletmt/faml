# [./spec/render/multiline_spec.rb:22](../../../spec/render/multiline_spec.rb#L22)
## Input
```haml
%p
  foo  |
bar |
  baz |

```

## Faml, Haml
```html
<p>
foo  bar baz 
</p>

```

## Hamlit
```html
<p>
foo bar baz 
</p>

```

# [./spec/render/multiline_spec.rb:47](../../../spec/render/multiline_spec.rb#L47)
## Input
```haml
:javascript
  hello |
  world |
= __LINE__

```

## Faml, Haml
```html
<script>
  hello |
  world |
</script>
4

```

## Hamlit
```html
<script>
  hello world 
</script>
2

```

