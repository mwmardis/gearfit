import { getWeeklyMuscleCoverage } from "@/lib/actions/history";
import { MuscleCoverage } from "@/components/dashboard/muscle-coverage";

export default async function DashboardPage() {
  const coverage = await getWeeklyMuscleCoverage();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <p className="text-muted-foreground">Welcome to GearFit</p>
      </div>

      <MuscleCoverage coverage={coverage} />
    </div>
  );
}
