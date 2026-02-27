export const VALID_CATEGORIES = [
  "free_weights",
  "benches",
  "racks",
  "machines",
  "bodyweight",
  "accessories",
] as const;

export type EquipmentCategory = (typeof VALID_CATEGORIES)[number];

export function validateCustomEquipmentInput(
  name: string,
  category: string
): { valid: true } | { valid: false; error: string } {
  if (!name || name.trim().length === 0) {
    return { valid: false, error: "Equipment name is required" };
  }
  if (name.length > 100) {
    return { valid: false, error: "Equipment name must be 100 characters or less" };
  }
  if (!VALID_CATEGORIES.includes(category as EquipmentCategory)) {
    return { valid: false, error: "Invalid equipment category" };
  }
  return { valid: true };
}
