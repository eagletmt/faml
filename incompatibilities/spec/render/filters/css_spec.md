# [./spec/render/filters/css_spec.rb:24](../../../../spec/render/filters/css_spec.rb#L24)
## Input
```haml
%div
  :css
  %span hello

```

## Faml
```html
<div>
<span>hello</span>
</div>

```

## Haml
```html
<div>
<style>
  
</style>
</div>

```

## Hamlit
```html
<div>
<style>

</style>
<span>hello</span>
</div>

```

