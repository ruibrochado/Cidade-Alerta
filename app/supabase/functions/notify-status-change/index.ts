// Supabase Edge Function: notify-status-change
// Deploy path: supabase/functions/notify-status-change/index.ts
//
// Required environment variables (set via `supabase secrets set` or the dashboard):
//   SUPABASE_URL              — injected automatically
//   SUPABASE_SERVICE_ROLE_KEY — injected automatically
//   FCM_SERVICE_ACCOUNT       — full Service Account JSON as a single-line string
//   FCM_PROJECT_ID            — your Firebase project ID (e.g. "cidade-alerta-xxxxx")

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { GoogleAuth } from "npm:google-auth-library@9";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// --- Status label helpers ---------------------------------------------------

const STATUS_LABELS: Record<string, string> = {
  submitted: "Submetida",
  in_progress: "Em resolução",
  resolved: "Resolvida",
  archived: "Arquivada",
};

function statusLabel(status: string): string {
  return STATUS_LABELS[status] ?? status;
}

// --- FCM OAuth2 token -------------------------------------------------------

async function getFcmAccessToken(): Promise<string> {
  const serviceAccountJson = Deno.env.get("FCM_SERVICE_ACCOUNT");

  if (!serviceAccountJson) {
    throw new Error("FCM_SERVICE_ACCOUNT env var is not set.");
  }

  const serviceAccount = JSON.parse(serviceAccountJson);

  const auth = new GoogleAuth({
    credentials: serviceAccount,
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });

  const client = await auth.getClient();
  const tokenResponse = await client.getAccessToken();

  if (!tokenResponse.token) {
    throw new Error("Failed to obtain FCM access token.");
  }

  return tokenResponse.token;
}

// --- FCM send ----------------------------------------------------------------

async function sendPushNotification(
  fcmToken: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<void> {
  const projectId = Deno.env.get("FCM_PROJECT_ID");

  if (!projectId) {
    throw new Error("FCM_PROJECT_ID env var is not set.");
  }

  const accessToken = await getFcmAccessToken();

  const fcmUrl =
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

  const payload = {
    message: {
      token: fcmToken,
      notification: { title, body },
      data,
      android: {
        priority: "high",
      },
      apns: {
        headers: { "apns-priority": "10" },
      },
    },
  };

  const response = await fetch(fcmUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`FCM request failed (${response.status}): ${errorText}`);
  }
}

// --- Main handler -----------------------------------------------------------

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed" }),
        { status: 405, headers: corsHeaders },
      );
    }

    const { issue_id, new_status } = await req.json();

    if (!issue_id || !new_status) {
      return new Response(
        JSON.stringify({ error: "Missing issue_id or new_status" }),
        { status: 400, headers: corsHeaders },
      );
    }

    // 1a. Fetch the issue
    // Note: issues.user_id → auth.users (not profiles), so no direct FK join
    const { data: issue, error: issueError } = await supabase
      .from("issues")
      .select("id, title, user_id")
      .eq("id", issue_id)
      .single();

    if (issueError || !issue) {
      return new Response(
        JSON.stringify({ error: "Issue not found" }),
        { status: 404, headers: corsHeaders },
      );
    }

    const ownerId: string = issue.user_id;
    const issueTitle: string = issue.title ?? "Denúncia";

    // 1b. Fetch the owner's FCM token from profiles (separate query)
    const { data: profile } = await supabase
      .from("profiles")
      .select("fcm_token")
      .eq("id", ownerId)
      .maybeSingle();

    const fcmToken: string | null = profile?.fcm_token ?? null;

    // 2. Insert row in `notifications` table
    const { error: notifError } = await supabase
      .from("notifications")
      .insert({
        user_id: ownerId,
        issue_id,
        issue_title: issueTitle,
        new_status,
        is_read: false,
      });

    if (notifError) {
      // Non-fatal: log and continue — we still attempt the push
      console.error("Failed to insert notification row:", notifError.message);
    }

    // 3. Send push notification (only if the user has a registered token)
    if (fcmToken) {
      const label = statusLabel(new_status);
      const title = "Atualização da sua denúncia";
      const body = `"${issueTitle}" foi marcada como: ${label}`;

      await sendPushNotification(fcmToken, title, body, {
        issue_id,
        new_status,
        type: "status_change",
      });
    } else {
      console.log(
        `User ${ownerId} has no FCM token — skipping push notification.`,
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        push_sent: !!fcmToken,
      }),
      { status: 200, headers: corsHeaders },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      { status: 500, headers: corsHeaders },
    );
  }
});