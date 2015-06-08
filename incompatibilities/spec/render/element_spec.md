# [./spec/render/element_spec.rb:72](../../../spec/render/element_spec.rb#L72)
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

# [./spec/render/element_spec.rb:93](../../../spec/render/element_spec.rb#L93)
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

## Haml
```html
<span>
hello <span> #@var </span>
</span>

```

## Hamlit
```html
<span>
hello <span> #@var </span>
</span>

```

# [./spec/render/element_spec.rb:126](../../../spec/render/element_spec.rb#L126)
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

# [./spec/render/element_spec.rb:130](../../../spec/render/element_spec.rb#L130)
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

