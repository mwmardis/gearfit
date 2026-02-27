import { describe, it, expect } from "vitest";
import { validateCustomEquipmentInput } from "@/lib/validators/equipment";

describe("validateCustomEquipmentInput", () => {
  it("rejects empty name", () => {
    const result = validateCustomEquipmentInput("", "free_weights");
    expect(result).toEqual({ valid: false, error: "Equipment name is required" });
  });

  it("rejects name longer than 100 characters", () => {
    const result = validateCustomEquipmentInput("a".repeat(101), "free_weights");
    expect(result).toEqual({ valid: false, error: "Equipment name must be 100 characters or less" });
  });

  it("rejects invalid category", () => {
    const result = validateCustomEquipmentInput("TRX Bands", "invalid_cat");
    expect(result).toEqual({ valid: false, error: "Invalid equipment category" });
  });

  it("accepts valid input", () => {
    const result = validateCustomEquipmentInput("TRX Bands", "accessories");
    expect(result).toEqual({ valid: true });
  });
});
