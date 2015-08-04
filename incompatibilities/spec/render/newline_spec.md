# [./spec/render/newline_spec.rb:19](../../../spec/render/newline_spec.rb#L19)
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

# [./spec/render/newline_spec.rb:27](../../../spec/render/newline_spec.rb#L27)
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

# [./spec/render/newline_spec.rb:36](../../../spec/render/newline_spec.rb#L36)
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

# [./spec/render/newline_spec.rb:71](../../../spec/render/newline_spec.rb#L71)
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

