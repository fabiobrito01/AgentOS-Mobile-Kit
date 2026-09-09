#!/usr/bin/env python3
import json
import os
import pathlib
import platform
import subprocess
import sys
import urllib.error
import urllib.request

BASE = pathlib.Path.home() / ".agentomobile"
KEY_FILE = BASE / "openai_api_key"
MODEL_FILE = BASE / "model"
STATE_FILE = BASE / "state.json"
API_URL = "https://api.openai.com/v1/responses"
DEFAULT_MODEL = "gpt-5.6-luna"

INSTRUCTIONS = """Você é o AgentO Mobile, um assistente de IA executado no Android do usuário. Responda em português do Brasil. Você possui ferramentas somente de leitura do aparelho nesta versão. Quando a pergunta depender do estado real do celular, use a ferramenta adequada antes de responder. Nunca invente que consultou ou alterou algo. Se o usuário pedir uma ação de escrita, envio, exclusão, toque na tela ou mudança de configuração, explique de forma curta que a v0.2 ainda está em modo leitura e que essa capacidade será adicionada ao Android Bridge. Seja objetivo e apresente valores técnicos de forma compreensível."""

TOOLS = [
    {
        "type": "function",
        "name": "get_battery_status",
        "description": "Lê o estado real da bateria do Android usando Termux:API, incluindo percentual, temperatura, saúde, tensão e estado de carga.",
        "parameters": {"type": "object", "properties": {}, "required": [], "additionalProperties": False},
        "strict": True,
    },
    {
        "type": "function",
        "name": "get_device_info",
        "description": "Lê informações reais do dispositivo Android, fabricante, modelo, versão do Android, arquitetura, kernel e identidade do ambiente Termux.",
        "parameters": {"type": "object", "properties": {}, "required": [], "additionalProperties": False},
        "strict": True,
    },
    {
        "type": "function",
        "name": "get_storage_status",
        "description": "Lê o uso de armazenamento disponível no ambiente Termux e no armazenamento compartilhado do Android quando acessível.",
        "parameters": {"type": "object", "properties": {}, "required": [], "additionalProperties": False},
        "strict": True,
    },
    {
        "type": "function",
        "name": "get_network_status",
        "description": "Lê informações de conexão de rede e Wi-Fi disponíveis no aparelho sem modificar a rede.",
        "parameters": {"type": "object", "properties": {}, "required": [], "additionalProperties": False},
        "strict": True,
    },
]


def run(cmd, timeout=20):
    try:
        p = subprocess.run(cmd, shell=True, text=True, capture_output=True, timeout=timeout)
        return {
            "exit_code": p.returncode,
            "stdout": p.stdout.strip(),
            "stderr": p.stderr.strip(),
        }
    except subprocess.TimeoutExpired:
        return {"exit_code": 124, "stdout": "", "stderr": "tempo limite excedido"}
    except Exception as exc:
        return {"exit_code": 1, "stdout": "", "stderr": str(exc)}


def get_battery_status():
    result = run("termux-battery-status", 20)
    if result["exit_code"] == 0 and result["stdout"]:
        try:
            return {"ok": True, "data": json.loads(result["stdout"])}
        except Exception:
            return {"ok": True, "raw": result["stdout"]}
    return {"ok": False, "error": result["stderr"] or "termux-battery-status indisponível"}


def get_device_info():
    props = {
        "fabricante": run("getprop ro.product.manufacturer")["stdout"],
        "modelo": run("getprop ro.product.model")["stdout"],
        "android": run("getprop ro.build.version.release")["stdout"],
        "sdk": run("getprop ro.build.version.sdk")["stdout"],
        "dispositivo": run("getprop ro.product.device")["stdout"],
        "arquitetura": platform.machine(),
        "kernel": platform.platform(),
        "usuario_termux": run("whoami")["stdout"],
        "diretorio": str(pathlib.Path.home()),
    }
    return {"ok": True, "data": props}


def get_storage_status():
    result = run("df -h $HOME /storage/emulated/0 2>&1", 20)
    return {"ok": result["exit_code"] == 0, "raw": result["stdout"] or result["stderr"]}


def get_network_status():
    wifi = run("termux-wifi-connectioninfo", 20)
    if wifi["exit_code"] == 0 and wifi["stdout"]:
        try:
            return {"ok": True, "wifi": json.loads(wifi["stdout"])}
        except Exception:
            return {"ok": True, "wifi_raw": wifi["stdout"]}
    fallback = run("ip addr 2>&1 | head -n 80", 20)
    return {
        "ok": fallback["exit_code"] == 0,
        "wifi_error": wifi["stderr"] or wifi["stdout"],
        "network_raw": fallback["stdout"] or fallback["stderr"],
    }


def execute_tool(name, arguments):
    if name == "get_battery_status":
        return get_battery_status()
    if name == "get_device_info":
        return get_device_info()
    if name == "get_storage_status":
        return get_storage_status()
    if name == "get_network_status":
        return get_network_status()
    return {"ok": False, "error": "Ferramenta desconhecida: " + str(name)}


