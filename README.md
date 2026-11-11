# Auction_roof
group 5

## Local setup

Requirements: Ruby (see `.ruby-version`) and Docker (Docker Desktop or Colima).

```sh
cp .env.example .env          # local DB settings (git-ignored)
docker compose up -d db       # PostgreSQL 17 on localhost:5434
bin/setup                     # bundle install + create/migrate databases
bin/dev                       # http://localhost:3000
```

Run tests: `bin/rails test`

## Production (Railway)

On the **web service** → Variables, set:

- `DATABASE_URL` = `${{Postgres.DATABASE_URL}}`
- `RAILS_MASTER_KEY` = contents of `config/master.key`

`bin/rails db:prepare` runs on boot and creates the main database plus
`<db>_cache`, `<db>_queue` and `<db>_cable` for Solid Cache/Queue/Cable.
