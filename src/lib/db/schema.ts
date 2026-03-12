// src/lib/db/schema.ts
import {
  pgTable,
  uuid,
  text,
  boolean,
  integer,
  numeric,
  date,
  timestamp,
  unique,
  check,
} from "drizzle-orm/pg-core";
import { relations, sql } from "drizzle-orm";

// ── profiles ──────────────────────────────────────────────
export const profiles = pgTable("profiles", {
  id: uuid("id").primaryKey(),
  displayName: text("display_name"),
  avatarUrl: text("avatar_url"),
  preferredUnits: text("preferred_units").notNull().default("lbs"),
  trainingGoal: text("training_goal").notNull().default("hypertrophy"),
  overloadSessionsThreshold: integer("overload_sessions_threshold").notNull().default(3),
  overloadIncrementLbs: numeric("overload_increment_lbs").notNull().default("5"),
  overloadIncrementKg: numeric("overload_increment_kg").notNull().default("2.5"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── equipment ─────────────────────────────────────────────
export const equipment = pgTable("equipment", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name").notNull(),
  category: text("category"),
  icon: text("icon"),
  isCustom: boolean("is_custom").notNull().default(false),
  createdBy: uuid("created_by").references(() => profiles.id, { onDelete: "cascade" }),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── muscles ───────────────────────────────────────────────
export const muscles = pgTable("muscles", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name").notNull().unique(),
  muscleGroup: text("muscle_group").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── equipment_profiles ────────────────────────────────────
export const equipmentProfiles = pgTable("equipment_profiles", {
  id: uuid("id").primaryKey().defaultRandom(),
  userId: uuid("user_id").notNull().references(() => profiles.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  isActive: boolean("is_active").notNull().default(false),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── equipment_profile_items ───────────────────────────────
export const equipmentProfileItems = pgTable(
  "equipment_profile_items",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    equipmentProfileId: uuid("equipment_profile_id")
      .notNull()
      .references(() => equipmentProfiles.id, { onDelete: "cascade" }),
    equipmentId: uuid("equipment_id")
      .notNull()
      .references(() => equipment.id, { onDelete: "cascade" }),
  },
  (t) => [unique().on(t.equipmentProfileId, t.equipmentId)]
);

// ── exercises ─────────────────────────────────────────────
export const exercises = pgTable("exercises", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name").notNull(),
  description: text("description"),
  instructions: text("instructions"),
  url: text("url"),
  bodyRegion: text("body_region"),
  mechanics: text("mechanics"),
  force: text("force"),
  utility: text("utility"),
  category: text("category"),
  isCustom: boolean("is_custom").notNull().default(false),
  createdBy: uuid("created_by").references(() => profiles.id, { onDelete: "cascade" }),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── exercise_equipment ────────────────────────────────────
export const exerciseEquipment = pgTable(
  "exercise_equipment",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    exerciseId: uuid("exercise_id")
      .notNull()
      .references(() => exercises.id, { onDelete: "cascade" }),
    equipmentId: uuid("equipment_id")
      .notNull()
      .references(() => equipment.id, { onDelete: "cascade" }),
  },
  (t) => [unique().on(t.exerciseId, t.equipmentId)]
);

// ── exercise_muscles ──────────────────────────────────────
export const exerciseMuscles = pgTable(
  "exercise_muscles",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    exerciseId: uuid("exercise_id")
      .notNull()
      .references(() => exercises.id, { onDelete: "cascade" }),
    muscleId: uuid("muscle_id")
      .notNull()
      .references(() => muscles.id, { onDelete: "cascade" }),
    role: text("role").notNull(), // 'primary' | 'secondary'
  },
  (t) => [unique().on(t.exerciseId, t.muscleId)]
);

// ── workout_templates ─────────────────────────────────────
export const workoutTemplates = pgTable("workout_templates", {
  id: uuid("id").primaryKey().defaultRandom(),
  userId: uuid("user_id").notNull().references(() => profiles.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  description: text("description"),
  isShared: boolean("is_shared").notNull().default(false),
  shareToken: uuid("share_token").unique().defaultRandom(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── template_exercises ────────────────────────────────────
export const templateExercises = pgTable("template_exercises", {
  id: uuid("id").primaryKey().defaultRandom(),
  templateId: uuid("template_id")
    .notNull()
    .references(() => workoutTemplates.id, { onDelete: "cascade" }),
  exerciseId: uuid("exercise_id")
    .notNull()
    .references(() => exercises.id, { onDelete: "cascade" }),
  orderIndex: integer("order_index").notNull(),
  targetSets: integer("target_sets").notNull().default(3),
  targetReps: integer("target_reps").notNull().default(10),
  targetWeight: numeric("target_weight"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── workout_sessions ──────────────────────────────────────
export const workoutSessions = pgTable("workout_sessions", {
  id: uuid("id").primaryKey().defaultRandom(),
  userId: uuid("user_id").notNull().references(() => profiles.id, { onDelete: "cascade" }),
  templateId: uuid("template_id").references(() => workoutTemplates.id, { onDelete: "set null" }),
  date: date("date").notNull().defaultNow(),
  durationMinutes: integer("duration_minutes"),
  notes: text("notes"),
  completed: boolean("completed").notNull().default(false),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── session_sets ──────────────────────────────────────────
export const sessionSets = pgTable("session_sets", {
  id: uuid("id").primaryKey().defaultRandom(),
  sessionId: uuid("session_id")
    .notNull()
    .references(() => workoutSessions.id, { onDelete: "cascade" }),
  exerciseId: uuid("exercise_id")
    .notNull()
    .references(() => exercises.id, { onDelete: "cascade" }),
  setNumber: integer("set_number").notNull(),
  weight: numeric("weight").notNull().default("0"),
  reps: integer("reps").notNull().default(0),
  rpe: numeric("rpe"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── saved_ai_suggestions ──────────────────────────────────
export const savedAiSuggestions = pgTable("saved_ai_suggestions", {
  id: uuid("id").primaryKey().defaultRandom(),
  userId: uuid("user_id").notNull().references(() => profiles.id, { onDelete: "cascade" }),
  exerciseName: text("exercise_name").notNull(),
  exerciseId: uuid("exercise_id").references(() => exercises.id, { onDelete: "set null" }),
  primaryMuscles: text("primary_muscles").array().notNull().default(sql`'{}'`),
  secondaryMuscles: text("secondary_muscles").array().notNull().default(sql`'{}'`),
  suggestedSets: integer("suggested_sets").notNull().default(3),
  suggestedReps: integer("suggested_reps").notNull().default(10),
  description: text("description"),
  instructions: text("instructions"),
  workoutType: text("workout_type").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── Auth.js tables ────────────────────────────────────────
// These are required by the Drizzle adapter for Auth.js.
// They are NEW tables, not migrated from Supabase.

export const users = pgTable("authjs_users", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name"),
  email: text("email").unique(),
  emailVerified: timestamp("email_verified", { withTimezone: true }),
  image: text("image"),
  passwordHash: text("password_hash"),
  profileId: uuid("profile_id").references(() => profiles.id, { onDelete: "cascade" }),
});

export const accounts = pgTable("authjs_accounts", {
  id: uuid("id").primaryKey().defaultRandom(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  type: text("type").notNull(),
  provider: text("provider").notNull(),
  providerAccountId: text("provider_account_id").notNull(),
  refreshToken: text("refresh_token"),
  accessToken: text("access_token"),
  expiresAt: integer("expires_at"),
  tokenType: text("token_type"),
  scope: text("scope"),
  idToken: text("id_token"),
  sessionState: text("session_state"),
});

export const sessions = pgTable("authjs_sessions", {
  id: uuid("id").primaryKey().defaultRandom(),
  sessionToken: text("session_token").notNull().unique(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  expires: timestamp("expires", { withTimezone: true }).notNull(),
});

export const verificationTokens = pgTable("authjs_verification_tokens", {
  identifier: text("identifier").notNull(),
  token: text("token").notNull().unique(),
  expires: timestamp("expires", { withTimezone: true }).notNull(),
});

// ── Relations ─────────────────────────────────────────────

export const equipmentProfilesRelations = relations(equipmentProfiles, ({ many }) => ({
  equipmentProfileItems: many(equipmentProfileItems),
}));

export const equipmentProfileItemsRelations = relations(equipmentProfileItems, ({ one }) => ({
  equipmentProfile: one(equipmentProfiles, {
    fields: [equipmentProfileItems.equipmentProfileId],
    references: [equipmentProfiles.id],
  }),
  equipment: one(equipment, {
    fields: [equipmentProfileItems.equipmentId],
    references: [equipment.id],
  }),
}));

export const exercisesRelations = relations(exercises, ({ many }) => ({
  exerciseEquipment: many(exerciseEquipment),
  exerciseMuscles: many(exerciseMuscles),
}));

export const exerciseEquipmentRelations = relations(exerciseEquipment, ({ one }) => ({
  exercise: one(exercises, {
    fields: [exerciseEquipment.exerciseId],
    references: [exercises.id],
  }),
  equipment: one(equipment, {
    fields: [exerciseEquipment.equipmentId],
    references: [equipment.id],
  }),
}));

export const exerciseMusclesRelations = relations(exerciseMuscles, ({ one }) => ({
  exercise: one(exercises, {
    fields: [exerciseMuscles.exerciseId],
    references: [exercises.id],
  }),
  muscle: one(muscles, {
    fields: [exerciseMuscles.muscleId],
    references: [muscles.id],
  }),
}));

export const workoutTemplatesRelations = relations(workoutTemplates, ({ many }) => ({
  templateExercises: many(templateExercises),
}));

export const templateExercisesRelations = relations(templateExercises, ({ one }) => ({
  template: one(workoutTemplates, {
    fields: [templateExercises.templateId],
    references: [workoutTemplates.id],
  }),
  exercise: one(exercises, {
    fields: [templateExercises.exerciseId],
    references: [exercises.id],
  }),
}));

export const workoutSessionsRelations = relations(workoutSessions, ({ one, many }) => ({
  template: one(workoutTemplates, {
    fields: [workoutSessions.templateId],
    references: [workoutTemplates.id],
  }),
  sessionSets: many(sessionSets),
}));

export const sessionSetsRelations = relations(sessionSets, ({ one }) => ({
  session: one(workoutSessions, {
    fields: [sessionSets.sessionId],
    references: [workoutSessions.id],
  }),
  exercise: one(exercises, {
    fields: [sessionSets.exerciseId],
    references: [exercises.id],
  }),
}));

export const savedAiSuggestionsRelations = relations(savedAiSuggestions, ({ one }) => ({
  exercise: one(exercises, {
    fields: [savedAiSuggestions.exerciseId],
    references: [exercises.id],
  }),
}));
