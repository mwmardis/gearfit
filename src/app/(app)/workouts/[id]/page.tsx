import { getTemplate } from "@/lib/actions/templates";
import { getExercises } from "@/lib/actions/exercises";
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

  return (
    <TemplateDetailClient template={template} allExercises={allExercises} />
  );
}
