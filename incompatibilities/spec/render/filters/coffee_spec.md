# [./spec/render/filters/coffee_spec.rb:4](../../../../spec/render/filters/coffee_spec.rb#L4)
## Input
```haml
:coffee
  square = (x) -> x * x
  square(3)

```

## Faml
```html
<script>
(function() {
  var square;

  square = function(x) {
    return x * x;
  };

  square(3);

}).call(this);

</script>

```

## Haml
```html
<script>
  (function() {
    var square;
  
    square = function(x) {
      return x * x;
    };
  
    square(3);
  
  }).call(this);
</script>

```

# [./spec/render/filters/coffee_spec.rb:15](../../../../spec/render/filters/coffee_spec.rb#L15)
## Input
```haml
:coffee
  square = (x) -> x * x
  square(#{1 + 2})

```

## Faml
```html
<script>
(function() {
  var square;

  square = function(x) {
    return x * x;
  };

  square(3);

}).call(this);

</script>

```

## Haml
```html
<script>
  (function() {
    var square;
  
    square = function(x) {
      return x * x;
    };
  
    square(3);
  
  }).call(this);
</script>

```

