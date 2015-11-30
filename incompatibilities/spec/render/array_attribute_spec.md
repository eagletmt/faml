# [./spec/render/array_attribute_spec.rb:35](../../../spec/render/array_attribute_spec.rb#L35)
## Input
```haml
%span{class: []}
```

## Faml
```html
<span></span>

```

## Haml, Hamlit
```html
<span class=''></span>

```

# [./spec/render/array_attribute_spec.rb:35](../../../spec/render/array_attribute_spec.rb#L35)
## Input
```haml
- v = []
%span{class: v}
```

## Faml
```html
<span></span>

```

## Haml, Hamlit
```html
<span class=''></span>

```

# [./spec/render/array_attribute_spec.rb:35](../../../spec/render/array_attribute_spec.rb#L35)
## Input
```haml
- h = {class: []}
%span{h}
```

## Faml
```html
<span></span>

```

## Haml, Hamlit
```html
<span class=''></span>

```

# [./spec/render/array_attribute_spec.rb:61](../../../spec/render/array_attribute_spec.rb#L61)
## Input
```haml
%span{id: []}
```

## Faml
```html
<span></span>

```

## Haml, Hamlit
```html
<span id=''></span>

```

# [./spec/render/array_attribute_spec.rb:61](../../../spec/render/array_attribute_spec.rb#L61)
## Input
```haml
- v = []
%span{id: v}
```

## Faml
```html
<span></span>

```

## Haml, Hamlit
```html
<span id=''></span>

```

# [./spec/render/array_attribute_spec.rb:61](../../../spec/render/array_attribute_spec.rb#L61)
## Input
```haml
- h = {id: []}
%span{h}
```

## Faml
```html
<span></span>

```

## Haml, Hamlit
```html
<span id=''></span>

```