def read_key():
    env = os.environ.get("OPENAI_API_KEY", "").strip()
    if env:
        return env
    if KEY_FILE.exists():
        return KEY_FILE.read_text(encoding="utf-8").strip()
    return ""


def read_model():
    if MODEL_FILE.exists():
        value = MODEL_FILE.read_text(encoding="utf-8").strip()
        if value:
            return value
    return DEFAULT_MODEL


def load_previous_response_id():
    try:
        if STATE_FILE.exists():
            data = json.loads(STATE_FILE.read_text(encoding="utf-8"))
            return data.get("previous_response_id") or None
    except Exception:
        pass
    return None


def save_previous_response_id(response_id):
    BASE.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps({"previous_response_id": response_id}), encoding="utf-8")


def api_request(payload, api_key):
    data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(
        API_URL,
        data=data,
        method="POST",
        headers={
            "Authorization": "Bearer " + api_key,
            "Content-Type": "application/json",
            "User-Agent": "AgentO-Mobile/0.2.0",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=90) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        try:
            parsed = json.loads(body)
            message = parsed.get("error", {}).get("message", body)
        except Exception:
            message = body
        if exc.code == 401:
            raise RuntimeError("Chave da OpenAI inválida ou não autorizada.")
        if exc.code == 429:
            raise RuntimeError("Limite ou saldo da API atingido. Verifique o faturamento da API OpenAI.")
        raise RuntimeError("OpenAI API HTTP %s: %s" % (exc.code, message[:800]))
    except urllib.error.URLError as exc:
        raise RuntimeError("Falha de rede ao acessar a OpenAI: %s" % exc.reason)


def extract_text(response):
    if isinstance(response.get("output_text"), str) and response.get("output_text").strip():
        return response["output_text"].strip()
    texts = []
    for item in response.get("output", []):
        if item.get("type") != "message":
            continue
        for content in item.get("content", []):
            if content.get("type") == "output_text" and content.get("text"):
                texts.append(content["text"])
    return "\n".join(texts).strip()


def make_payload(model, input_value, previous_response_id=None):
    payload = {
        "model": model,
        "input": input_value,
        "instructions": INSTRUCTIONS,
        "tools": TOOLS,
        "tool_choice": "auto",
        "parallel_tool_calls": True,
        "reasoning": {"effort": "low"},
        "text": {"verbosity": "low"},
        "max_output_tokens": 1400,
    }
    if previous_response_id:
        payload["previous_response_id"] = previous_response_id
    return payload


def chat(user_text):
    api_key = read_key()
    if not api_key:
        return "A OpenAI ainda não está configurada. No AgentO Mobile, toque em CONFIGURAR OPENAI e informe uma chave de API. A chave será armazenada no Termux, não dentro do APK."
    model = read_model()
    previous = load_previous_response_id()
    response = api_request(make_payload(model, user_text, previous), api_key)

    for _ in range(6):
        calls = [item for item in response.get("output", []) if item.get("type") == "function_call"]
        if not calls:
            break
        tool_outputs = []
        for call in calls:
            try:
                args = json.loads(call.get("arguments") or "{}")
            except Exception:
                args = {}
            result = execute_tool(call.get("name", ""), args)
            tool_outputs.append({
                "type": "function_call_output",
                "call_id": call.get("call_id"),
                "output": json.dumps(result, ensure_ascii=False),
            })
        response = api_request(make_payload(model, tool_outputs, response.get("id")), api_key)

    response_id = response.get("id")
    if response_id:
        save_previous_response_id(response_id)
    text = extract_text(response)
    if not text:
        return "A IA concluiu a execução, mas não retornou texto. Use DIAGNÓSTICO e tente novamente."
    return text


def diagnostic():
    py = sys.version.split()[0]
    battery = get_battery_status()
    return {
        "agent_core": "0.2.0",
        "python": py,
        "model": read_model(),
        "api_key_configured": bool(read_key()),
        "termux_api_battery": battery.get("ok", False),
        "battery_sample": battery.get("data", {}).get("percentage") if battery.get("ok") else None,
        "state_exists": STATE_FILE.exists(),
    }


def main():
    BASE.mkdir(parents=True, exist_ok=True)
    arg = sys.argv[1] if len(sys.argv) > 1 else "--diagnostic"
    if arg == "--chat-stdin":
        text = sys.stdin.read().strip()
        if not text:
            print("Digite uma mensagem.")
            return 2
        try:
            print(chat(text))
            return 0
        except Exception as exc:
            print("Erro do AgentO: " + str(exc))
            return 1
    if arg == "--diagnostic" or arg == "--self-test":
        print(json.dumps(diagnostic(), ensure_ascii=False, indent=2))
        return 0
    if arg == "--reset":
        try:
            STATE_FILE.unlink(missing_ok=True)
        except TypeError:
            if STATE_FILE.exists():
                STATE_FILE.unlink()
        print("Conversa da IA reiniciada.")
        return 0
    if arg == "--local-battery":
        print(json.dumps(get_battery_status(), ensure_ascii=False, indent=2))
        return 0
    print("Uso: agent_core.py --chat-stdin | --diagnostic | --reset | --local-battery")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
