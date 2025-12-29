## Recommendation for writing config in your App

### Use `#[serde(default)]` everywhere

This is useful to allow partial config to be deserialized. Without it, you will need to write every fields of a struct to modify only one.

### Don't use different default implementation for nested struct.

Take this code as an example:

```rs
#[derive(Deserialize, Serialize)]
#[serde(default)]
struct Config {
    nested: NestedConfig,
}

#[derive(Deserialize, Serialize)]
#[serde(default)]
struct NestedConfig {
    number: u32,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            nested: NestedConfig { number: 0 },
        }
    }
}

impl Default for NestedConfig {
    fn default() -> Self {
        Self { number: 1 }
    }
}
```

With the value `{}`, `number` will be equal to `0`, while with the value `{ "nested": {} }`, it will be equal to `1`.

### Always use a String for Keys of Maps.

This include `HashMap`, `BTreeMap`, etc ...
It is firstly because `JSON schema`, `figment`, and other config formats like `kdl` or `json` doesn't support it (`ron` does tho).
This make sense when thinking about it, because for managing perfectly a `Map` independently of the App code, we need to know the exact implementation of the key comparison.
