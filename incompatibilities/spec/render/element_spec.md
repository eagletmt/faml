# [./spec/render/element_spec.rb:63](../../../spec/render/element_spec.rb#L63)
## Input
```haml
%.foo
```

## Faml (Error)
```html
Invalid element declaration
```

## Haml (Error)
```html
Invalid tag: "%.foo".
```

## Hamlit
```html
< class='foo'></>

```

# [./spec/render/element_spec.rb:84](../../../spec/render/element_spec.rb#L84)
## Input
```haml
- @var = '</span>'
%span
  hello <span> #@var </span>

```

## Faml
```html
<span>
hello <span> &lt;/span&gt; </span>
</span>

```

## Haml, Hamlit
```html
<span>
hello <span> #@var </span>
</span>

```

