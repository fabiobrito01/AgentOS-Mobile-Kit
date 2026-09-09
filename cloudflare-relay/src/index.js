import { createMcpHandler } from "agents/mcp/server";
import { McpServer } from "@modelcontextprotocol/server";
import { z } from "zod";

const VERSION = "0.4.0";
const ACTIONS = new Set(["battery", "device", "storage", "network", "status"]);
const TITLES = {
  battery: "Consultar bateria do celular",
  device: "Consultar informações do dispositivo",
  storage: "Consultar armazenamento do celular",
  network: "Consultar rede do celular",
  status: "Executar diagnóstico geral do celular",
};

const json = (data, status = 200) => new Response(JSON.stringify(data, null, 2), {
  status,
  headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" },
});

function bearer(request) {
  const value = request.headers.get("authorization") || "";
  return value.startsWith("Bearer ") ? value.slice(7) : "";
}

function deviceAuthorized(request, env) {
  return Boolean(env.DEVICE_TOKEN) && bearer(request) === env.DEVICE_TOKEN;
}

function pendingKey(deviceId) { return `pending:${deviceId}`; }
function resultKey(id) { return `result:${id}`; }

async function readPending(env, deviceId) {
  const raw = await env.RELAY_KV.get(pendingKey(deviceId));
  return raw ? JSON.parse(raw) : null;
}

async function queueAction(env, action) {
  if (!ACTIONS.has(action)) throw new Error("Ação não permitida.");
  const deviceId = env.DEFAULT_DEVICE_ID || "fabio-phone";
  const existing = await readPending(env, deviceId);
  if (existing) {
    if (existing.action === action) return existing;
    throw new Error(`O celular já possui uma solicitação pendente: ${existing.action}.`);
  }
  const command = {
    id: crypto.randomUUID(),
    device_id: deviceId,
    action,
    created_at: new Date().toISOString(),
  };
  await env.RELAY_KV.put(pendingKey(deviceId), JSON.stringify(command), { expirationTtl: 300 });
  return command;
}

async function readResult(env, id) {
  const raw = await env.RELAY_KV.get(resultKey(id));
  return raw ? JSON.parse(raw) : null;
}

async function waitForResult(env, id, timeoutMs = 50000) {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    const result = await readResult(env, id);
    if (result) return result;
    await new Promise(resolve => setTimeout(resolve, 1500));
  }
  return null;
}

function toolContent(action, requestId, result) {
  if (!result) {
    return `Solicitação ${requestId} enviada ao celular para ${TITLES[action]}. Aguardando confirmação no aparelho. Se necessário, use mobile_result com esse request_id.`;
  }
  if (result.status === "denied") {
    return `A solicitação ${requestId} foi negada no celular. ${result.stderr || ""}`.trim();
  }
  if (result.status === "error" || Number(result.exit_code) !== 0) {
    return `A consulta ${requestId} terminou com erro.\n${result.stderr || result.stdout || "Sem detalhes."}`;
  }
  return result.stdout || "Consulta concluída sem texto de retorno.";
}

function createServer(env) {
  const server = new McpServer({ name: "AgentO Mobile", version: VERSION });

  for (const action of ACTIONS) {
    server.registerTool(
      `mobile_${action}`,
      {
        description: `Use esta ferramenta quando o usuário quiser ${TITLES[action].toLowerCase()}. Ela envia somente uma consulta de leitura pré-definida ao AgentO Mobile e exige confirmação no telefone.`,
        inputSchema: {},
        annotations: {
          readOnlyHint: true,
          destructiveHint: false,
          openWorldHint: false,
          idempotentHint: true,
        },
      },
      async () => {
        try {
          const command = await queueAction(env, action);
          const result = await waitForResult(env, command.id);
          return {
            content: [{ type: "text", text: toolContent(action, command.id, result) }],
            structuredContent: {
              request_id: command.id,
              action,
              status: result?.status || "pending",
              result: result || null,
            },
          };
        } catch (error) {
          return { content: [{ type: "text", text: `AgentO Mobile: ${error.message}` }], isError: true };
        }
      },
    );
  }

  server.registerTool(
    "mobile_result",
    {
      description: "Use esta ferramenta para consultar o resultado de uma solicitação AgentO Mobile que ainda estava aguardando confirmação no telefone.",
      inputSchema: { request_id: z.string().min(8) },
      annotations: { readOnlyHint: true, destructiveHint: false, openWorldHint: false, idempotentHint: true },
    },
    async ({ request_id }) => {
      const result = await readResult(env, request_id);
      if (!result) {
        return {
          content: [{ type: "text", text: `A solicitação ${request_id} ainda não possui resultado. Verifique se a confirmação apareceu no telefone.` }],
          structuredContent: { request_id, status: "pending" },
        };
      }
      return {
        content: [{ type: "text", text: toolContent(result.action, request_id, result) }],
        structuredContent: { request_id, status: result.status, result },
      };
    },
  );

  return server;
}

async function deviceApi(request, env, url) {
  if (!deviceAuthorized(request, env)) return json({ ok: false, error: "unauthorized" }, 401);
  const deviceId = env.DEFAULT_DEVICE_ID || "fabio-phone";

  if (request.method === "GET" && url.pathname === "/api/device/pull") {
    const requested = url.searchParams.get("device_id") || "";
    if (requested !== deviceId) return json({ ok: false, error: "unknown_device" }, 404);
    const command = await readPending(env, deviceId);
    return json({ ok: true, command });
  }

  if (request.method === "POST" && url.pathname === "/api/device/result") {
    const body = await request.json();
    if (body.device_id !== deviceId) return json({ ok: false, error: "unknown_device" }, 404);
    if (!body.request_id || !ACTIONS.has(body.action)) return json({ ok: false, error: "invalid_result" }, 400);
    const pending = await readPending(env, deviceId);
    if (pending && pending.id !== body.request_id) return json({ ok: false, error: "request_mismatch" }, 409);
    const result = {
      request_id: body.request_id,
      device_id: deviceId,
      action: body.action,
      status: body.status || "completed",
      stdout: String(body.stdout || ""),
      stderr: String(body.stderr || ""),
      exit_code: Number(body.exit_code ?? -999),
      received_at: new Date().toISOString(),
    };
    await env.RELAY_KV.put(resultKey(body.request_id), JSON.stringify(result), { expirationTtl: 900 });
    if (pending && pending.id === body.request_id) await env.RELAY_KV.delete(pendingKey(deviceId));
    return json({ ok: true });
  }

  return json({ ok: false, error: "not_found" }, 404);
}

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    if (url.pathname === "/health") {
      return json({ ok: true, service: "AgentO Mobile Relay", version: VERSION, transport: "MCP Streamable HTTP" });
    }

    if (url.pathname.startsWith("/api/device/")) return deviceApi(request, env, url);

    const connectorKey = String(env.CONNECTOR_KEY || "");
    if (connectorKey && url.pathname === `/mcp/${connectorKey}`) {
      return createMcpHandler(() => createServer(env))(request, env, ctx);
    }

    return json({ ok: false, error: "not_found" }, 404);
  },
};
