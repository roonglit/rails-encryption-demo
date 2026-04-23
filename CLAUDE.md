# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

Rails 8.1 demo app (Ruby 3.x, see `.ruby-version`) exploring Active Record encryption. Uses SQLite for all databases (primary + solid_cache / solid_queue / solid_cable), Propshaft, Importmap, Hotwire (Turbo + Stimulus), Tailwind CSS, and Devise for authentication.

## Commands

- `bin/setup` — install dependencies, prepare DB, start the server. Pass `--skip-server` to just prepare.
- `bin/dev` — start dev server + Tailwind watcher via `Procfile.dev` (installs `foreman` on demand). Defaults to port 3000, override with `PORT=`.
- `bin/rails test` — run the Rails test suite. Single file: `bin/rails test test/models/user_test.rb`. Single test: `bin/rails test test/models/user_test.rb:12`. System tests: `bin/rails test:system` (uses Capybara + Selenium).
- `bin/rails db:seed:replant` — truncate and re-run `db/seeds.rb` (also part of CI).
- `bin/rubocop` — style (rubocop-rails-omakase).
- `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error` — static security analysis.
- `bin/bundler-audit` — gem vulnerability audit. `bin/importmap audit` — JS dependency audit.
- `bin/ci` — runs the full pipeline defined in `config/ci.rb` (setup, rubocop, brakeman, bundler-audit, importmap audit, tests, seeds replant).

## Architecture notes

- **Authentication is global.** `ApplicationController` calls `before_action :authenticate_user!`, so every controller requires a signed-in user by default. Skip with `skip_before_action :authenticate_user!` on public endpoints. Devise routes are mounted at `devise_for :users` (see `config/routes.rb`); root is `home#index`.
- **Devise uses a custom layout.** `ApplicationController#layout_by_resource` picks `layouts/devise.html.erb` whenever `devise_controller?` is true, otherwise `layouts/application.html.erb`. The Devise layout renders `flash[:notice]` / `flash[:alert]` itself, so individual Devise views don't need to. Devise views live under `app/views/devise/{sessions,registrations,passwords,shared}/` and are Tailwind-styled — the generator's `_links.html.erb` partial still exists but isn't rendered by the redesigned views.
- **Four SQLite databases in production** (`config/database.yml`): `primary`, `cache`, `queue`, `cable`, each with its own migrations directory (`db/migrate`, `db/cache_migrate`, `db/queue_migrate`, `db/cable_migrate`) and schema file (`db/schema.rb`, `db/cache_schema.rb`, `db/queue_schema.rb`, `db/cable_schema.rb`). Solid Cache / Solid Queue / Solid Cable back Rails.cache, Active Job, and Action Cable respectively — no Redis.
- **Deployment is Kamal-based** (`config/deploy.yml`, `.kamal/`) with the `thruster` gem fronting Puma for asset caching/compression. `storage/` is intended to be a persistent Docker volume since SQLite files live there.
- **Encryption demo focus.** This repo exists to exercise Active Record encryption; when adding models/fields, prefer `encrypts :field` on the model. `config/master.key` is checked in locally — `config/credentials.yml.enc` holds the encryption primary/deterministic/derivation keys used by Active Record encryption.
