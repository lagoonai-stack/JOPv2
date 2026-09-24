# 🎬 One Prompt

A minimal **Rails 8** application with authentication, subscriptions, and an AI-powered “Just One Prompt” chat experience.

---

## ✨ Features

- User authentication (Devise + remember me)
- Admin panel (ActiveAdmin)
- AI chat (**Just One Prompt**) powered by OpenAI
- Stripe subscriptions (Card + PIX)
- Plan-based limits (prompts + tokens)
- PostgreSQL
- RSpec test suite
- Production security hardening

---

## 🧱 Tech Stack

- **Ruby** 3.4.3 (recommended via RVM)
- **Rails** 8.1.2
- **PostgreSQL**
- **Devise**
- **ActiveAdmin**
- **Stripe**
- **OpenAI Responses API** via the official `openai` Ruby SDK

---

# 🚀 Setup

You can run this project in two ways:

1. 🐳 **Docker Compose (fastest way)**
2. 💻 **Local setup (RVM + PostgreSQL)**

---

# 🐳 Option 1 — Docker Setup

## Requirements

- Docker
- Docker Compose

Install Docker:

- macOS: https://docs.docker.com/desktop/install/mac-install/
- Linux: https://docs.docker.com/engine/install/

Verify installation:

```bash
docker --version
docker compose version
```

## Run the Application

```bash
docker compose build
docker compose up
```

The web container waits for PostgreSQL, then runs **pending migrations** automatically (`db:prepare`). No need to run `db:create` or `db:migrate` by hand. To load seed data (optional):

```bash
docker compose exec web bin/rails db:seed
```

Access:

```
http://localhost:3000
```

Stop containers:

```bash
docker compose down
```

## Stripe webhooks (Docker, local)

To forward Stripe webhooks to the app inside Docker, use the `webhooks` profile. Ensure `STRIPE_SECRET_KEY` (and optionally `STRIPE_WEBHOOK_SECRET`) are set in `.env.local`. The Stripe CLI will use that key and forward events to the Rails app.

```bash
docker compose --profile webhooks up
```

The `stripe` service runs `stripe listen --forward-to http://web:3000/webhooks/stripe`. Use the webhook signing secret printed by the CLI (or the one in `.env.local`) for `STRIPE_WEBHOOK_SECRET`.

---

# 💻 Option 2 — Local Setup (RVM + PostgreSQL)

Recommended for development.

---

## 1️⃣ Install RVM (Ruby Version Manager)

Official site: https://rvm.io/

### macOS

```bash
\curl -sSL https://get.rvm.io | bash -s stable
source "$HOME/.rvm/scripts/rvm"
```

### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install curl gpg build-essential libssl-dev libreadline-dev zlib1g-dev -y
\curl -sSL https://get.rvm.io | bash -s stable
source "$HOME/.rvm/scripts/rvm"
```

Verify installation:

```bash
rvm --version
```

---

## 2️⃣ Install Ruby 3.4.3

```bash
rvm install 3.4.3
rvm use 3.4.3 --default
ruby -v
```

---

## 3️⃣ Install PostgreSQL

Official downloads: https://www.postgresql.org/download/

### macOS (Homebrew)

Install Homebrew (if needed): https://brew.sh/

```bash
brew install postgresql
brew services start postgresql
```

### Linux (Ubuntu/Debian)

```bash
sudo apt install postgresql postgresql-contrib libpq-dev -y
sudo service postgresql start
```

Create database user (if needed):

```bash
sudo -u postgres createuser -s root
```

---

## 4️⃣ Clone & Install Dependencies

```bash
git clone <your-repo-url>
cd one-prompt
source "$HOME/.rvm/scripts/rvm"
rvm use .
bundle install
```

---

## 5️⃣ Database Configuration

Expected defaults (`config/database.yml`):

```
DB_USER=root
DB_PASSWORD=
DB_HOST=localhost
```

Create and migrate:

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

---

## 6️⃣ Start the Server

```bash
bin/rails server
```

Open:

```
http://localhost:3000
```

---

# 🔐 Environment Variables

Create a `.env.local` file or export manually:

```bash
export OPENAI_API_KEY=your_key_here
export STRIPE_PUBLISHABLE_KEY=your_key
export STRIPE_SECRET_KEY=your_key
export STRIPE_WEBHOOK_SECRET=your_secret
```

Optional:

```bash
export OPENAI_MODEL=gpt-5.1
```

---

# 🤖 Just One Prompt (AI Chat)

- URL: `/chat`
- Authenticated users only
- Uses `movie-maker` agent
- Token usage tracked per conversation
- Plan limits enforced automatically

Agent configuration:

```
config/initializers/openai_agents.rb
```

---

# 💳 Subscriptions (Stripe)

### Plans

| Plan    | Price (BRL) | Prompts | Tokens |
|---------|------------|---------|--------|
| Starter | R$ 49,90   | 30/mo   | 60k    |
| Pro     | R$ 67,90   | 60/mo   | 120k   |

Webhook endpoint:

```
POST /webhooks/stripe
```

No card data is stored — only payment metadata and Stripe IDs.

---

# 🛠 Admin Panel

URL:

```
/admin
```

Seeded development admin:

```
Email: admin@gmail.com
Password: Abcde,12345
```

---

# 🛡 Security

- Password minimum: 12 characters
- Devise paranoid mode enabled
- HTTP-only + SameSite cookies
- Rack::Attack throttling
- Force SSL in production

---

# 🧪 Tests

```bash
bundle exec rspec
```

---

# 🔔 Stripe CLI — Local Webhook Testing

To test Stripe webhooks locally, use the Stripe CLI.

## Install Stripe CLI

macOS (Homebrew):

```bash
brew install stripe/stripe-cli/stripe
```

Linux:

```bash
curl -s https://packages.stripe.dev/api/security/keypair/stripe-cli-archive-keyring.gpg | sudo tee /usr/share/keyrings/stripe.gpg
echo "deb [signed-by=/usr/share/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main" | sudo tee -a /etc/apt/sources.list.d/stripe.list
sudo apt update
sudo apt install stripe
```

Official docs: https://stripe.com/docs/stripe-cli

Login:

```bash
stripe login
```

## Forward Webhooks to Local App

Run:

```bash
stripe listen --forward-to localhost:3000/webhooks/stripe
```

Stripe will output a webhook signing secret.
Set it in your environment:

```bash
export STRIPE_WEBHOOK_SECRET=whsec_XXXXXXXX
```

Now trigger events (example):

```bash
stripe trigger checkout.session.completed
```

Your local Rails app will receive and process the webhook.
