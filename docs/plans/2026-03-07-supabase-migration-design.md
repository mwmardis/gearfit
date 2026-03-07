# Supabase Migration Design

**Date:** 2026-03-07
**Status:** Approved

## Overview

Migrate 3 apps (including GearFit) off Supabase to eliminate per-project costs. Replace Supabase services with free-tier alternatives that pair with Vercel.

## Target Stack

| Concern | Current (Supabase) | Replacement | Free Tier |
|---------|-------------------|-------------|-----------|
| Database | Supabase Postgres | **Neon** (Postgres) | 0.5 GB, 190 compute hrs/mo, multiple DBs per project |
| Auth | Supabase Auth | **Auth.js v5** (NextAuth) | Open source, runs in Next.js |
| Storage | Supabase Storage | **Vercel Blob** | 250 MB |
| Edge Functions | Supabase Edge Functions | **Next.js API routes** | Included with Vercel |
| Email (magic links) | Supabase built-in | **Resend** | 3,000 emails/mo |

## Database: Supabase Postgres to Neon

### Migration Strategy

1. Export schemas and data via `pg_dump` from Supabase
2. Import via `pg_restore` into Neon
3. All 3 apps share one Neon project with separate databases (stays within free tier)

### Code Changes

- Replace `@supabase/supabase-js` database calls with **Drizzle ORM** + `@neondatabase/serverless`
- Drizzle chosen for: lightweight, SQL-like syntax, first-class Neon support
- Define Drizzle schemas matching existing Supabase tables
- RLS policies are dropped; authorization checks move into server actions (add `userId` guard at the top of each action)

### Why Drizzle over Prisma

- Lighter bundle, no engine binary
- SQL-like API (closer to current raw Supabase queries)
- Native Neon serverless driver support
- Better edge runtime compatibility

## Auth: Supabase Auth to Auth.js v5

### Providers

- **Credentials provider:** email/password login (replaces Supabase email/password)
- **Email provider:** magic links via Resend (replaces Supabase magic links)

### Session Strategy

- JWT stored in HTTP-only cookies (same approach as Supabase)
- Auth.js Next.js middleware replaces `src/lib/supabase/middleware.ts` for route protection

### Database Tables

Auth.js requires 4 tables (auto-generated via Drizzle adapter):
- `users` — core user records
- `accounts` — linked auth providers
- `sessions` — active sessions (optional with JWT strategy)
- `verification_tokens` — magic link / email verification tokens

### User Migration

- Export users from Supabase Auth dashboard or API
- Supabase uses bcrypt for password hashing; Auth.js Credentials provider supports bcrypt
- Existing passwords carry over without re-hashing
- Users do not need to reset passwords

### Key Code Changes

| Current (Supabase) | Replacement (Auth.js) |
|--------------------|-----------------------|
| `createClient()` / `createServerClient()` for auth | `auth()` from Auth.js |
| `supabase.auth.getUser()` | `auth()` returns session with user |
| `signUp`, `signIn`, `signOut` actions | Auth.js `signIn()` / `signOut()` |
| Supabase middleware | Auth.js `authorized` callback in middleware |

## Storage: Supabase Storage to Vercel Blob

### API Mapping

| Current (Supabase) | Replacement (Vercel Blob) |
|--------------------|--------------------------|
| `supabase.storage.from('bucket').upload(path, file)` | `put(filename, file, { access: 'public' })` |
| `supabase.storage.from('bucket').getPublicUrl(path)` | URL returned directly from `put()`, store in DB |
| `supabase.storage.from('bucket').remove([path])` | `del(url)` |

### Migration

1. Download all files from Supabase Storage buckets
2. Re-upload to Vercel Blob
3. Update URL references in the database

### Limits

- 250 MB free tier. If exceeded, swap to Cloudflare R2 (10 GB free, zero egress).

## Edge Functions: Supabase Edge Functions to Next.js API Routes

No new service needed. Supabase Edge Functions become Next.js API routes (`app/api/*/route.ts`) or server actions. These run on Vercel's serverless/edge runtime for free.

## Migration Order

GearFit is the most complex app and serves as the migration template. The pattern established here applies to the other 2 apps.

### Per-App Migration Sequence

1. **Set up Neon database** — create DB, import schema and data
2. **Install Drizzle + define schemas** — replace Supabase client with Drizzle
3. **Migrate auth to Auth.js** — set up providers, middleware, migrate users
4. **Migrate storage to Vercel Blob** — move files, update references
5. **Replace Edge Functions** — convert to Next.js API routes
6. **Add authorization guards** — replace RLS with server action checks
7. **Test end-to-end** — verify all flows work
8. **Cut over** — point production to Neon, remove Supabase project

## Environment Variables

### Remove
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`

### Add
- `DATABASE_URL` (Neon connection string)
- `AUTH_SECRET` (Auth.js secret)
- `AUTH_RESEND_KEY` (Resend API key for magic links)
- `BLOB_READ_WRITE_TOKEN` (Vercel Blob token)
