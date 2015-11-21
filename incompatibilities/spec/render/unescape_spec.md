# [./spec/render/unescape_spec.rb:18](../../../spec/render/unescape_spec.rb#L18)
## Input
```haml
!<p>hello</p>
```

## Faml
```html
<p>hello</p>

```

## Haml, Hamlit
```html
!<p>hello</p>

```

# [./spec/render/unescape_spec.rb:34](../../../spec/render/unescape_spec.rb#L34)
## Input
```haml
!~ "<p>hello\n<pre>pre\nworld</pre></p>"
```

## Faml, Haml
```html
<p>hello
<pre>pre&#x000A;world</pre></p>

```

## Hamlit
```html
!~ "<p>hello\n<pre>pre\nworld</pre></p>"

```

# [./spec/render/unescape_spec.rb:34](../../../spec/render/unescape_spec.rb#L34)
## Input
```haml
%span!~ "<p>hello\n<pre>pre\nworld</pre></p>"
```

## Faml, Haml
```html
<span><p>hello
<pre>pre&#x000A;world</pre></p></span>

```

## Hamlit
```html
<span>~ "<p>hello\n<pre>pre\nworld</pre></p>"</span>

```

