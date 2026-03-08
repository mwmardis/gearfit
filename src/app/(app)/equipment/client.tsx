"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { EquipmentProfileForm } from "@/components/equipment/equipment-profile-form";
import { EquipmentProfileCard } from "@/components/equipment/equipment-profile-card";
import { Plus } from "lucide-react";
import { type InferSelectModel } from "drizzle-orm";
import { equipment as equipmentTable } from "@/lib/db/schema";

type Equipment = InferSelectModel<typeof equipmentTable>;

interface EquipmentPageClientProps {
  equipment: Equipment[];
  profiles: {
    id: string;
    name: string;
    isActive: boolean;
    userId: string;
    createdAt: Date;
    updatedAt: Date;
    equipmentProfileItems: {
      equipmentId: string;
      equipment: { id: string; name: string; category: string | null };
    }[];
  }[];
}

export function EquipmentPageClient({
  equipment,
  profiles,
}: EquipmentPageClientProps) {
  const [open, setOpen] = useState(false);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Equipment</h1>
          <p className="text-muted-foreground">
            Manage your equipment profiles
          </p>
        </div>
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild>
            <Button>
              <Plus className="mr-2 h-4 w-4" />
              New Profile
            </Button>
          </DialogTrigger>
          <DialogContent className="max-h-[80vh] overflow-y-auto sm:max-w-lg">
            <DialogHeader>
              <DialogTitle>Create Equipment Profile</DialogTitle>
            </DialogHeader>
            <EquipmentProfileForm
              equipment={equipment}
              onClose={() => setOpen(false)}
            />
          </DialogContent>
        </Dialog>
      </div>

      {profiles.length === 0 ? (
        <p className="text-sm text-muted-foreground">
          No equipment profiles yet. Create one to filter exercises by your
          available gear.
        </p>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2">
          {profiles.map((profile) => (
            <EquipmentProfileCard key={profile.id} profile={profile} />
          ))}
        </div>
      )}
    </div>
  );
}
