import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// Cliente Supabase com SERVICE_ROLE_KEY (bypass RLS) - uso interno em jobs
export function createServiceClient() {
  const url  = Deno.env.get("SUPABASE_URL")!;
  const key  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  if (!url || !key) {
    throw new Error("SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY ausentes.");
  }
  return createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

// Helper de log padronizado para audit_log
export async function logAudit(
  client: ReturnType<typeof createServiceClient>,
  familyId: string,
  action: string,
  details: Record<string, unknown>,
) {
  await client.from("audit_log").insert({
    family_id: familyId,
    action,
    details,
    source: "edge_function",
  });
}
