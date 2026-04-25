# Rails Encryption Demo

A minimal Rails 8.1 playground for exploring **Active Record encryption** — encrypting OAuth access/refresh tokens at the model boundary — on top of Devise authentication (email + "Sign in with Google") and a Tailwind-styled UI.

Companion repo for the article *How to Safely Store OAuth Access Tokens in Rails with Active Record Encryption*(https://medium.com/@roonglit/how-to-safely-store-oauth-access-tokens-in-rails-with-active-record-encryption-56d1ca3bce6c).

## Stack

- Ruby 3.3.4 / Rails 8.1
- SQLite (primary + Solid Cache / Solid Queue / Solid Cable)
- Propshaft, Importmap, Hotwire (Turbo + Stimulus)
- Tailwind CSS v4 (via `tailwindcss-rails`)
- Devise + `omniauth-google-oauth2` for authentication

## First-time setup

Neither `config/master.key` nor `config/credentials.yml.enc` is committed — both are generated locally on first run so you start with your own secrets. The whole bootstrap takes about two minutes:

### 1. Install dependencies

```bash
bin/setup --skip-server
```

### 2. Generate Rails credentials

```bash
EDITOR="code --wait" bin/rails credentials:edit  # or "vim", "nano", etc.
```

On first run this creates `config/master.key` (gitignored) and `config/credentials.yml.enc` with a fresh `secret_key_base`. Save and close the editor to encrypt.

### 3. Add Active Record encryption keys

```bash
bin/rails db:encryption:init
```

It prints a YAML block. Re-open credentials with `EDITOR="..." bin/rails credentials:edit` and paste it at the bottom:

```yaml
active_record_encryption:
  primary_key: <generated>
  deterministic_key: <generated>
  key_derivation_salt: <generated>
```

⚠️ **Back up your `master.key`.** If you lose it, every encrypted token in the database becomes permanently unreadable.

### 4. Configure Google OAuth (optional)

Only needed if you want to exercise "Sign in with Google". Create `.env` at the repo root (already gitignored):

```
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-secret
```

In Google Cloud Console → **APIs & Services** → **Credentials** → your OAuth client, add:

- Authorized redirect URI: `http://localhost:3000/users/auth/google_oauth2/callback`
- Authorized JavaScript origin: `http://localhost:3000`

The initializer at `config/initializers/devise.rb` already passes `access_type: "offline"` and `prompt: "consent"`, which is what tells Google to actually issue a `refresh_token` (otherwise you only get the short-lived access token).

### 5. Migrate and run

```bash
bin/rails db:prepare
bin/dev                  # boots Rails + Tailwind watcher on port 3000
```

Visit <http://localhost:3000> and either create a password account or use **Sign in with Google**.

## Verifying encryption is actually doing something

After signing in with Google, peek at the raw row:

```bash
bin/rails runner 'puts ActiveRecord::Base.connection.select_value("SELECT access_token FROM oauth_identities LIMIT 1")'
```

You should see a JSON envelope, not a plaintext token:

```
{"p":"...","h":{"iv":"...","at":"...","c":true}}
```

Read it back through the model and it decrypts transparently:

```bash
bin/rails runner 'puts OauthIdentity.last.access_token'
# => ya29.a0AfB_byC...
```

## Commands

| Task                  | Command                               |
| --------------------- | ------------------------------------- |
| Run server + CSS      | `bin/dev`                             |
| Run tests             | `bin/rails test`                      |
| Run a single test     | `bin/rails test path/to_test.rb:LINE` |
| System tests          | `bin/rails test:system`               |
| Rebuild Tailwind once | `bin/rails tailwindcss:build`         |
| Lint (RuboCop)        | `bin/rubocop`                         |
| Security scan         | `bin/brakeman`                        |
| Full CI pipeline      | `bin/ci`                              |

## Authentication notes

Every controller requires a signed-in user by default (`authenticate_user!` is declared in `ApplicationController`). Add `skip_before_action :authenticate_user!` on any controller you want to expose publicly.

Devise's sign-in, sign-up, password-reset, and account-settings screens are rendered through a dedicated `layouts/devise.html.erb` with Tailwind styling; `ApplicationController` switches layouts automatically for Devise controllers.
