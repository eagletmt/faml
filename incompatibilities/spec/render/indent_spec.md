# [./spec/render/indent_spec.rb:17](../../../spec/render/indent_spec.rb#L17)
## Input
```haml
%div
  %div
      %div

```

## Faml (Error)
```html
Inconsistent indentation: 4 spaces used for indentation, but the rest of the document was indented using 2 spaces.
```

## Haml (Error)
```html
The line was indented 2 levels deeper than the previous line.
```

## Hamlit
```html
<div>
<div>
</div>
</div>

```

# [./spec/render/indent_spec.rb:29](../../../spec/render/indent_spec.rb#L29)
## Input
```haml
%div
    %div
      %div

```

## Faml (Error)
```html
Inconsistent indentation: 2 spaces used for indentation, but the rest of the document was indented using 4 spaces.
```

## Haml (Error)
```html
Inconsistent indentation: 6 spaces used for indentation, but the rest of the document was indented using 4 spaces.
```

## Hamlit
```html
<div>
<div></div>
<div></div>
</div>

```

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

