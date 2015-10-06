# [./spec/render/filters/plain_spec.rb:4](../../../../spec/render/filters/plain_spec.rb#L4)
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

# [./spec/render/filters/plain_spec.rb:13](../../../../spec/render/filters/plain_spec.rb#L13)
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

## Haml
```html
<span>
hello

abc


<span>world</span>
</span>

```

## Hamlit
```html
<span>
hello

abc

<span>world</span>
</span>

```

