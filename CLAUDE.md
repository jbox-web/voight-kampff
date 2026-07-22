# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Voight-Kampff is a Ruby gem that detects bots/crawlers/spiders by matching a request's
User-Agent string against a JSON list of known crawler patterns
(`config/crawler-user-agents.json`, sourced from monperrus/crawler-user-agents).

## Commands

- Run tests: `bin/rspec`
- Run a single spec file: `bin/rspec spec/lib/voight_kampff/test_spec.rb`
- Run a single example by line: `bin/rspec spec/lib/voight_kampff/test_spec.rb:12`
- Lint: `bin/rubocop`
- Default rake task (runs specs): `bin/rake`
- Refresh the crawler list: `bin/rake voight_kampff:import_user_agents` (downloads a fresh
  `crawler-user-agents.json` into `./config`; optional URL arg overrides the source)

Always use the project binstubs (`bin/rspec`, `bin/rubocop`, `bin/rake`, `bin/bundle`) — never
`bundle exec` or a globally installed gem.

## Architecture

Detection is centralized in `VoightKampff::Test` (`lib/voight_kampff/test.rb`). Everything else
is a thin entry point that delegates to it:

- `VoightKampff.bot?/human?` (`lib/voight_kampff.rb`) — module-level API taking a raw UA string.
- `VoightKampff::Methods` (`lib/voight_kampff/methods.rb`) — mixin providing `bot?`/`human?` that
  call `user_agent` on the host object. Included into `Rack::Request` (and thus
  `ActionDispatch::Request`).
- `bot?` is aliased as `replicant?` at every layer.

Key mechanics in `Test`:

- All crawler patterns are compiled once into a **single alternation regexp** with named groups
  (`(?<match0>...)|(?<match1>...)|...`), memoized in class variables (`@@crawler_regexp`,
  `@@crawlers`). This is a deliberate performance optimization — one regexp match instead of
  iterating hundreds of patterns. The matched group name (`match<N>`) is parsed back to an index
  to recover the crawler entry.
- `human?` means "no matching crawler entry" (empty `agent` hash); `bot?` is its negation. A blank
  UA is treated as human.
- The JSON file is resolved via `lookup_paths` in priority order: `Rails.root/config/...` first
  (if Rails is defined), then the gem's own `config/...`. This lets an app override the bundled
  list by dropping its own `config/crawler-user-agents.json`.

## Integration entry points

- Rack: `require 'voight_kampff/rack'` — reopens `Rack::Request` (`rack_request.rb`).
- Rails: `require 'voight_kampff/rails'` — loads rack integration plus `VoightKampff::Engine`
  (`engine.rb`), which registers the rake task and includes `Methods` into
  `ActionDispatch::Request` via an initializer.

Consumers pick the entry point in their Gemfile with `require:` (see README "Upgrading to 2.0").

## Testing

Specs use RSpec with **Combustion** to boot a minimal Rails app from `spec/dummy` (see
`spec_helper.rb`). Controller specs exercise the real `ActionDispatch::Request` integration
against a `ReplicantsController` that returns 403 for humans and 200 for bots.

Test fixtures live in `spec/support/humans.rb` (`HUMANS`) and `spec/support/replicants.rb`
(`REPLICANTS`) — name → UA-string maps iterated over to generate examples. Add new detection
cases there.

SimpleCov (HTML + JSON) runs on every spec run and writes to `coverage/`.

## Conventions

- Every file starts with `# frozen_string_literal: true`.
- RuboCop uses the rubocop-performance/rails/rake/rspec plugin suite with `NewCops: enable` and
  `TargetRubyVersion: 3.2`; `spec/dummy/**/*` and `bin/*` are excluded.
- Supported Ruby: `>= 3.2` (gemspec). CI matrix covers 3.2, 3.3, 3.4, 4.0.
- The gem ships only `README.md`, `LICENSE`, `lib/**/*.rb`, and `config/*.json`.
