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

# [./spec/render/element_spec.rb:117](../../../spec/render/element_spec.rb#L117)
## Input
```haml
%p/ hello
```

## Faml (Error)
```html
Self-closing tags can't have content
```

## Haml (Error)
```html
Self-closing tags can't have content.
```

## Hamlit
```html
<p>

```

# [./spec/render/element_spec.rb:121](../../../spec/render/element_spec.rb#L121)
## Input
```haml
%p/
  hello

```

## Faml (Error)
```html
Illegal nesting: nesting within a self-closing tag is illegal
```

## Haml (Error)
```html
Illegal nesting: nesting within a self-closing tag is illegal.
```

## Hamlit
```html
<p>
hello
</p>

```

