# [./spec/render/filters/plain_spec.rb:5](../../../../spec/render/filters/plain_spec.rb#L5)
## Input
```haml
%span
  :plain
    he#{'llo'}
  %span world

```

## Faml
```html
<span>
hello
<span>world</span>
</span>

```

## Haml, Hamlit
```html
<span>
hello

<span>world</span>
</span>

```

# [./spec/render/filters/plain_spec.rb:14](../../../../spec/render/filters/plain_spec.rb#L14)
## Input
```haml
%span
  :plain
    he#{'llo'}

    abc

  %span world

```

## Faml
```html
<span>
hello

abc
<span>world</span>
</span>

```

## Haml, Hamlit
```html
<span>
hello

abc


<span>world</span>
</span>

```

