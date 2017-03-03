# plug_accept_language

parse the accept-language header

## Installation

`PlugAcceptLanguage` is [available in Hex](https://hex.pm/docs/publish) and can be installed as:

  1. Add `plug_accept_language` your list of dependencies in `mix.exs`:

        def deps do
          [{:plug_accept_language, "~> 0.1.0"}]
        end

## Usage

```elixir
acceptable_list = PlugAcceptLanguage.list(conn)
# ["en", "es", "pt"]
```
