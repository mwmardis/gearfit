import NextAuth from "next-auth";
import Credentials from "next-auth/providers/credentials";
import { DrizzleAdapter } from "@auth/drizzle-adapter";
import { db } from "@/lib/db";
import { users, accounts, sessions, verificationTokens, profiles } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import bcrypt from "bcryptjs";

export const { handlers, signIn, signOut, auth } = NextAuth({
  adapter: DrizzleAdapter(db, {
    usersTable: users,
    // @ts-expect-error - DrizzleAdapter types expect snake_case JS properties but our schema uses camelCase. Runtime is correct.
    accountsTable: accounts,
    // @ts-expect-error - same as above
    sessionsTable: sessions,
    verificationTokensTable: verificationTokens,
  }),
  session: { strategy: "jwt" },
  pages: {
    signIn: "/login",
  },
  providers: [
    Credentials({
      credentials: {
        email: {},
        password: {},
      },
      async authorize(credentials) {
        const email = credentials.email as string;
        const password = credentials.password as string;

        const [user] = await db
          .select()
          .from(users)
          .where(eq(users.email, email))
          .limit(1);

        if (!user?.passwordHash) return null;

        const valid = await bcrypt.compare(password, user.passwordHash);
        if (!valid) return null;

        return {
          id: user.id,
          email: user.email,
          name: user.name,
          profileId: user.profileId,
        };
      },
    }),
  ],
  callbacks: {
    authorized({ auth, request: { nextUrl } }) {
      const isLoggedIn = !!auth?.user;
      const publicPaths = ["/login", "/signup", "/share"];
      const isPublicPath = publicPaths.some((path) =>
        nextUrl.pathname.startsWith(path)
      );

      if (!isLoggedIn && !isPublicPath) {
        return false; // Redirects to signIn page
      }
      return true;
    },
    async jwt({ token, user }) {
      if (user) {
        token.profileId = (user as { profileId?: string }).profileId;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.sub!;
        (session.user as { profileId?: string }).profileId = token.profileId as string;
      }
      return session;
    },
  },
});
