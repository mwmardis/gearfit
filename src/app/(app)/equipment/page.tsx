import { getEquipmentList, getEquipmentProfiles } from "@/lib/actions/equipment";
import { EquipmentPageClient } from "./client";

export default async function EquipmentPage() {
  const [equipment, profiles] = await Promise.all([
    getEquipmentList(),
    getEquipmentProfiles(),
  ]);

  return <EquipmentPageClient equipment={equipment} profiles={profiles} />;
}
