# [./spec/render/indent_spec.rb:41](../../../spec/render/indent_spec.rb#L41)
## Input
```haml
%p
	%a

```

## Faml (Error)
```html
Indentation with hard tabs are not allowed :-p
```

## Haml, Hamlit
```html
<p>
<a></a>
</p>

```

