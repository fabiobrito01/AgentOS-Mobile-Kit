# AgentO Mobile Relay v0.4

Ponte sem OpenAI API entre ChatGPT/MCP e o AgentO Mobile no Android.

## Fluxo

ChatGPT -> MCP Streamable HTTP -> Cloudflare Worker/KV -> AgentO Mobile -> Termux/Termux:API -> Android -> Worker -> ChatGPT.

O APK aceita somente as ações `battery`, `device`, `storage`, `network` e `status`. Toda ação recebida pelo relay exige confirmação no aparelho antes da execução. O relay nunca envia shell arbitrário ao APK.

## Preparação Cloudflare

1. `npm install`
2. Crie um KV: `npx wrangler kv namespace create RELAY_KV`.
3. Copie `wrangler.example.jsonc` para `wrangler.jsonc` e substitua `COLOQUE_AQUI_O_ID_DO_KV` pelo ID retornado.
4. Crie dois valores aleatórios fortes e grave como secrets:
   - `npx wrangler secret put DEVICE_TOKEN`
   - `npx wrangler secret put CONNECTOR_KEY`
5. `npm run deploy`.

O `DEVICE_TOKEN` é configurado somente no APK. O `CONNECTOR_KEY` faz parte do caminho privado do MCP: `https://<worker>/mcp/<CONNECTOR_KEY>` e deve ser tratado como credencial do protótipo.

## Configuração no APK

Em **CONFIGURAR RELAY** informe:

- URL base HTTPS do Worker, sem `/mcp`;
- Device ID igual a `DEFAULT_DEVICE_ID` (padrão: `fabio-phone`);
- o mesmo `DEVICE_TOKEN` salvo no Worker.

Use **TESTAR ENDPOINT DO RELAY** e depois **CONECTAR RELAY**. O serviço foreground fará polling e notificará quando houver uma solicitação aguardando confirmação.

## Ferramentas MCP

- `mobile_battery`
- `mobile_device`
- `mobile_storage`
- `mobile_network`
- `mobile_status`
- `mobile_result(request_id)`

As cinco primeiras enfileiram uma consulta e aguardam até 50 segundos pelo resultado. Se o usuário ainda não confirmou no celular, retornam `pending` e o resultado pode ser consultado depois por `mobile_result`.

## Segurança do protótipo

- HTTPS obrigatório no APK (`usesCleartextTraffic=false`).
- Token do dispositivo via `Authorization: Bearer`.
- MCP em caminho secreto no protótipo; migrar para OAuth antes de produção/multiusuário.
- Lista fechada de consultas somente de leitura.
- Confirmação humana no Android para cada solicitação.
- Nenhuma chave OpenAI é usada ou armazenada.
- Tokens nunca devem ser commitados no GitHub.
