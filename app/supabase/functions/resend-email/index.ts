import { serve } from "https://deno.land/std@0.190.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");

serve(async (req: Request) => {
  try {
    if (!RESEND_API_KEY) {
      return new Response(
        JSON.stringify({ error: "Missing RESEND_API_KEY" }),
        { status: 500 }
      );
    }

    const { to, subject, html } = await req.json();

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "Cidade Alerta <onboarding@resend.dev>",
        to,
        subject,
        html,
      }),
    });

    const data = await res.json();

    return new Response(JSON.stringify(data), {
      status: res.status,
      headers: { "Content-Type": "application/json" },
    });

  } catch (error) {
    return new Response(
      JSON.stringify({ error: String(error) }),
      { status: 500 }
    );
  }
});
