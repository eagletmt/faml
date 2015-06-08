# [./spec/render/filters/preserve_spec.rb:4](../../../../spec/render/filters/preserve_spec.rb#L4)
## Input
```haml
%span start
:preserve
  hello
    #{"<p>wor\nld</p>"}
  <span>hello</span>
%span end

```

## Faml, Haml
```html
<span>start</span>
hello&#x000A;  <p>wor&#x000A;ld</p>&#x000A;<span>hello</span>
<span>end</span>

```

## Hamlit
```html
<span>start</span>
hello&#x000A;  &lt;p&gt;wor
ld&lt;/p&gt;&#x000A;<span>hello</span>
<span>end</span>

```

