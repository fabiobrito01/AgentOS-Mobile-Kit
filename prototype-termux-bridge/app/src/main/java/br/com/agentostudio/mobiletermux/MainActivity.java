package br.com.agentostudio.mobiletermux;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONObject;

import java.text.Normalizer;
import java.util.Locale;

public class MainActivity extends Activity {
    private static final String TERMUX_PERMISSION = "com.termux.permission.RUN_COMMAND";
    private static final int REQ_TERMUX_PERMISSION = 1001;
    private static final String HOME = "/data/data/com.termux/files/home";
    private static final String BASH = "/data/data/com.termux/files/usr/bin/bash";

    private TextView statusView;
    private TextView outputView;
    private ScrollView outputScroll;
    private String lastResult = "";
    private String lastAction = "";
    private String originalRequest = "";
    private String pendingAction = null;

    private final BroadcastReceiver resultReceiver = new BroadcastReceiver() {
        @Override public void onReceive(Context context, Intent intent) {
            if (!PluginResultsService.ACTION_RESULT.equals(intent.getAction())) return;

            String purpose = intent.getStringExtra(PluginResultsService.EXTRA_PURPOSE);
            String stdout = intent.getStringExtra(PluginResultsService.EXTRA_STDOUT);
            String stderr = intent.getStringExtra(PluginResultsService.EXTRA_STDERR);
            int exitCode = intent.getIntExtra(PluginResultsService.EXTRA_EXIT_CODE, -999);

            if (stdout == null) stdout = "";
            if (stderr == null) stderr = "";

            lastAction = purpose == null ? "" : purpose;
            if (exitCode == 0) {
                lastResult = stdout.trim();
                if (lastResult.isEmpty()) lastResult = "Comando concluído sem texto de retorno.";
                statusView.setText("Concluído. Resultado pronto para compartilhar com o ChatGPT.");
                appendOutput("Resultado — " + friendlyAction(lastAction), lastResult);
            } else {
                lastResult = (stdout + (stderr.isEmpty() ? "" : "\n" + stderr)).trim();
                if (lastResult.isEmpty()) lastResult = "Falha sem texto de retorno. exitCode=" + exitCode;
                statusView.setText("O comando terminou com erro.");
                appendOutput("Erro — " + friendlyAction(lastAction), lastResult);
            }
        }
    };

    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(buildUi());
        requestTermuxPermissionIfNeeded();
        appendOutput("AgentO", "v0.3.0 pronta. Esta versão não usa OpenAI API. Ela recebe uma ação do ChatGPT por compartilhamento, texto ou deep link, pede sua confirmação, executa no Termux e permite compartilhar o resultado de volta.");
        handleIncomingIntent(getIntent());
    }

    @Override protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        handleIncomingIntent(intent);
    }

    @Override protected void onStart() {
        super.onStart();
        IntentFilter filter = new IntentFilter(PluginResultsService.ACTION_RESULT);
        if (Build.VERSION.SDK_INT >= 33) registerReceiver(resultReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
        else registerReceiver(resultReceiver, filter);
    }

    @Override protected void onStop() {
        try { unregisterReceiver(resultReceiver); } catch (Exception ignored) {}
        super.onStop();
    }

    @Override public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQ_TERMUX_PERMISSION && grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            statusView.setText("Permissão do Termux concedida.");
            if (pendingAction != null) {
                String action = pendingAction;
                pendingAction = null;
                executeAction(action);
            }
        }
    }

    private View buildUi() {
        int pad = dp(16);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(pad, pad, pad, pad);

        TextView title = new TextView(this);
        title.setText("AgentO Mobile Connector");
        title.setTextSize(25);
        title.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        root.addView(title);

        TextView subtitle = new TextView(this);
        subtitle.setText("v0.3.0 · ChatGPT sem API → Termux → Android");
        subtitle.setTextSize(14);
        subtitle.setPadding(0, dp(4), 0, dp(10));
        root.addView(subtitle);

        statusView = new TextView(this);
        statusView.setText("Pronto. Aguardando uma ação.");
        statusView.setTextSize(15);
        statusView.setPadding(0, 0, 0, dp(10));
        root.addView(statusView);

        outputScroll = new ScrollView(this);
        outputView = new TextView(this);
        outputView.setTextSize(15);
        outputView.setTextIsSelectable(true);
        outputView.setPadding(dp(12), dp(12), dp(12), dp(12));
        outputScroll.addView(outputView);
        LinearLayout.LayoutParams outLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f);
        root.addView(outputScroll, outLp);

        Button paste = button("COLAR / INTERPRETAR COMANDO DO CHATGPT");
        paste.setOnClickListener(v -> pasteFromClipboard());
        root.addView(paste);

        Button share = button("COMPARTILHAR RESULTADO COM CHATGPT");
        share.setOnClickListener(v -> shareResultToChatGPT());
        root.addView(share);

        LinearLayout row1 = horizontalRow();
        Button battery = smallButton("Bateria");
        battery.setOnClickListener(v -> confirmAction("battery", "Teste iniciado manualmente no APK."));
        row1.addView(battery, weightedButtonParams());
        Button device = smallButton("Dispositivo");
        device.setOnClickListener(v -> confirmAction("device", "Teste iniciado manualmente no APK."));
        row1.addView(device, weightedButtonParams());
        root.addView(row1);

        LinearLayout row2 = horizontalRow();
        Button storage = smallButton("Armazenamento");
        storage.setOnClickListener(v -> confirmAction("storage", "Teste iniciado manualmente no APK."));
        row2.addView(storage, weightedButtonParams());
        Button network = smallButton("Rede / Wi-Fi");
        network.setOnClickListener(v -> confirmAction("network", "Teste iniciado manualmente no APK."));
        row2.addView(network, weightedButtonParams());
        root.addView(row2);

        LinearLayout row3 = horizontalRow();
        Button status = smallButton("Status Termux");
        status.setOnClickListener(v -> confirmAction("status", "Teste iniciado manualmente no APK."));
        row3.addView(status, weightedButtonParams());
        Button examples = smallButton("Copiar exemplos");
        examples.setOnClickListener(v -> copyExamples());
        row3.addView(examples, weightedButtonParams());
        root.addView(row3);

        LinearLayout row4 = horizontalRow();
        Button chatgpt = smallButton("Abrir ChatGPT");
        chatgpt.setOnClickListener(v -> openChatGPT());
        row4.addView(chatgpt, weightedButtonParams());
        Button termux = smallButton("Abrir Termux");
        termux.setOnClickListener(v -> openTermux());
        row4.addView(termux, weightedButtonParams());
        root.addView(row4);

        TextView note = new TextView(this);
        note.setText("Protocolo v0.3: AGENTO:battery, AGENTO:device, AGENTO:storage, AGENTO:network ou AGENTO:status. Também aceita agentomobile://run?action=battery. Ações externas são limitadas a consultas de leitura e sempre pedem confirmação.");
        note.setTextSize(12);
        note.setPadding(0, dp(8), 0, 0);
        root.addView(note);

        return root;
    }

    private void handleIncomingIntent(Intent intent) {
        if (intent == null) return;

        if (Intent.ACTION_VIEW.equals(intent.getAction())) {
            Uri data = intent.getData();
            if (data != null && "agentomobile".equalsIgnoreCase(data.getScheme()) && "run".equalsIgnoreCase(data.getHost())) {
                String action = canonicalAction(data.getQueryParameter("action"));
                if (action != null) confirmAction(action, "Solicitação recebida por deep link: " + data.toString());
                else appendOutput("Sistema", "Deep link recebido, mas a ação não é suportada.");
            }
            return;
        }

        if (Intent.ACTION_SEND.equals(intent.getAction()) && "text/plain".equals(intent.getType())) {
            String text = intent.getStringExtra(Intent.EXTRA_TEXT);
            if (text != null && !text.trim().isEmpty()) processIncomingText(text, "Texto compartilhado para o AgentO Mobile.");
        }
    }

    private void pasteFromClipboard() {
        ClipboardManager clipboard = (ClipboardManager)getSystemService(CLIPBOARD_SERVICE);
        if (clipboard == null || !clipboard.hasPrimaryClip() || clipboard.getPrimaryClip() == null || clipboard.getPrimaryClip().getItemCount() == 0) {
            Toast.makeText(this, "A área de transferência está vazia.", Toast.LENGTH_LONG).show();
            return;
        }
        CharSequence text = clipboard.getPrimaryClip().getItemAt(0).coerceToText(this);
        if (text == null || text.toString().trim().isEmpty()) {
            Toast.makeText(this, "Não encontrei texto para interpretar.", Toast.LENGTH_LONG).show();
            return;
        }
        processIncomingText(text.toString(), "Texto colado da área de transferência.");
    }

    private void processIncomingText(String text, String source) {
        String action = inferAction(text);
        if (action == null) {
            appendOutput("Sistema", "Não consegui identificar uma ação permitida no texto. Use um dos comandos: AGENTO:battery, AGENTO:device, AGENTO:storage, AGENTO:network ou AGENTO:status.");
            return;
        }
        confirmAction(action, source + "\n\n" + text);
    }

    private String inferAction(String text) {
        if (text == null) return null;
        String trimmed = text.trim();

        if (trimmed.startsWith("{")) {
            try {
                JSONObject obj = new JSONObject(trimmed);
                String action = canonicalAction(obj.optString("action", null));
                if (action != null) return action;
            } catch (Exception ignored) {}
        }

        String normalized = normalize(trimmed);
        int marker = normalized.indexOf("agento:");
        if (marker >= 0) {
            String tail = normalized.substring(marker + 7).trim();
            int end = 0;
            while (end < tail.length()) {
                char c = tail.charAt(end);
                if (!(Character.isLetterOrDigit(c) || c == '_' || c == '-')) break;
                end++;
            }
            if (end > 0) {
                String action = canonicalAction(tail.substring(0, end));
                if (action != null) return action;
            }
        }

        if (normalized.contains("bateria") || normalized.contains("battery")) return "battery";
        if (normalized.contains("armazenamento") || normalized.contains("storage") || normalized.contains("espaco livre")) return "storage";
        if (normalized.contains("wifi") || normalized.contains("wi-fi") || normalized.contains("rede") || normalized.contains("network")) return "network";
        if (normalized.contains("dispositivo") || normalized.contains("device") || normalized.contains("informacoes do celular") || normalized.contains("informacao do celular")) return "device";
        if (normalized.contains("termux") || normalized.contains("status")) return "status";
        return null;
    }

    private String canonicalAction(String value) {
        if (value == null) return null;
        String v = normalize(value).trim();
        if (v.equals("battery") || v.equals("bateria")) return "battery";
        if (v.equals("device") || v.equals("dispositivo") || v.equals("celular")) return "device";
        if (v.equals("storage") || v.equals("armazenamento") || v.equals("espaco")) return "storage";
        if (v.equals("network") || v.equals("rede") || v.equals("wifi") || v.equals("wi-fi")) return "network";
        if (v.equals("status") || v.equals("termux")) return "status";
        return null;
    }

    private String normalize(String value) {
        String n = Normalizer.normalize(value == null ? "" : value, Normalizer.Form.NFD);
        n = n.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
        return n.toLowerCase(Locale.ROOT);
    }

    private void confirmAction(String action, String requestText) {
        originalRequest = requestText == null ? "" : requestText.trim();
        String description = friendlyAction(action);
        new AlertDialog.Builder(this)
                .setTitle("Autorizar ação no celular")
                .setMessage("Solicitação: " + description + "\n\nEsta versão executa apenas consultas de leitura previamente permitidas. Deseja executar agora?")
                .setNegativeButton("Cancelar", null)
                .setPositiveButton("Executar", (dialog, which) -> executeAction(action))
                .show();
    }

    private void executeAction(String action) {
        String cmd;
        switch (action) {
            case "battery":
                cmd = "if command -v termux-battery-status >/dev/null 2>&1; then termux-battery-status; else echo 'termux-battery-status não encontrado. Instale Termux:API e pkg install termux-api.'; exit 2; fi";
                break;
            case "device":
                cmd = "echo '=== DISPOSITIVO ==='; " +
                        "echo 'Fabricante:' $(getprop ro.product.manufacturer); " +
                        "echo 'Marca:' $(getprop ro.product.brand); " +
                        "echo 'Modelo:' $(getprop ro.product.model); " +
                        "echo 'Android:' $(getprop ro.build.version.release); " +
                        "echo 'SDK:' $(getprop ro.build.version.sdk); " +
                        "echo 'Arquitetura:' $(getprop ro.product.cpu.abi); " +
                        "echo; uname -a";
                break;
            case "storage":
                cmd = "echo '=== ARMAZENAMENTO ==='; df -h \"$HOME\" 2>/dev/null; " +
                        "if [ -d /sdcard ]; then echo; echo 'Armazenamento compartilhado:'; df -h /sdcard 2>/dev/null || true; fi";
                break;
            case "network":
                cmd = "echo '=== REDE ==='; " +
                        "if command -v termux-wifi-connectioninfo >/dev/null 2>&1; then termux-wifi-connectioninfo; " +
                        "else echo 'Termux:API Wi-Fi não disponível; exibindo interfaces:'; ip -brief addr 2>/dev/null || ip addr; fi";
                break;
            case "status":
                cmd = "echo '=== AGENTO / TERMUX ==='; date; echo; echo 'Usuário:'; whoami; echo 'Diretório:'; pwd; echo; uname -a; echo; command -v termux-battery-status >/dev/null 2>&1 && echo 'Termux:API: OK' || echo 'Termux:API: não detectado'";
                break;
            default:
                appendOutput("Sistema", "Ação bloqueada: " + action);
                return;
        }

        if (Build.VERSION.SDK_INT >= 23 && checkSelfPermission(TERMUX_PERMISSION) != PackageManager.PERMISSION_GRANTED) {
            pendingAction = action;
            statusView.setText("Conceda a permissão para o AgentO executar comandos no Termux.");
            requestTermuxPermissionIfNeeded();
            return;
        }

        statusView.setText("Executando: " + friendlyAction(action) + "...");
        runTermuxShell(cmd, action, "AgentO Connector — " + action);
    }

    private void runTermuxShell(String command, String purpose, String label) {
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
            appendOutput("Sistema", e.toString());
        } catch (Exception e) {
            statusView.setText("Não foi possível chamar o Termux.");
            appendOutput("Sistema", e.toString());
        }
    }

    private void shareResultToChatGPT() {
        if (lastResult == null || lastResult.trim().isEmpty()) {
            Toast.makeText(this, "Execute uma consulta primeiro.", Toast.LENGTH_LONG).show();
            return;
        }

        StringBuilder payload = new StringBuilder();
        payload.append("AGENTO MOBILE — RESULTADO DO CELULAR\n");
        payload.append("Ação: ").append(lastAction).append("\n\n");
        if (!originalRequest.isEmpty()) {
            payload.append("Solicitação original recebida pelo AgentO:\n").append(originalRequest).append("\n\n");
        }
        payload.append("Resultado real obtido no aparelho:\n").append(lastResult).append("\n\n");
        payload.append("Interprete este resultado e responda à minha solicitação. Não invente dados que não estejam acima.");

        Intent send = new Intent(Intent.ACTION_SEND);
        send.setType("text/plain");
        send.putExtra(Intent.EXTRA_TEXT, payload.toString());

        Intent direct = new Intent(send);
        direct.setPackage("com.openai.chatgpt");
        if (direct.resolveActivity(getPackageManager()) != null) {
            startActivity(direct);
        } else {
            startActivity(Intent.createChooser(send, "Compartilhar resultado"));
        }
    }

    private void openChatGPT() {
        Intent launch = getPackageManager().getLaunchIntentForPackage("com.openai.chatgpt");
        if (launch != null) {
            startActivity(launch);
            return;
        }
        try {
            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://chatgpt.com/")));
        } catch (Exception e) {
            Toast.makeText(this, "Não foi possível abrir o ChatGPT.", Toast.LENGTH_LONG).show();
        }
    }

    private void openTermux() {
        Intent launch = getPackageManager().getLaunchIntentForPackage("com.termux");
        if (launch != null) startActivity(launch);
        else Toast.makeText(this, "Termux não encontrado.", Toast.LENGTH_LONG).show();
    }

    private void copyExamples() {
        String examples = "AGENTO:battery\nAGENTO:device\nAGENTO:storage\nAGENTO:network\nAGENTO:status\n\nDeep link:\nagentomobile://run?action=battery";
        ClipboardManager clipboard = (ClipboardManager)getSystemService(CLIPBOARD_SERVICE);
        if (clipboard != null) {
            clipboard.setPrimaryClip(ClipData.newPlainText("AgentO Mobile commands", examples));
            Toast.makeText(this, "Exemplos copiados.", Toast.LENGTH_LONG).show();
        }
    }

    private void requestTermuxPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= 23 && checkSelfPermission(TERMUX_PERMISSION) != PackageManager.PERMISSION_GRANTED) {
            try { requestPermissions(new String[]{TERMUX_PERMISSION}, REQ_TERMUX_PERMISSION); }
            catch (Exception e) { statusView.setText("Conceda manualmente a permissão adicional do Termux."); }
        }
    }

    private String friendlyAction(String action) {
        if (action == null) return "ação";
        switch (action) {
            case "battery": return "Consultar bateria";
            case "device": return "Consultar informações do dispositivo";
            case "storage": return "Consultar armazenamento";
            case "network": return "Consultar rede / Wi-Fi";
            case "status": return "Consultar status do Termux";
            default: return action;
        }
    }

    private void appendOutput(String who, String text) {
        if (text == null || text.trim().isEmpty()) return;
        String old = outputView.getText().toString();
        String block = who + ":\n" + text.trim();
        outputView.setText(old.isEmpty() ? block : old + "\n\n" + block);
        outputScroll.post(() -> outputScroll.fullScroll(View.FOCUS_DOWN));
    }

    private Button button(String text) {
        Button b = new Button(this);
        b.setText(text);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.topMargin = dp(6);
        b.setLayoutParams(lp);
        return b;
    }

    private Button smallButton(String text) {
        Button b = new Button(this);
        b.setText(text);
        b.setTextSize(12);
        b.setAllCaps(false);
        return b;
    }

    private LinearLayout horizontalRow() {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(0, dp(4), 0, 0);
        return row;
    }

    private LinearLayout.LayoutParams weightedButtonParams() {
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f);
        lp.setMargins(dp(2), 0, dp(2), 0);
        return lp;
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
