"use client";

import { useTransition } from "react";
import {
  setActiveProfile,
  deleteEquipmentProfile,
} from "@/lib/actions/equipment";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Check, Trash2 } from "lucide-react";

interface EquipmentProfileCardProps {
  profile: {
    id: string;
    name: string;
    isActive: boolean;
    equipmentProfileItems: {
      equipmentId: string;
      equipment: { id: string; name: string; category: string | null };
    }[];
  };
}

export function EquipmentProfileCard({ profile }: EquipmentProfileCardProps) {
  const [isPending, startTransition] = useTransition();

  const equipmentNames = profile.equipmentProfileItems
    .map((item) => item.equipment?.name)
    .filter(Boolean);

  return (
    <Card className={profile.isActive ? "border-primary" : ""}>
      <CardHeader className="pb-2">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg">{profile.name}</CardTitle>
          {profile.isActive && <Badge variant="default">Active</Badge>}
        </div>
        <CardDescription>
          {equipmentNames.length} piece{equipmentNames.length !== 1 ? "s" : ""}{" "}
          of equipment
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="mb-4 flex flex-wrap gap-1">
          {equipmentNames.map((name) => (
            <Badge key={name} variant="secondary" className="text-xs">
              {name}
            </Badge>
          ))}
        </div>
        <div className="flex gap-2">
          {!profile.isActive && (
            <Button
              size="sm"
              variant="outline"
              disabled={isPending}
              onClick={() =>
                startTransition(() => setActiveProfile(profile.id))
              }
            >
              <Check className="mr-1 h-3 w-3" />
              Set Active
            </Button>
          )}
          <Button
            size="sm"
            variant="ghost"
            className="text-destructive hover:text-destructive"
            disabled={isPending}
            onClick={() =>
              startTransition(() => deleteEquipmentProfile(profile.id))
            }
          >
            <Trash2 className="mr-1 h-3 w-3" />
            Delete
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
