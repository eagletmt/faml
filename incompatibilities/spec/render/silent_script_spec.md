# [./spec/render/silent_script_spec.rb:52](../../../spec/render/silent_script_spec.rb#L52)
## Input
```haml
%div
  - case
  - when 1.even?
    even
  - when 2.even?
    2
    even
  - else
    else

```

## Faml, Hamlit
```html
<div>
2
even
</div>

```

## Haml (Error)
```html
(haml):9: syntax error, unexpected keyword_end, expecting end-of-input
...upper if @haml_buffer;end;; end
...                               ^
```

