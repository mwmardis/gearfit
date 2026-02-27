"use client";

import { useState, useTransition } from "react";
import {
  createEquipmentProfile,
  createCustomEquipment,
} from "@/lib/actions/equipment";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import type { Database } from "@/lib/database.types";

type Equipment = Database["public"]["Tables"]["equipment"]["Row"];

interface EquipmentProfileFormProps {
  equipment: Equipment[];
  onClose: () => void;
}

const categoryLabels: Record<string, string> = {
  free_weights: "Free Weights",
  benches: "Benches",
  racks: "Racks",
  machines: "Machines",
  bodyweight: "Bodyweight",
  accessories: "Accessories",
};

export function EquipmentProfileForm({
  equipment,
  onClose,
}: EquipmentProfileFormProps) {
  const [isPending, startTransition] = useTransition();
  const [customName, setCustomName] = useState("");
  const [customCategory, setCustomCategory] = useState("accessories");
  const [newEquipmentIds, setNewEquipmentIds] = useState<string[]>([]);

  const grouped = equipment.reduce(
    (acc, item) => {
      const cat = item.category ?? "other";
      if (!acc[cat]) acc[cat] = [];
      acc[cat].push(item);
      return acc;
    },
    {} as Record<string, Equipment[]>
  );

  async function handleAddCustom() {
    const formData = new FormData();
    formData.set("name", customName);
    formData.set("category", customCategory);
    startTransition(async () => {
      const newEquipment = await createCustomEquipment(formData);
      setNewEquipmentIds((prev) => [...prev, newEquipment.id]);
      setCustomName("");
    });
  }

  function handleSubmit(formData: FormData) {
    startTransition(async () => {
      await createEquipmentProfile(formData);
      onClose();
    });
  }

  return (
    <form action={handleSubmit} className="space-y-6">
      <div className="space-y-2">
        <Label htmlFor="name">Profile Name</Label>
        <Input
          id="name"
          name="name"
          placeholder='e.g. "Home Gym" or "Commercial Gym"'
          required
        />
      </div>
      <div className="space-y-4">
        <Label>Available Equipment</Label>
        <div className="space-y-2 border-b pb-4 mb-4">
          <label className="text-sm font-medium">Add Custom Equipment</label>
          <div className="flex gap-2">
            <Input
              placeholder="e.g. TRX Bands"
              value={customName}
              onChange={(e) => setCustomName(e.target.value)}
              className="flex-1"
            />
            <select
              value={customCategory}
              onChange={(e) => setCustomCategory(e.target.value)}
              className="rounded-md border px-2 text-sm"
            >
              {Object.entries(categoryLabels).map(([key, label]) => (
                <option key={key} value={key}>
                  {label}
                </option>
              ))}
            </select>
            <Button
              type="button"
              size="sm"
              onClick={handleAddCustom}
              disabled={!customName.trim() || isPending}
            >
              Add
            </Button>
          </div>
        </div>
        {newEquipmentIds.map((id) => (
          <input key={id} type="hidden" name="equipment" value={id} />
        ))}
        {Object.entries(grouped).map(([category, items]) => (
          <div key={category}>
            <h4 className="mb-2 text-sm font-medium text-muted-foreground">
              {categoryLabels[category] ?? category}
            </h4>
            <div className="grid grid-cols-2 gap-2">
              {items.map((item) => (
                <label
                  key={item.id}
                  className="flex items-center gap-2 text-sm"
                >
                  <Checkbox name="equipment" value={item.id} />
                  {item.name}
                </label>
              ))}
            </div>
          </div>
        ))}
      </div>
      <div className="flex gap-2 justify-end">
        <Button type="button" variant="outline" onClick={onClose}>
          Cancel
        </Button>
        <Button type="submit" disabled={isPending}>
          {isPending ? "Creating..." : "Create Profile"}
        </Button>
      </div>
    </form>
  );
}
