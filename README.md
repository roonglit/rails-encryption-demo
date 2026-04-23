# Rails Encryption Demo

A minimal Rails 8.1 playground for exploring **Active Record encryption** — deterministic queries, key rotation, and transparent serialization — on top of Devise authentication and a Tailwind-styled UI.

## Stack

- Ruby 3.3.4 / Rails 8.1
- SQLite (primary + Solid Cache / Solid Queue / Solid Cable)
- Propshaft, Importmap, Hotwire (Turbo + Stimulus)
- Tailwind CSS v4 (via `tailwindcss-rails`)
- Devise for authentication, with custom Tailwind views

## Getting started

```bash
bin/setup          # install gems, prepare DB, start the server
# or, without starting the server:
bin/setup --skip-server
```

Then run the app:

```bash
bin/dev            # boots Rails + Tailwind watcher on port 3000
```

Visit <http://localhost:3000>. You'll be redirected to `/users/sign_in` — create an account from there.

## Commands

| Task                  | Command                           |
| --------------------- | --------------------------------- |
| Run server + CSS      | `bin/dev`                         |
| Run tests             | `bin/rails test`                  |
| Run a single test     | `bin/rails test path/to_test.rb:LINE` |
| System tests          | `bin/rails test:system`           |
| Rebuild Tailwind once | `bin/rails tailwindcss:build`     |
| Lint (RuboCop)        | `bin/rubocop`                     |
| Security scan         | `bin/brakeman`                    |
| Full CI pipeline      | `bin/ci`                          |

## Authentication

Every controller requires a signed-in user by default (`authenticate_user!` is declared in `ApplicationController`). Add `skip_before_action :authenticate_user!` on any controller you want to expose publicly.

Devise's sign-in, sign-up, password-reset, and account-settings screens are rendered through a dedicated `layouts/devise.html.erb` with Tailwind styling; `ApplicationController` switches layouts automatically for Devise controllers.
