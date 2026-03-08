import { getExercises } from "@/lib/actions/exercises";
import { getEquipmentProfiles } from "@/lib/actions/equipment";
import { ExercisesPageClient } from "./client";

export default async function ExercisesPage() {
  const exercises = await getExercises();
  const profiles = await getEquipmentProfiles();
  const activeProfile = profiles.find((p: { isActive: boolean }) => p.isActive);
  const equipmentNames = activeProfile
    ? activeProfile.equipmentProfileItems.map(
        (item: { equipment: { name: string } }) => item.equipment.name
      )
    : [];

  return (
    <ExercisesPageClient
      initialExercises={exercises}
      equipmentProfileName={activeProfile?.name ?? null}
      equipmentNames={equipmentNames}
    />
  );
}
