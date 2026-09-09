package br.com.agentostudio.mobiletermux;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends Activity {
    private static final String TERMUX_PERMISSION = "com.termux.permission.RUN_COMMAND";
    private static final int REQ_TERMUX_PERMISSION = 1001;
    private static final String HOME = "/data/data/com.termux/files/home";
    private static final String BASH = "/data/data/com.termux/files/usr/bin/bash";

    private TextView statusView;
    private TextView relayView;
    private TextView resultView;
    private EditText commandInput;
    private Button relayButton;
    private String lastResult = "";
    private String lastAction = "";
    private String lastPromptedRelayId = "";

    private final BroadcastReceiver resultReceiver = new BroadcastReceiver() {
        @Override public void onReceive(Context context, Intent intent) {
            if (!PluginResultsService.ACTION_RESULT.equals(intent.getAction())) return;
            String purpose = intent.getStringExtra(PluginResultsService.EXTRA_PURPOSE);
            String stdout = intent.getStringExtra(PluginResultsService.EXTRA_STDOUT);
            String stderr = intent.getStringExtra(PluginResultsService.EXTRA_STDERR);
            int exitCode = intent.getIntExtra(PluginResultsService.EXTRA_EXIT_CODE, -999);
            if (stdout == null) stdout = "";
            if (stderr == null) stderr = "";
            String action = actionFromPurpose(purpose);
            lastAction = action;
            lastResult = stdout.trim().isEmpty() ? stderr.trim() : stdout.trim();
            if (!stderr.trim().isEmpty() && !stdout.trim().isEmpty()) lastResult += "\n\nERRO:\n" + stderr.trim();
            resultView.setText(lastResult.isEmpty() ? "Sem texto de retorno." : lastResult);
            statusView.setText(exitCode == 0 ? "Consulta concluída." : "Consulta terminou com erro.");
            if (purpose != null && purpose.startsWith("relay|")) {
                statusView.setText(exitCode == 0 ? "Resultado enviado ao relay." : "Resultado/erro devolvido ao relay.");
                lastPromptedRelayId = "";
            }
            updateRelayStatus();
        }
    };

    private final BroadcastReceiver incomingReceiver = new BroadcastReceiver() {
        @Override public void onReceive(Context context, Intent intent) {
            if (!RelayService.ACTION_INCOMING.equals(intent.getAction())) return;
            String id = intent.getStringExtra(RelayService.EXTRA_REQUEST_ID);
            String action = intent.getStringExtra(RelayService.EXTRA_ACTION);
            promptRelayCommand(id, action);
        }
    };

    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(buildUi());
        requestTermuxPermissionIfNeeded();
        updateRelayStatus();
        handleExternalIntent(getIntent());
    }

    @Override protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        handleExternalIntent(intent);
    }

    @Override protected void onStart() {
        super.onStart();
        IntentFilter resultFilter = new IntentFilter(PluginResultsService.ACTION_RESULT);
        IntentFilter relayFilter = new IntentFilter(RelayService.ACTION_INCOMING);
        if (Build.VERSION.SDK_INT >= 33) {
            registerReceiver(resultReceiver, resultFilter, Context.RECEIVER_NOT_EXPORTED);
            registerReceiver(incomingReceiver, relayFilter, Context.RECEIVER_NOT_EXPORTED);
        } else {
            registerReceiver(resultReceiver, resultFilter);
            registerReceiver(incomingReceiver, relayFilter);
        }
        maybePromptStoredCommand();
    }

    @Override protected void onStop() {
        try { unregisterReceiver(resultReceiver); } catch (Exception ignored) {}
        try { unregisterReceiver(incomingReceiver); } catch (Exception ignored) {}
        super.onStop();
    }

    private View buildUi() {
        int pad = dp(16);
        ScrollView scroll = new ScrollView(this);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(pad, pad, pad, pad);
        scroll.addView(root);

        TextView title = new TextView(this);
        title.setText("AgentO Mobile Relay");
        title.setTextSize(25);
        title.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        root.addView(title);

        TextView subtitle = new TextView(this);
        subtitle.setText("v0.4.0 · ChatGPT ↔ Relay HTTPS ↔ Termux ↔ Android · sem OpenAI API");
        subtitle.setTextSize(14);
        subtitle.setPadding(0, dp(4), 0, dp(10));
        root.addView(subtitle);

        statusView = new TextView(this);
        statusView.setText("Pronto.");
        statusView.setTextSize(15);
        statusView.setPadding(0, 0, 0, dp(8));
        root.addView(statusView);

        relayView = new TextView(this);
        relayView.setTextSize(13);
        relayView.setTextIsSelectable(true);
        relayView.setPadding(0, 0, 0, dp(8));
        root.addView(relayView);

        LinearLayout relayRow = row();
        Button config = smallButton("CONFIGURAR RELAY");
        config.setOnClickListener(v -> showRelayConfig());
        relayRow.addView(config, weight());
        relayButton = smallButton("CONECTAR RELAY");
        relayButton.setOnClickListener(v -> toggleRelay());
        relayRow.addView(relayButton, weight());
        root.addView(relayRow);

        Button testRelay = button("TESTAR ENDPOINT DO RELAY");
        testRelay.setOnClickListener(v -> testRelay());
        root.addView(testRelay);

        TextView quick = label("Consultas rápidas (sempre pedem confirmação):");
        root.addView(quick);

        LinearLayout row1 = row();
        Button battery = smallButton("BATERIA");
        battery.setOnClickListener(v -> confirmAndRun("battery", null));
        row1.addView(battery, weight());
        Button device = smallButton("DISPOSITIVO");
        device.setOnClickListener(v -> confirmAndRun("device", null));
        row1.addView(device, weight());
        root.addView(row1);

        LinearLayout row2 = row();
        Button storage = smallButton("ARMAZENAMENTO");
        storage.setOnClickListener(v -> confirmAndRun("storage", null));
        row2.addView(storage, weight());
        Button network = smallButton("REDE");
        network.setOnClickListener(v -> confirmAndRun("network", null));
        row2.addView(network, weight());
        root.addView(row2);

        Button full = button("DIAGNÓSTICO GERAL");
        full.setOnClickListener(v -> confirmAndRun("status", null));
        root.addView(full);

        commandInput = new EditText(this);
        commandInput.setHint("AGENTO:battery, AGENTO:device, AGENTO:storage...");
        commandInput.setSingleLine(false);
        commandInput.setMinLines(2);
        commandInput.setGravity(Gravity.TOP);
        root.addView(commandInput, new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));

        LinearLayout commandRow = row();
        Button interpret = smallButton("INTERPRETAR TEXTO");
        interpret.setOnClickListener(v -> interpretText(commandInput.getText().toString()));
        commandRow.addView(interpret, weight());
        Button paste = smallButton("COLAR E INTERPRETAR");
        paste.setOnClickListener(v -> pasteAndInterpret());
        commandRow.addView(paste, weight());
        root.addView(commandRow);

        TextView out = label("Resultado do celular:");
        out.setPadding(0, dp(10), 0, dp(4));
        root.addView(out);

        resultView = new TextView(this);
        resultView.setText("Nenhuma consulta executada ainda.");
        resultView.setTextSize(14);
        resultView.setTextIsSelectable(true);
        resultView.setPadding(dp(10), dp(10), dp(10), dp(10));
        root.addView(resultView);

        Button share = button("COMPARTILHAR RESULTADO COM CHATGPT");
        share.setOnClickListener(v -> shareResult());
        root.addView(share);

        Button termux = button("ABRIR TERMUX");
        termux.setOnClickListener(v -> openTermux());
        root.addView(termux);

        TextView note = new TextView(this);
        note.setText("Segurança v0.4: o relay só pode solicitar battery, device, storage, network ou status. O APK não aceita shell arbitrário vindo da internet e exige sua confirmação antes de cada ação. O token do dispositivo fica no armazenamento privado do app; produção futura usará Android Keystore/OAuth.");
        note.setTextSize(12);
        note.setPadding(0, dp(8), 0, dp(20));
        root.addView(note);

        return scroll;
    }

    private void showRelayConfig() {
        SharedPreferences p = RelayHttp.prefs(this);
        LinearLayout box = new LinearLayout(this);
        box.setOrientation(LinearLayout.VERTICAL);
        int pad = dp(16);
        box.setPadding(pad, 0, pad, 0);

        EditText url = new EditText(this);
        url.setHint("https://seu-relay.workers.dev");
        url.setText(p.getString(RelayHttp.KEY_URL, ""));
        url.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_URI);
        box.addView(url);

        EditText device = new EditText(this);
        device.setHint("Device ID, ex.: fabio-phone");
        device.setText(p.getString(RelayHttp.KEY_DEVICE_ID, "fabio-phone"));
        box.addView(device);

        EditText token = new EditText(this);
        token.setHint("Token do dispositivo");
        token.setText(p.getString(RelayHttp.KEY_TOKEN, ""));
        token.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        box.addView(token);

        new AlertDialog.Builder(this)
                .setTitle("Configurar Relay HTTPS")
                .setMessage("Use apenas um endpoint HTTPS seu. O token não é enviado ao ChatGPT; ele autentica somente o APK no relay.")
                .setView(box)
                .setNegativeButton("Cancelar", null)
                .setPositiveButton("Salvar", (dialog, which) -> {
                    String u = RelayHttp.cleanBase(url.getText().toString());
                    String d = device.getText().toString().trim();
                    String t = token.getText().toString().trim();
                    RelayHttp.prefs(this).edit()
                            .putString(RelayHttp.KEY_URL, u)
                            .putString(RelayHttp.KEY_DEVICE_ID, d)
                            .putString(RelayHttp.KEY_TOKEN, t)
                            .apply();
                    updateRelayStatus();
                    Toast.makeText(this, "Configuração do relay salva.", Toast.LENGTH_LONG).show();
                })
                .show();
    }

    private void toggleRelay() {
        SharedPreferences p = RelayHttp.prefs(this);
        boolean enabled = p.getBoolean(RelayHttp.KEY_ENABLED, false);
        if (enabled) {
            p.edit().putBoolean(RelayHttp.KEY_ENABLED, false).apply();
            stopService(new Intent(this, RelayService.class));
            statusView.setText("Relay desconectado.");
        } else {
            if (!RelayHttp.configured(this)) {
                Toast.makeText(this, "Configure URL, Device ID e token primeiro.", Toast.LENGTH_LONG).show();
                showRelayConfig();
                return;
            }
            p.edit().putBoolean(RelayHttp.KEY_ENABLED, true).apply();
            Intent service = new Intent(this, RelayService.class);
            if (Build.VERSION.SDK_INT >= 26) startForegroundService(service); else startService(service);
            statusView.setText("Relay conectado. Aguardando solicitações.");
        }
        updateRelayStatus();
    }

    private void testRelay() {
        if (!RelayHttp.configured(this)) {
            Toast.makeText(this, "Configure o relay primeiro.", Toast.LENGTH_LONG).show();
            return;
        }
        statusView.setText("Testando relay...");
        new Thread(() -> {
            try {
                String response = RelayHttp.health(this);
                runOnUiThread(() -> {
                    statusView.setText("Relay HTTPS respondeu corretamente.");
                    resultView.setText(response);
                });
            } catch (Exception e) {
                runOnUiThread(() -> {
                    statusView.setText("Falha ao acessar o relay.");
                    resultView.setText(e.toString());
                });
            }
        }, "RelayHealth").start();
    }

    private void updateRelayStatus() {
        SharedPreferences p = RelayHttp.prefs(this);
        boolean enabled = p.getBoolean(RelayHttp.KEY_ENABLED, false);
        String url = p.getString(RelayHttp.KEY_URL, "");
        String device = p.getString(RelayHttp.KEY_DEVICE_ID, "");
        String pending = p.getString(RelayHttp.KEY_PENDING_ACTION, "");
        relayView.setText("Relay: " + (enabled ? "CONECTADO" : "desconectado") +
                "\nURL: " + (url == null || url.isEmpty() ? "não configurada" : url) +
                "\nDevice: " + (device == null || device.isEmpty() ? "não configurado" : device) +
                (pending == null || pending.isEmpty() ? "" : "\nPendente: " + friendlyAction(pending)));
        relayButton.setText(enabled ? "DESCONECTAR RELAY" : "CONECTAR RELAY");
    }

    private void maybePromptStoredCommand() {
        SharedPreferences p = RelayHttp.prefs(this);
        String id = p.getString(RelayHttp.KEY_PENDING_ID, "");
        String action = p.getString(RelayHttp.KEY_PENDING_ACTION, "");
        if (id != null && !id.isEmpty() && action != null && !action.isEmpty()) promptRelayCommand(id, action);
    }

    private void promptRelayCommand(String id, String action) {
        if (id == null || id.trim().isEmpty()) return;
        if (id.equals(lastPromptedRelayId)) return;
        lastPromptedRelayId = id;
        if (!allowedAction(action)) {
            denyRelay(id, action, "Ação não autorizada pela lista segura da v0.4.");
            return;
        }
        confirmAndRun(action, id);
    }

    private void confirmAndRun(String action, String relayRequestId) {
        if (!allowedAction(action)) {
            Toast.makeText(this, "Ação não reconhecida.", Toast.LENGTH_LONG).show();
            return;
        }
        String source = relayRequestId == null ? "Solicitação local" : "Solicitação recebida pelo relay";
        new AlertDialog.Builder(this)
                .setTitle("Autorizar ação no celular")
                .setMessage(source + ":\n\n" + friendlyAction(action) + "\n\nEsta versão executa somente consultas de leitura pré-definidas.")
                .setNegativeButton("Negar", (dialog, which) -> {
                    if (relayRequestId != null) denyRelay(relayRequestId, action, "Usuário negou a solicitação no aparelho.");
                })
                .setPositiveButton("Executar", (dialog, which) -> executeAction(action, relayRequestId))
                .show();
    }

    private void denyRelay(String id, String action, String reason) {
        statusView.setText("Solicitação negada.");
        resultView.setText(reason);
        new Thread(() -> {
            try { RelayHttp.postResult(this, id, action, "denied", "", reason, -1); }
            catch (Exception ignored) {}
            RelayHttp.clearPending(this);
            runOnUiThread(() -> {
                lastPromptedRelayId = "";
                updateRelayStatus();
            });
        }, "RelayDeny").start();
    }

    private void executeAction(String action, String relayRequestId) {
        String command = commandFor(action);
        if (command == null) return;
        lastAction = action;
        statusView.setText(relayRequestId == null ? "Executando consulta no Termux..." : "Executando solicitação do relay no Termux...");
        resultView.setText("Aguardando retorno...");
        String purpose = relayRequestId == null ? "manual|" + action : "relay|" + relayRequestId + "|" + action;
        runTermuxShell(command, purpose, "AgentO " + friendlyAction(action));
    }

    private String commandFor(String action) {
        if ("battery".equals(action)) {
            return "if command -v termux-battery-status >/dev/null 2>&1; then termux-battery-status; else echo 'termux-battery-status não encontrado'; exit 2; fi";
        }
        if ("device".equals(action)) {
            return "echo '=== DISPOSITIVO ==='; " +
                    "echo 'manufacturer:'; getprop ro.product.manufacturer; " +
                    "echo 'model:'; getprop ro.product.model; " +
                    "echo 'android:'; getprop ro.build.version.release; " +
                    "echo 'sdk:'; getprop ro.build.version.sdk; " +
                    "echo 'abi:'; getprop ro.product.cpu.abi";
        }
        if ("storage".equals(action)) {
            return "echo '=== ARMAZENAMENTO ==='; df -h \"$HOME\" /storage/emulated/0 2>/dev/null || df -h";
        }
        if ("network".equals(action)) {
            return "echo '=== REDE ==='; if command -v termux-wifi-connectioninfo >/dev/null 2>&1; then termux-wifi-connectioninfo; else ip -brief addr 2>/dev/null || echo 'Termux:API Wi-Fi não disponível'; fi";
        }
        if ("status".equals(action)) {
            return "echo '=== AGENTO MOBILE STATUS ==='; date; echo; " +
                    "echo '--- BATERIA ---'; (termux-battery-status 2>/dev/null || true); echo; " +
                    "echo '--- DISPOSITIVO ---'; getprop ro.product.manufacturer; getprop ro.product.model; getprop ro.build.version.release; uname -m; echo; " +
                    "echo '--- ARMAZENAMENTO ---'; df -h \"$HOME\" /storage/emulated/0 2>/dev/null || df -h; echo; " +
                    "echo '--- REDE ---'; (termux-wifi-connectioninfo 2>/dev/null || true)";
        }
        return null;
    }

    private boolean allowedAction(String action) {
        return "battery".equals(action) || "device".equals(action) || "storage".equals(action)
                || "network".equals(action) || "status".equals(action);
    }

    private String friendlyAction(String action) {
        if ("battery".equals(action)) return "Consultar bateria";
        if ("device".equals(action)) return "Consultar dispositivo";
        if ("storage".equals(action)) return "Consultar armazenamento";
        if ("network".equals(action)) return "Consultar rede";
        if ("status".equals(action)) return "Diagnóstico geral";
        return action == null ? "" : action;
    }

    private String actionFromPurpose(String purpose) {
        if (purpose == null) return lastAction;
        if (purpose.startsWith("manual|")) return purpose.substring("manual|".length());
        if (purpose.startsWith("relay|")) {
            String[] p = purpose.split("\\|", 3);
            return p.length == 3 ? p[2] : lastAction;
        }
        return lastAction;
    }

    private void interpretText(String text) {
        String action = parseAction(text);
        if (action == null) {
            Toast.makeText(this, "Comando não reconhecido. Use AGENTO:battery/device/storage/network/status.", Toast.LENGTH_LONG).show();
            return;
        }
        confirmAndRun(action, null);
    }

    private String parseAction(String text) {
        if (text == null) return null;
        String s = text.trim();
        if (s.toLowerCase().startsWith("agentomobile://")) {
            try {
                Uri u = Uri.parse(s);
                String a = u.getQueryParameter("action");
                return allowedAction(a) ? a : null;
            } catch (Exception ignored) {}
        }
        String lower = s.toLowerCase();
        if (lower.startsWith("agento:")) lower = lower.substring(7).trim();
        if (allowedAction(lower)) return lower;
        return null;
    }

    private void pasteAndInterpret() {
        ClipboardManager cm = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
        if (cm == null || !cm.hasPrimaryClip() || cm.getPrimaryClip() == null || cm.getPrimaryClip().getItemCount() == 0) {
            Toast.makeText(this, "Área de transferência vazia.", Toast.LENGTH_SHORT).show();
            return;
        }
        CharSequence cs = cm.getPrimaryClip().getItemAt(0).coerceToText(this);
        commandInput.setText(cs);
        interpretText(cs == null ? "" : cs.toString());
    }

    private void handleExternalIntent(Intent intent) {
        if (intent == null) return;
        String relayId = intent.getStringExtra(RelayService.EXTRA_REQUEST_ID);
        String relayAction = intent.getStringExtra(RelayService.EXTRA_ACTION);
        if (relayId != null && relayAction != null) {
            promptRelayCommand(relayId, relayAction);
            intent.removeExtra(RelayService.EXTRA_REQUEST_ID);
            intent.removeExtra(RelayService.EXTRA_ACTION);
            return;
        }
        if (Intent.ACTION_VIEW.equals(intent.getAction()) && intent.getData() != null) {
            String action = intent.getData().getQueryParameter("action");
            if (allowedAction(action)) confirmAndRun(action, null);
        } else if (Intent.ACTION_SEND.equals(intent.getAction()) && "text/plain".equals(intent.getType())) {
            String text = intent.getStringExtra(Intent.EXTRA_TEXT);
            if (text != null) {
                commandInput.setText(text);
                String action = parseAction(text);
                if (action != null) confirmAndRun(action, null);
            }
        }
    }

    private void shareResult() {
        if (lastResult == null || lastResult.trim().isEmpty()) {
            Toast.makeText(this, "Nenhum resultado para compartilhar.", Toast.LENGTH_SHORT).show();
            return;
        }
        String text = "AgentO Mobile Relay v0.4 — sem OpenAI API.\n\nResultado — " + friendlyAction(lastAction) + ":\n" + lastResult;
        Intent send = new Intent(Intent.ACTION_SEND);
        send.setType("text/plain");
        send.putExtra(Intent.EXTRA_TEXT, text);
        startActivity(Intent.createChooser(send, "Compartilhar resultado"));
    }

    private void runTermuxShell(String command, String purpose, String label) {
        if (Build.VERSION.SDK_INT >= 23 && checkSelfPermission(TERMUX_PERMISSION) != PackageManager.PERMISSION_GRANTED) {
            statusView.setText("Permissão RUN_COMMAND não concedida.");
            requestTermuxPermissionIfNeeded();
            return;
        }
        int executionId = PluginResultsService.getNextExecutionId();
        Intent resultIntent = new Intent(this, PluginResultsService.class);
        resultIntent.putExtra(PluginResultsService.EXTRA_EXECUTION_ID, executionId);
        resultIntent.putExtra(PluginResultsService.EXTRA_PURPOSE, purpose);
        int flags = PendingIntent.FLAG_ONE_SHOT;
        if (Build.VERSION.SDK_INT >= 31) flags |= PendingIntent.FLAG_MUTABLE;
        PendingIntent pendingIntent = PendingIntent.getService(this, executionId, resultIntent, flags);

        Intent intent = new Intent();
        intent.setClassName("com.termux", "com.termux.app.RunCommandService");
        intent.setAction("com.termux.RUN_COMMAND");
        intent.putExtra("com.termux.RUN_COMMAND_PATH", BASH);
        intent.putExtra("com.termux.RUN_COMMAND_ARGUMENTS", new String[]{"-lc", command});
        intent.putExtra("com.termux.RUN_COMMAND_WORKDIR", HOME);
        intent.putExtra("com.termux.RUN_COMMAND_BACKGROUND", true);
        intent.putExtra("com.termux.RUN_COMMAND_COMMAND_LABEL", label);
        intent.putExtra("com.termux.RUN_COMMAND_PENDING_INTENT", pendingIntent);
        try {
            startService(intent);
        } catch (SecurityException e) {
            statusView.setText("Acesso ao Termux negado. Verifique RUN_COMMAND e allow-external-apps=true.");
            resultView.setText(e.toString());
        } catch (Exception e) {
            statusView.setText("Não foi possível chamar o Termux.");
            resultView.setText(e.toString());
        }
    }

    private void requestTermuxPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= 23 && checkSelfPermission(TERMUX_PERMISSION) != PackageManager.PERMISSION_GRANTED) {
            try { requestPermissions(new String[]{TERMUX_PERMISSION}, REQ_TERMUX_PERMISSION); }
            catch (Exception ignored) {}
        }
    }

    private void openTermux() {
        Intent launch = getPackageManager().getLaunchIntentForPackage("com.termux");
        if (launch != null) startActivity(launch);
        else Toast.makeText(this, "Termux não encontrado.", Toast.LENGTH_LONG).show();
    }

    private LinearLayout row() {
        LinearLayout r = new LinearLayout(this);
        r.setOrientation(LinearLayout.HORIZONTAL);
        r.setPadding(0, dp(4), 0, 0);
        return r;
    }

    private LinearLayout.LayoutParams weight() {
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f);
        lp.setMargins(dp(2), 0, dp(2), 0);
        return lp;
    }

    private Button button(String text) {
        Button b = new Button(this);
        b.setText(text);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.topMargin = dp(6);
        b.setLayoutParams(lp);
        return b;
    }

    private Button smallButton(String text) {
        Button b = new Button(this);
        b.setText(text);
        b.setTextSize(11);
        b.setAllCaps(false);
        return b;
    }

    private TextView label(String text) {
        TextView t = new TextView(this);
        t.setText(text);
        t.setTextSize(16);
        t.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        t.setPadding(0, dp(8), 0, dp(2));
        return t;
    }

    private int dp(int value) { return Math.round(value * getResources().getDisplayMetrics().density); }
}
