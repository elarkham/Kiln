# Kiln

Job server because I didn't like any of the other ones enough

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kiln` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kiln, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/golem](https://hexdocs.pm/golem).

## Objectives

### Minimum
- [x] Allow arbitrary jobs to be run async
- [x] Number of jobs run at once should be configurably limited
- [x] Jobs are stored in queue, only removed once job is finished
- [-] Queue should be persisted in between application restarts
- [-] Should work with postgres

### Primary
- [x] Job progress should be easily tracked
- [x] Jobs should be given a configurable priority
- [x] Job failures should be clearly reported
- [ ] Job failure handling should be configurable
- [-] Support multiple kinds of DB for persistence
- [ ] Duration Logging
- [x] Max Attempts

### Extended
- [ ] Configurable job timeouts
- [+] Job cancellation support
- [ ] Multi-Node support (via Horde?)
- [ ] Scheduled Jobs (Cron/Quantum-Like)
- [ ] Web Interface
- [ ] Make API more magical sounding

## Magic Naming Ideas
(Because it's more fun this way)

Job Definition -> Chem  | Mandate, Order, Decree
Job Struct     -> Golem | Imp, Minion, Demon, Slave, Servant

Get     -> Summon  (only from external data sources)
New     -> Conjure,   Bake
Delete  -> Destroy,   Crush
Convert -> Transmute, Rebake


