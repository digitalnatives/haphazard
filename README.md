# Haphazard

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
Source code is released under MIT License. Check LICENSE for more information.
