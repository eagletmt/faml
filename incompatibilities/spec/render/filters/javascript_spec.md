# [./spec/render/filters/javascript_spec.rb:24](../../../../spec/render/filters/javascript_spec.rb#L24)
## Input
```haml
%div
  :javascript
  %span world

```

## Faml
```html
<div>
<span>world</span>
</div>

```

## Haml
```html
<div>
<script>
  
</script>
</div>

```

## Hamlit
```html
<div>
<script>
  
</script>
<span>world</span>
</div>

```

