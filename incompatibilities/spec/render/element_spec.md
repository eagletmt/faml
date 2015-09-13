# [./spec/render/element_spec.rb:56](../../../spec/render/element_spec.rb#L56)
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

