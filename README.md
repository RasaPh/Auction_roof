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

### File uploads (Active Storage)

The container disk is wiped on every deploy, so uploaded photos and documents
must not be stored on it. Pick one:

**Option A: S3-compatible bucket (recommended, e.g. Cloudflare R2)**

- `ACTIVE_STORAGE_SERVICE` = `s3`
- `S3_BUCKET`, `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY`
- `S3_REGION` = `auto` for R2 (or the AWS region, e.g. `ap-southeast-1`)
- `S3_ENDPOINT` = `https://<account_id>.r2.cloudflarestorage.com` for R2 (leave unset for AWS)

**Option B: Railway Volume**

Attach a volume to the web service mounted at `/rails/storage` and leave
`ACTIVE_STORAGE_SERVICE` unset (defaults to `local`). Only works with a single replica.
