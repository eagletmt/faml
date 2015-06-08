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

