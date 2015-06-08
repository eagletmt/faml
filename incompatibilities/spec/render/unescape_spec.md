# [./spec/render/unescape_spec.rb:17](../../../spec/render/unescape_spec.rb#L17)
## Input
```haml
!<p>hello</p>
```

## Faml, Hamlit
```html
<p>hello</p>

```

## Haml
```html
!<p>hello</p>

```

# [./spec/render/unescape_spec.rb:33](../../../spec/render/unescape_spec.rb#L33)
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
~ "<p>hello\n<pre>pre\nworld</pre></p>"

```

# [./spec/render/unescape_spec.rb:33](../../../spec/render/unescape_spec.rb#L33)
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

