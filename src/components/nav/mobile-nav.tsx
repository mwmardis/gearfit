"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useTheme } from "next-themes";
import {
  LayoutDashboard,
  Dumbbell,
  BookOpen,
  History,
  Moon,
  Sun,
} from "lucide-react";

const navItems = [
  { href: "/", label: "Home", icon: LayoutDashboard },
  { href: "/workouts", label: "Workouts", icon: Dumbbell },
  { href: "/exercises", label: "Exercises", icon: BookOpen },
  { href: "/history", label: "History", icon: History },
];

export function MobileNav() {
  const pathname = usePathname();
  const { resolvedTheme, setTheme } = useTheme();

  return (
    <nav className="fixed bottom-4 left-4 right-4 z-50 flex items-center rounded-2xl border border-border/50 bg-background/80 shadow-xl backdrop-blur-xl md:hidden">
      {navItems.map(({ href, label, icon: Icon }) => {
        const isActive = pathname === href;
        return (
          <Link
            key={href}
            href={href}
            className={`relative flex flex-1 flex-col items-center gap-1 py-3 text-xs font-medium transition-all duration-200 ${
              isActive
                ? "text-primary"
                : "text-muted-foreground hover:text-foreground"
            }`}
          >
            <div className="relative">
              <Icon
                className={`h-5 w-5 transition-transform duration-200 ${
                  isActive ? "scale-110" : ""
                }`}
              />
              {isActive && (
                <div className="absolute -bottom-1.5 left-1/2 h-1 w-1 -translate-x-1/2 rounded-full bg-primary" />
              )}
            </div>
            {label}
          </Link>
        );
      })}
      <button
        onClick={() => setTheme(resolvedTheme === "dark" ? "light" : "dark")}
        className="flex flex-1 flex-col items-center gap-1 py-3 text-xs font-medium text-muted-foreground transition-colors hover:text-foreground"
      >
        <Sun className="h-5 w-5 dark:hidden" />
        <Moon className="hidden h-5 w-5 dark:block" />
        Theme
      </button>
    </nav>
  );
}
