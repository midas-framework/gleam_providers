import gleam/list
import gleam/string

pub fn extension() {
  ".schema.env"
}

const module_template = "
import gleam/map
import gleam/option.{Option}
import gleam/os
import gleam/result

pub type Env{
    Env(
      RECORD_FIELDS
    )
}

pub fn from_env() {
    let raw = os.get_env()
    cast_env(raw)
}

pub fn cast_env(raw) {
    ENV_CHECKS
    Ok(Env(RECORD_KEYS))
}
"

fn render(specs) {
  module_template
  |> string.replace("RECORD_FIELDS", record_fields(specs))
  |> string.replace("ENV_CHECKS", env_checks(specs))
  |> string.replace("RECORD_KEYS", record_keys(specs))
}

fn record_fields(specs) {
  specs
  |> list.map(record_field)
  |> string.join(",\r\n")
}

fn record_field(spec) {
  let tuple(key, spec) = spec
  case spec {
    Required | Fallback(_fallback) ->
      string.concat([string.lowercase(key), ": String"])
    Optional -> string.concat([string.lowercase(key), ": Option(String)"])
  }
}

fn env_checks(specs) {
  specs
  |> list.map(env_check)
  |> string.join("\r\n")
}

fn env_check(spec) {
  case spec {
    tuple(key, Required) ->
      "try RECORD_KEY = map.get(raw, \"ENV_KEY\")"
      |> string.replace("RECORD_KEY", string.lowercase(key))
      |> string.replace("ENV_KEY", key)
    tuple(key, Optional) ->
      "let RECORD_KEY = map.get(raw, \"ENV_KEY\") |> option.from_result"
      |> string.replace("RECORD_KEY", string.lowercase(key))
      |> string.replace("ENV_KEY", key)
    tuple(key, Fallback(fallback)) ->
      "let RECORD_KEY = map.get(raw, \"ENV_KEY\") |> result.unwrap(\"FALLBACK\")"
      |> string.replace("RECORD_KEY", string.lowercase(key))
      |> string.replace("ENV_KEY", key)
      |> string.replace("FALLBACK", fallback)
  }
}

fn record_keys(specs) {
  specs
  |> list.map(fn(spec: tuple(String, EnvSpec)) { string.lowercase(spec.0) })
  |> string.join(", ")
}

pub fn provide(raw) {
  raw
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.filter(non_empty)
  |> list.map(parse_spec)
  |> render()
}

fn non_empty(line) {
  // already trimmed
  "" != line
}

type EnvSpec {
  Required
  Optional
  Fallback(fallback: String)
}

fn parse_spec(line) {
  case string.split_once(line, "?") {
    Ok(tuple(key, "")) -> tuple(key, Optional)
    Ok(tuple(key, fallback)) -> tuple(key, Fallback(fallback))
    Error(Nil) -> tuple(line, Required)
  }
}
