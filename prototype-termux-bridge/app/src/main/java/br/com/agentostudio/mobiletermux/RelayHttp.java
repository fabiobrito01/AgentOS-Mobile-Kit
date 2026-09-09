package br.com.agentostudio.mobiletermux;

import android.content.Context;
import android.content.SharedPreferences;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public final class RelayHttp {
    public static final String PREFS = "agentomobile_relay";
    public static final String KEY_URL = "relay_url";
    public static final String KEY_DEVICE_ID = "device_id";
    public static final String KEY_TOKEN = "device_token";
    public static final String KEY_ENABLED = "relay_enabled";
    public static final String KEY_PENDING_ID = "pending_id";
    public static final String KEY_PENDING_ACTION = "pending_action";

    private RelayHttp() {}

    public static SharedPreferences prefs(Context context) {
        return context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }

    public static boolean configured(Context context) {
        SharedPreferences p = prefs(context);
        return !p.getString(KEY_URL, "").trim().isEmpty()
                && !p.getString(KEY_DEVICE_ID, "").trim().isEmpty()
                && !p.getString(KEY_TOKEN, "").trim().isEmpty();
    }

    public static String cleanBase(String value) {
        String s = value == null ? "" : value.trim();
        while (s.endsWith("/")) s = s.substring(0, s.length() - 1);
        return s;
    }

    private static HttpURLConnection open(Context context, String path, String method, boolean auth) throws Exception {
        SharedPreferences p = prefs(context);
        String base = cleanBase(p.getString(KEY_URL, ""));
        if (base.isEmpty()) throw new IllegalStateException("Relay URL não configurada.");
        URL url = new URL(base + path);
        HttpURLConnection c = (HttpURLConnection) url.openConnection();
        c.setRequestMethod(method);
        c.setConnectTimeout(10000);
        c.setReadTimeout(30000);
        c.setRequestProperty("Accept", "application/json");
        if (auth) {
            String token = p.getString(KEY_TOKEN, "").trim();
            if (token.isEmpty()) throw new IllegalStateException("Token do dispositivo não configurado.");
            c.setRequestProperty("Authorization", "Bearer " + token);
        }
        return c;
    }

    public static String health(Context context) throws Exception {
        HttpURLConnection c = open(context, "/health", "GET", false);
        int code = c.getResponseCode();
        String body = readBody(c, code);
        c.disconnect();
        if (code < 200 || code >= 300) throw new IllegalStateException("HTTP " + code + ": " + body);
        return body;
    }

    public static RelayCommand pull(Context context) throws Exception {
        SharedPreferences p = prefs(context);
        String deviceId = p.getString(KEY_DEVICE_ID, "").trim();
        if (deviceId.isEmpty()) throw new IllegalStateException("Device ID não configurado.");
        String path = "/api/device/pull?device_id=" + URLEncoder.encode(deviceId, "UTF-8");
        HttpURLConnection c = open(context, path, "GET", true);
        int code = c.getResponseCode();
        String body = readBody(c, code);
        c.disconnect();
        if (code < 200 || code >= 300) throw new IllegalStateException("HTTP " + code + ": " + body);
        JSONObject json = new JSONObject(body);
        Object raw = json.opt("command");
        if (!(raw instanceof JSONObject)) return null;
        JSONObject cmd = (JSONObject) raw;
        String id = cmd.optString("id", "").trim();
        String action = cmd.optString("action", "").trim();
        if (id.isEmpty() || action.isEmpty()) return null;
        return new RelayCommand(id, action);
    }

    public static void postResult(Context context, String requestId, String action,
                                  String status, String stdout, String stderr, int exitCode) throws Exception {
        SharedPreferences p = prefs(context);
        String deviceId = p.getString(KEY_DEVICE_ID, "").trim();
        JSONObject body = new JSONObject();
        body.put("device_id", deviceId);
        body.put("request_id", requestId == null ? "" : requestId);
        body.put("action", action == null ? "" : action);
        body.put("status", status == null ? "completed" : status);
        body.put("stdout", stdout == null ? "" : stdout);
        body.put("stderr", stderr == null ? "" : stderr);
        body.put("exit_code", exitCode);

        HttpURLConnection c = open(context, "/api/device/result", "POST", true);
        c.setDoOutput(true);
        c.setRequestProperty("Content-Type", "application/json; charset=utf-8");
        byte[] data = body.toString().getBytes(StandardCharsets.UTF_8);
        c.setFixedLengthStreamingMode(data.length);
        try (OutputStream out = c.getOutputStream()) {
            out.write(data);
        }
        int code = c.getResponseCode();
        String response = readBody(c, code);
        c.disconnect();
        if (code < 200 || code >= 300) throw new IllegalStateException("HTTP " + code + ": " + response);
    }

    public static void clearPending(Context context) {
        prefs(context).edit().remove(KEY_PENDING_ID).remove(KEY_PENDING_ACTION).apply();
    }

    private static String readBody(HttpURLConnection c, int code) throws Exception {
        InputStream stream = code >= 200 && code < 400 ? c.getInputStream() : c.getErrorStream();
        if (stream == null) return "";
        StringBuilder sb = new StringBuilder();
        try (BufferedReader r = new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = r.readLine()) != null) sb.append(line).append('\n');
        }
        return sb.toString().trim();
    }

    public static final class RelayCommand {
        public final String id;
        public final String action;
        RelayCommand(String id, String action) {
            this.id = id;
            this.action = action;
        }
    }
}
