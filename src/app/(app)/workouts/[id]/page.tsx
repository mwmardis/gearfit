import { getTemplate } from "@/lib/actions/templates";
import { getExercises } from "@/lib/actions/exercises";
import { getEquipmentProfiles } from "@/lib/actions/equipment";
import { TemplateDetailClient } from "./client";
import { notFound } from "next/navigation";

interface TemplateDetailPageProps {
  params: Promise<{ id: string }>;
}

export default async function TemplateDetailPage({
  params,
}: TemplateDetailPageProps) {
  const { id } = await params;

  let template;
  try {
    template = await getTemplate(id);
  } catch {
    notFound();
  }

  const allExercises = await getExercises();

  const profiles = await getEquipmentProfiles();
  const activeProfile = profiles.find((p: { isActive: boolean }) => p.isActive);
  const equipmentNames = activeProfile
    ? activeProfile.equipmentProfileItems.map(
        (item: { equipment: { name: string } }) => item.equipment.name
      )
    : [];

  return (
    <TemplateDetailClient
      template={template}
      allExercises={allExercises}
      equipmentProfileName={activeProfile?.name ?? null}
      equipmentNames={equipmentNames}
    />
  );
}
