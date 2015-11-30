# [./spec/render/filters/preserve_spec.rb:5](../../../../spec/render/filters/preserve_spec.rb#L5)
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
hello&#x000A;  <p>wor
ld</p>&#x000A;<span>hello</span>&#x000A;
<span>end</span>

```

# [./spec/render/filters/preserve_spec.rb:16](../../../../spec/render/filters/preserve_spec.rb#L16)
## Input
```haml
:preserve
  hello


%p

```

## Faml, Haml
```html
hello&#x000A;&#x000A;
<p></p>

```

## Hamlit
```html
hello&#x000A;
<p></p>

```

