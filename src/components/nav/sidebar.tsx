"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { handleSignOut } from "@/lib/actions/auth";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { ThemeToggle } from "@/components/theme-toggle";
import {
  LayoutDashboard,
  Dumbbell,
  BookOpen,
  History,
  Settings,
  User,
  LogOut,
  Flame,
} from "lucide-react";
import type { User as SupabaseUser } from "@supabase/supabase-js";
import type { Database } from "@/lib/database.types";

type Profile = Database["public"]["Tables"]["profiles"]["Row"];

const navItems = [
  { href: "/", label: "Dashboard", icon: LayoutDashboard },
  { href: "/workouts", label: "Workouts", icon: Dumbbell },
  { href: "/exercises", label: "Exercises", icon: BookOpen },
  { href: "/history", label: "History", icon: History },
  { href: "/equipment", label: "Equipment", icon: Settings },
  { href: "/profile", label: "Profile", icon: User },
];

interface SidebarProps {
  user: SupabaseUser;
  profile: Profile | null;
}

export function Sidebar({ user, profile }: SidebarProps) {
  const pathname = usePathname();
  const initials = (profile?.display_name ?? user.email ?? "U")
    .slice(0, 2)
    .toUpperCase();

  return (
    <aside className="hidden md:flex w-60 flex-col border-r border-border/50 bg-sidebar p-5">
      {/* Brand */}
      <div className="mb-8 flex items-center gap-2.5 px-2">
        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-energy">
          <Flame className="h-4 w-4 text-white" />
        </div>
        <h1 className="font-display text-lg font-bold tracking-tight">
          GearFit
        </h1>
      </div>

      {/* Navigation */}
      <nav className="flex-1 space-y-1">
        {navItems.map(({ href, label, icon: Icon }) => {
          const isActive = pathname === href;
          return (
            <Link
              key={href}
              href={href}
              className={`group relative flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all duration-200 ${
                isActive
                  ? "nav-active bg-primary/10 text-primary"
                  : "text-muted-foreground hover:bg-accent hover:text-foreground"
              }`}
            >
              <Icon
                className={`h-[18px] w-[18px] transition-transform duration-200 group-hover:scale-110 ${
                  isActive ? "text-primary" : ""
                }`}
              />
              {label}
            </Link>
          );
        })}
      </nav>

      {/* User section */}
      <div className="mt-4 rounded-xl border border-border/50 bg-muted/30 p-3">
        <div className="flex items-center gap-3">
          <Avatar className="h-9 w-9 ring-2 ring-primary/20">
            <AvatarFallback className="bg-gradient-energy text-xs font-semibold text-white">
              {initials}
            </AvatarFallback>
          </Avatar>
          <div className="flex-1 min-w-0">
            <p className="truncate text-sm font-semibold">
              {profile?.display_name ?? user.email}
            </p>
            <p className="truncate text-xs text-muted-foreground">
              {user.email}
            </p>
          </div>
        </div>
        <div className="mt-3 flex items-center gap-1">
          <ThemeToggle />
          <form action={handleSignOut} className="flex-1">
            <Button
              variant="ghost"
              size="sm"
              type="submit"
              className="w-full justify-start gap-2 text-xs text-muted-foreground hover:text-destructive"
            >
              <LogOut className="h-3.5 w-3.5" />
              Sign out
            </Button>
          </form>
        </div>
      </div>
    </aside>
  );
}
