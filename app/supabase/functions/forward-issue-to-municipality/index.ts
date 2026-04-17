// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { Resend } from "npm:resend";

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

const resend = new Resend(Deno.env.get("RESEND_API_KEY")!);

const TEST_EMAIL = Deno.env.get("TEST_EMAIL")!;
const FROM_EMAIL = Deno.env.get("FROM_EMAIL")!;

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

    const { issue_id } = await req.json();

    if (!issue_id) {
      return new Response(
        JSON.stringify({ error: "Missing issue_id" }),
        { status: 400, headers: corsHeaders },
      );
    }

    const { data: issue, error: issueError } = await supabase
      .from("issues")
      .select("*")
      .eq("id", issue_id)
      .single();

    if (issueError || !issue) {
      return new Response(
        JSON.stringify({ error: "Issue not found" }),
        { status: 404, headers: corsHeaders },
      );
    }

    const hasCoordinates =
      issue.latitude != null && issue.longitude != null;

    const mapLink = hasCoordinates
      ? `https://www.openstreetmap.org/?mlat=${issue.latitude}&mlon=${issue.longitude}#map=18/${issue.latitude}/${issue.longitude}`
      : "N/A";

    const subject = `Nova denúncia registada | ${issue.ticket_number ?? issue.id} | Cidade Alerta`;

    const html = `
      <!DOCTYPE html>
      <html lang="pt">
        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>Nova Denúncia Submetida</title>
        </head>
        <body style="margin:0; padding:0; background-color:#f4f7fb; font-family:Arial, Helvetica, sans-serif; color:#1f2937;">
          <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f4f7fb; padding:32px 16px;">
            <tr>
              <td align="center">
                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:700px; background-color:#ffffff; border-radius:20px; overflow:hidden; box-shadow:0 8px 30px rgba(0,0,0,0.08);">
                  
                  <tr>
                    <td style="background:#CDE5CB; padding:28px 32px; color:#1F2937;">
                      <table role="presentation" width="100%">
                        <tr>
<td align="left" style="vertical-align:middle; padding-right:24px;">
  <div style="font-size:12px; letter-spacing:1px; text-transform:uppercase; opacity:0.9; margin-bottom:8px;">
    Cidade Alerta
  </div>
  <h1 style="margin:0; font-size:28px; line-height:1.2;">
    Nova denúncia registada
  </h1>
  <p style="margin:10px 0 0 0; font-size:15px; line-height:1.5; opacity:0.95;">
    Foi registada uma nova denúncia através da nossa aplicação. Consulte abaixo os respetivos detalhes para avaliação e tratamento da situação reportada.
  </p>
</td>
<td align="right" style="vertical-align:middle; width:96px; padding-left:12px;">
  <img
    src="https://vvylvxymbwktociregtz.supabase.co/storage/v1/object/public/public-images/logo.png"
    alt="App logo"
    style="width:72px; height:72px; object-fit:contain; display:block; margin-left:auto;"
  />
</td>
                        </tr>
                      </table>
                    </td>
                  </tr>

                  <tr>
                    <td style="padding:28px 32px 8px 32px;">
                      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f8fafc; border:1px solid #e5e7eb; border-radius:16px;">
                        <tr>
                          <td style="padding:20px 24px;">
                            <div style="font-size:12px; text-transform:uppercase; letter-spacing:0.8px; color:#6b7280; margin-bottom:8px;">
                              Identificador da ocorrência
                            </div>
                            <div style="font-size:26px; font-weight:700; color:#111827;">
                              ${issue.ticket_number ?? issue.id}
                            </div>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>

                  <tr>
                    <td style="padding:16px 32px;">
                      <h2 style="margin:0 0 16px 0; font-size:18px; color:#111827;">Detalhes da denúncia</h2>
                      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="border-collapse:collapse;">
                        <tr>
                          <td style="padding:12px 0; border-bottom:1px solid #e5e7eb; width:180px; color:#6b7280; font-size:14px;">Categoria</td>
                          <td style="padding:12px 0; border-bottom:1px solid #e5e7eb; color:#111827; font-size:14px; font-weight:600;">${issue.category ?? "N/A"}</td>
                        </tr>
                        <tr>
                          <td style="padding:12px 0; border-bottom:1px solid #e5e7eb; color:#6b7280; font-size:14px;">Título</td>
                          <td style="padding:12px 0; border-bottom:1px solid #e5e7eb; color:#111827; font-size:14px; font-weight:600;">${issue.title ?? "N/A"}</td>
                        </tr>
                        <tr>
                          <td style="padding:12px 0; border-bottom:1px solid #e5e7eb; color:#6b7280; font-size:14px;">Descrição</td>
                          <td style="padding:12px 0; border-bottom:1px solid #e5e7eb; color:#111827; font-size:14px; line-height:1.6;">
                            ${issue.description ?? "N/A"}
                          </td>
                        </tr>
                        <tr>
                          <td style="padding:12px 0; border-bottom:1px solid #e5e7eb; color:#6b7280; font-size:14px;">Morada / Localização</td>
                          <td style="padding:12px 0; border-bottom:1px solid #e5e7eb; color:#111827; font-size:14px; font-weight:600;">
                            ${issue.street ?? "N/A"}
                          </td>
                        </tr>
                        <tr>
                          <td style="padding:12px 0; border-bottom:1px solid #e5e7eb; color:#6b7280; font-size:14px;">Latitude</td>
                          <td style="padding:12px 0; border-bottom:1px solid #e5e7eb; color:#111827; font-size:14px;">
                            ${issue.latitude ?? "N/A"}
                          </td>
                        </tr>
                        <tr>
                          <td style="padding:12px 0; color:#6b7280; font-size:14px;">Longitude</td>
                          <td style="padding:12px 0; color:#111827; font-size:14px;">
                            ${issue.longitude ?? "N/A"}
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>

                  <tr>
                    <td style="padding:8px 32px 24px 32px;">
                      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f9fafb; border:1px solid #e5e7eb; border-radius:16px;">
                        <tr>
                          <td style="padding:20px 24px;">
                            <h3 style="margin:0 0 8px 0; font-size:16px; color:#111827;">Acesso rápido</h3>
                            <p style="margin:0 0 16px 0; font-size:14px; color:#4b5563; line-height:1.6;">
                              Utilize o link abaixo para abrir a localização da ocorrência diretamente no mapa.
                            </p>
                            <a href="${mapLink}" style="display:inline-block; background-color:#16a34a; color:#ffffff; text-decoration:none; padding:12px 20px; border-radius:10px; font-size:14px; font-weight:700;">
                              Ver localização no mapa
                            </a>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>

                  ${
                    issue.photo_url
                      ? `
                  <tr>
                    <td style="padding:0 32px 24px 32px;">
                      <h2 style="margin:0 0 16px 0; font-size:18px; color:#111827;">Imagem anexada</h2>
                      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="border:1px solid #e5e7eb; border-radius:16px; overflow:hidden; background-color:#f9fafb;">
                        <tr>
                          <td style="padding:16px;">
                            <img src="${issue.photo_url}" alt="Imagem da ocorrência" style="display:block; width:100%; max-width:100%; height:auto; border-radius:12px;" />
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                  `
                      : ""
                  }

                  <tr>
                    <td style="padding:0 32px 32px 32px;">
                      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f8fafc; border:1px solid #e5e7eb; border-radius:16px;">
                        <tr>
                          <td style="padding:18px 24px;">
                            <p style="margin:0; font-size:13px; color:#6b7280; line-height:1.7;">
                              Esta mensagem foi gerada automaticamente pela aplicação. 
                              Recomenda-se a validação da ocorrência e o respetivo encaminhamento interno de acordo com os procedimentos do município.
                            </p>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>

                  <tr>
                    <td style="padding:20px 32px; background-color:#111827; color:#d1d5db;">
                      <table role="presentation" width="100%">
                        <tr>
                          <td align="left" style="font-size:12px; line-height:1.7;">
                            <strong style="color:#ffffff;">Cidade Alerta</strong><br/>
                            Melhorar a vida na cidade através da participação dos cidadãos
                          </td>
                          <td align="right" style="font-size:12px; line-height:1.7;">
                            Referência: ${issue.ticket_number ?? issue.id}
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>

                </table>
              </td>
            </tr>
          </table>
        </body>
      </html>
    `;

    const result = await resend.emails.send({
      from: FROM_EMAIL,
      to: [TEST_EMAIL],
      subject,
      html,
    });

    return new Response(
      JSON.stringify({
        success: true,
        sent_to: TEST_EMAIL,
        resend_id: result.data?.id ?? null,
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

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/forward-issue-to-municipality' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
