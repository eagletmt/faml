# [./spec/render/sanitize_spec.rb:24](../../../spec/render/sanitize_spec.rb#L24)
## Input
```haml
&~ "<p>hello</p>"
```

## Faml, Haml
```html
&lt;p&gt;hello&lt;/p&gt;

```

## Hamlit
```html
~ "<p>hello</p>"

```

# [./spec/render/sanitize_spec.rb:24](../../../spec/render/sanitize_spec.rb#L24)
## Input
```haml
%span&~ "<p>hello</p>"
```

## Faml, Haml
```html
<span>&lt;p&gt;hello&lt;/p&gt;</span>

```

## Hamlit
```html
<span>~ "<p>hello</p>"</span>

```

