# Haphazard [![Build Status](https://travis-ci.org/digitalnatives/haphazard.svg?branch=master)](https://travis-ci.org/digitalnatives/haphazard) [![Coverage Status](https://coveralls.io/repos/github/digitalnatives/haphazard/badge.svg?branch=master)](https://coveralls.io/github/digitalnatives/haphazard?branch=master) [![hex.pm version](https://img.shields.io/hexpm/v/haphazard.svg)](https://hex.pm/packages/haphazard) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/digitalnatives/haphazard.svg)](https://beta.hexfaktor.org/github/digitalnatives/haphazard) [![Hex.pm](https://img.shields.io/hexpm/l/haphazard.svg "License")](LICENSE)

Haphazard is an ETS based plug for caching response body.
Check the [Online Documentation](https://hexdocs.pm/haphazard)

## Installation

Add `haphazard` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:haphazard, "~> 0.3.0"}]
end
```
put it in `applications`
```elixir
applications: [:logger, ..., :haphazard]
```

## Usage
Setup in your plug router:
```elixir
plug Haphazard.Plug
```
Additional configurations (optional):
```elixir
plug Haphazard.Plug,
  methods: ~w(GET HEAD),
  path: ~r/\/myroute/,
  ttl: 60_000,
  enabled: true
```

The additional configurations reflect the default values.

## License
Source code is released under MIT License. Check [LICENSE](LICENSE) for more information.
