# [./spec/render/newline_spec.rb:20](../../../spec/render/newline_spec.rb#L20)
## Input
```haml
%div
  - 2.times do |i|
    %span>= i

```

## Faml, Haml
```html
<div><span>0</span><span>1</span></div>

```

## Hamlit
```html
<div>
<span>0</span><span>1</span></div>

```

# [./spec/render/newline_spec.rb:28](../../../spec/render/newline_spec.rb#L28)
## Input
```haml
%div
  /
    - 2.times do |i|
      %span>= i

```

## Faml, Haml
```html
<div>
<!--<span>0</span><span>1</span>-->
</div>

```

## Hamlit
```html
<div>
<!--
<span>0</span><span>1</span>--></div>

```

# [./spec/render/newline_spec.rb:37](../../../spec/render/newline_spec.rb#L37)
## Input
```haml
%div
  / [if IE]
    - 2.times do |i|
      %span>= i

```

## Faml, Haml
```html
<div>
<!--[if IE]><span>0</span><span>1</span><![endif]-->
</div>

```

## Hamlit
```html
<div>
<!--[if IE]>
<span>0</span><span>1</span><![endif]--></div>

```

# [./spec/render/newline_spec.rb:72](../../../spec/render/newline_spec.rb#L72)
## Input
```haml
%div(foo="bar") <b>hello</b>
```

## Faml, Haml
```html
<div foo='bar'><b>hello</b></div>

```

## Hamlit (Error)
```html
Generator supports only core expressions - found ["b>"]
```

