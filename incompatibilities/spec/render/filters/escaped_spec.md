# [./spec/render/filters/escaped_spec.rb:4](../../../../spec/render/filters/escaped_spec.rb#L4)
## Input
```haml
%span start
:escaped
  hello
    #{'<p>world</p>'}
  <span>hello</span>
%span end

```

## Faml, Haml
```html
<span>start</span>
hello
  &lt;p&gt;world&lt;/p&gt;
&lt;span&gt;hello&lt;/span&gt;

<span>end</span>

```

## Hamlit
```html
<span>start</span>
hello
  &lt;p&gt;world&lt;/p&gt;
&lt;span&gt;hello&lt;/span&gt;
<span>end</span>

```

