// scripts/migrate-users.ts (one-time script)
// Run with: npx tsx scripts/migrate-users.ts
import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";
import { users, profiles } from "../src/lib/db/schema";
import { eq } from "drizzle-orm";

const sql = neon(process.env.DATABASE_URL!);
const db = drizzle(sql);

// Supabase exports users as JSON via their management API
// Get this from: supabase auth admin listUsers() or dashboard export
const supabaseUsers = [
  // Paste exported users here, format:
  // { id: "uuid", email: "...", encrypted_password: "$2a$...", raw_user_meta_data: { display_name: "..." } }
];

async function migrate() {
  for (const su of supabaseUsers) {
    // The profile already exists (migrated via pg_dump)
    // Just create the Auth.js user linked to it
    await db.insert(users).values({
      email: su.email,
      name: su.raw_user_meta_data?.display_name ?? null,
      passwordHash: su.encrypted_password,
      profileId: su.id, // Supabase user ID = profile ID (profiles.id references auth.users.id)
    });

    console.log(`Migrated: ${su.email}`);
  }
}

migrate().catch(console.error);
