# [./spec/render/array_attribute_spec.rb:11](../../../spec/render/array_attribute_spec.rb#L11)
## Input
```haml
- h1 = {class: 'c1', id: ['id1', 'id3']}
- h2 = {class: [{}, 'c2'], id: 'id2'}
%span#main.content{h1, h2} hello

```

## Faml, Haml
```html
<span class='c1 c2 content {}' id='main_id1_id3_id2'>hello</span>

```

## Hamlit
```html
<span class='c1 content c2 {}' id='main_id1_id3_id2'>hello</span>

```

# [./spec/render/array_attribute_spec.rb:19](../../../spec/render/array_attribute_spec.rb#L19)
## Input
```haml
%span.foo{class: "foo bar"}
```

## Faml, Haml
```html
<span class='bar foo'></span>

```

## Hamlit
```html
<span class='foo bar foo'></span>

```

# [./spec/render/array_attribute_spec.rb:19](../../../spec/render/array_attribute_spec.rb#L19)
## Input
```haml
- v = 'foo bar'
%span.foo{class: v}
```

## Faml, Haml
```html
<span class='bar foo'></span>

```

## Hamlit
```html
<span class='foo foo bar'></span>

```

# [./spec/render/array_attribute_spec.rb:19](../../../spec/render/array_attribute_spec.rb#L19)
## Input
```haml
- h = {class: 'foo bar'}
%span.foo{h}
```

## Faml, Haml
```html
<span class='bar foo'></span>

```

## Hamlit
```html
<span class='foo foo bar'></span>

```

# [./spec/render/array_attribute_spec.rb:37](../../../spec/render/array_attribute_spec.rb#L37)
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

# [./spec/render/array_attribute_spec.rb:41](../../../spec/render/array_attribute_spec.rb#L41)
## Input
```haml
%span{class: [1, nil, false, true]}
```

## Faml, Haml
```html
<span class='1 true'></span>

```

## Hamlit
```html
<span class='1  false true'></span>

```

# [./spec/render/array_attribute_spec.rb:41](../../../spec/render/array_attribute_spec.rb#L41)
## Input
```haml
- v = [1, nil, false, true]
%span{class: v}
```

## Faml, Haml
```html
<span class='1 true'></span>

```

## Hamlit
```html
<span class='1  false true'></span>

```

# [./spec/render/array_attribute_spec.rb:41](../../../spec/render/array_attribute_spec.rb#L41)
## Input
```haml
- h = { class: [1, nil, false, true] }
%span{h}
```

## Faml, Haml
```html
<span class='1 true'></span>

```

## Hamlit
```html
<span class='1  false true'></span>

```

# [./spec/render/array_attribute_spec.rb:63](../../../spec/render/array_attribute_spec.rb#L63)
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

# [./spec/render/array_attribute_spec.rb:67](../../../spec/render/array_attribute_spec.rb#L67)
## Input
```haml
%span{id: [1, nil, false, true]}
```

## Faml, Haml
```html
<span id='1_true'></span>

```

## Hamlit
```html
<span id='1__false_true'></span>

```

# [./spec/render/array_attribute_spec.rb:67](../../../spec/render/array_attribute_spec.rb#L67)
## Input
```haml
- v = [1, nil, false, true]
%span{id: v}
```

## Faml, Haml
```html
<span id='1_true'></span>

```

## Hamlit
```html
<span id='1__false_true'></span>

```

# [./spec/render/array_attribute_spec.rb:67](../../../spec/render/array_attribute_spec.rb#L67)
## Input
```haml
- h = { id: [1, nil, false, true] }
%span{h}
```

## Faml, Haml
```html
<span id='1_true'></span>

```

## Hamlit
```html
<span id='1__false_true'></span>

```

