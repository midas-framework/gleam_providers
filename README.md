# Gleam Providers

This is a project aims to be a framework for allowing Gleam Programs type safe interaction with external sources,
e.g. CSV, JSON, API's and SQL.

## Usage

### 1. Add this project to your dependencies, 
along with any providers for data sources you require.

```exs
{:gleam_providers, "~> 0.1.0"},

{:gleam_providers_csv, "~> 0.1.0"},
{:gleam_providers_json_schema, "~> 0.1.0"},
```

### 2. Modify `mix.exs` to have Gleam Providers amongst the list of compilers.

```elixir
defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_app,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      erlc_paths: ["src", "gen"],
      compilers: [:gleam_providers, :gleam | Mix.compilers()],
      deps: deps()
    ]
  end
# ...
```

**Gleam Providers includes an environment variables provider as an example**

### 3. Add a schema file for your datasource

For our example let's define the env variables we expect in `src/my_app/config.schema.env

```
FOO
BAR?
BAZ?fallback value
```

*This file specifies that a `FOO` environment variable is expected, `BAR` and `BAZ` are optional with a fallback value existing for `BAZ`*

### 4. Enjoy typesafe access to your datasource


```rust
import my_app/config

pub fn main() {
  let config = config.from_env()
  submodule.do_something(config)
}
```

```rust
import my_app/config.{Env}

pub fn do_something(config) {
  let foo: String = config.foo
  let bar: Option(String) = config.bar
  let baz: String = config.baz
  // ...
}
```


## How it works

At compiletime schema files describing a data source are transformed into Gleam code that defines a type for that data source,
along with various utilities such as encoded in decoding functions.

## Write your own providers

A provider is a module defined at `src/gleam/providers/my_provider`

This module must define two functions.
```rust
pub fn extension() {
  ".my.extension"
}

pub fn provide(schema: String) -> String {
  // Return valid Gleam Code.
}
```

## Future work

These are inspired by Fsharp Type Providers, it would be nicer to have better integration into the Gleam language.

### Don't rely on the filesystem

At the moment compilation of the provider schema's generates Gleam files which are stored amongst the source, it would be nice to not do this.
It would also alow providers to be a single function and not need to define an extension they rely on.

### Helpers for generating gleam code

At the moment the return value of the `provide` function is Gleam code in string format, 
it would be nicer to have helpers in this providers library that specific providers could rely on for generating Gleam code.

One thing of note is this would end up being faily close to defining an AST for Gleam in Gleam, currently an AST for Gleam only exists in Rust code.

### Be able to run gleam code at compilation time without erlang

This is a long shot but at the moment this works only for gleam projects using Mix.
Steps to improve this could be to use Escripts instead of relying on Mix.
Eventually using a different Rust backend that is easier to ship with the compiler would be useful.
Gleam to WASM JS or RUST would all be improvements.
