[![Hex pm](https://img.shields.io/hexpm/v/wipo_st3.svg?style=flat)](https://hex.pm/packages/wipo_st3) [![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://wipo-st3.hexdocs.pm)

# WIPO ST.3 Country Codes

[Codes and English names](https://www.wipo.int/en/web/pct-system/guide/index) ([→ direct link to PDF](https://www.wipo.int/documents/d/standards/docs-en-03-03-01.pdf)) of states, intergovernmental organizations and other entities packaged for your convenience.

WIPO recommends the use of `XX`/`:xx` to refer to unknown states, entities or organizations. While this is currently not supported by `wipo_st3`, it can be included if the need arises. Do you want to allow an unknown origin in your data model? Do you need to?

The codes and their English names are read from `priv/wipo_st3_codes.json` while the library is compiled.

## Wrong Exit?

If you're looking for country codes as known from domains or football matches you're in the wrong place; WIPO ST.3 is aimed at patents, trademarks and plant variety protection use cases.

## Installation

The package can be installed by adding `wipo_st3` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:wipo_st3, "~> 1.0.0"}
  ]
end
```

If `igniter` is installed you can instead run:

```sh
mix igniter.add wipo_st3
```
## Changelog

Updates to WIPO Standard ST.3 are announced by the [Committee on WIPO Standards (CWS)](https://www.wipo.int/en/web/cws/circulars/index).

* v1.0.0 - Initial release covering revision 2026-09-02


## Usage

```elixir
iex> WipoSt3.parse_code("qz")
{:ok, :qz}

iex> WipoSt3.name(:qz)
"Community Plant Variety Office (European Union) (CPVO)"

iex> WipoSt3.parse_code("zz")
{:error, :unknown_wipo_country_code}

iex> WipoSt3.to_select_options() |> Enum.take(2)
[{"Afghanistan", :af}, {"African Intellectual Property Organization (OAPI)", :oa}]

iex> WipoSt3.to_ash_enum_values() |> Keyword.fetch!(:at)
[label: "Austria"]
```

### Phoenix Selects

If you need compabitility with `Phoenix.HTML.Form.options_for_select/3` use `WipoSt3.to_select_options/0` to create the options for a HTML `select`:

```heex
<%= select f, :wipo_country_code, WipoSt3.to_select_options() %>
```

### Ash Enums

`WipoSt3.to_ash_enum_values/0` can be passed to Ash:

```elixir
defmodule MyApp.CountryCode do
  use Ash.Type.Enum, values: WipoSt3.to_ash_enum_values()
end
```

Full documentation can be found at <https://hexdocs.pm/wipo_st3>.
