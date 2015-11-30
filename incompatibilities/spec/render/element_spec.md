# [./spec/render/element_spec.rb:57](../../../spec/render/element_spec.rb#L57)
## Input
```haml
- @var = '</span>'
%span
  hello <span> #@var </span>

```

## Faml, Hamlit
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

