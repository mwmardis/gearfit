// middleware.ts (root)
export { auth as middleware } from "@/lib/auth";

export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - api/auth (Auth.js routes)
     * - _next/static, _next/image (Next.js internals)
     * - favicon.ico, public files
     * - login, signup, share (public pages)
     */
    "/((?!api/auth|_next/static|_next/image|favicon\\.ico|login|signup|share|.*\\.svg$).*)",
  ],
};
