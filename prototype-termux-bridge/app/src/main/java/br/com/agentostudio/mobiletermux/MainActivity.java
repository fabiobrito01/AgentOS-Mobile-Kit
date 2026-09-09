package br.com.agentostudio.mobiletermux;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.graphics.Typeface;
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

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

public class MainActivity extends Activity {
    private static final String TERMUX_PERMISSION = "com.termux.permission.RUN_COMMAND";
    private static final int REQ_TERMUX_PERMISSION = 1001;
    private static final String HOME = "/data/data/com.termux/files/home";
    private static final String BASH = "/data/data/com.termux/files/usr/bin/bash";

    private TextView statusView;
    private TextView chatView;
    private EditText messageInput;
    private ScrollView chatScroll;
    private Button sendButton;

    private final BroadcastReceiver resultReceiver = new BroadcastReceiver() {
        @Override public void onReceive(Context context, Intent intent) {
            if (!PluginResultsService.ACTION_RESULT.equals(intent.getAction())) return;

            String purpose = intent.getStringExtra(PluginResultsService.EXTRA_PURPOSE);
            String stdout = intent.getStringExtra(PluginResultsService.EXTRA_STDOUT);
            String stderr = intent.getStringExtra(PluginResultsService.EXTRA_STDERR);
            int exitCode = intent.getIntExtra(PluginResultsService.EXTRA_EXIT_CODE, -999);

            if (stdout == null) stdout = "";
            if (stderr == null) stderr = "";

            if ("chat".equals(purpose)) {
                sendButton.setEnabled(true);
                if (!stdout.trim().isEmpty()) {
                    appendChat("AgentO", stdout.trim());
                    statusView.setText(exitCode == 0 ? "IA conectada ao Termux." : "A IA retornou um erro.");
                } else {
                    appendChat("Sistema", "Não houve resposta. " + stderr.trim());
                    statusView.setText("Falha na resposta da IA.");
                }
                return;
            }

            if ("install".equals(purpose)) {
                statusView.setText(exitCode == 0 ? "Núcleo IA instalado no Termux." : "Falha ao instalar o núcleo IA.");
                appendChat("Sistema", stdout.trim().isEmpty() ? stderr.trim() : stdout.trim());
                return;
            }

            if ("api_key".equals(purpose)) {
                statusView.setText(exitCode == 0 ? "Chave da OpenAI configurada no Termux." : "Falha ao salvar a chave.");
                Toast.makeText(MainActivity.this, exitCode == 0 ? "OpenAI configurada." : "Não foi possível salvar a chave.", Toast.LENGTH_LONG).show();
                return;
            }

            if ("model".equals(purpose)) {
                statusView.setText(exitCode == 0 ? "Modelo de IA atualizado." : "Falha ao alterar o modelo.");
                Toast.makeText(MainActivity.this, stdout.trim().isEmpty() ? "Modelo atualizado." : stdout.trim(), Toast.LENGTH_LONG).show();
                return;
            }

            if ("reset".equals(purpose)) {
                statusView.setText("Conversa da IA reiniciada.");
                appendChat("Sistema", stdout.trim().isEmpty() ? "Contexto da conversa reiniciado." : stdout.trim());
                return;
            }

            if ("diagnostic".equals(purpose)) {
                statusView.setText(exitCode == 0 ? "Diagnóstico concluído." : "Diagnóstico encontrou problema.");
                appendChat("Diagnóstico", stdout.trim().isEmpty() ? stderr.trim() : stdout.trim());
                return;
            }

            statusView.setText(exitCode == 0 ? "Comando concluído." : "Comando terminou com erro.");
            if (!stdout.trim().isEmpty() || !stderr.trim().isEmpty()) {
                appendChat("Terminal", (stdout + (stderr.isEmpty() ? "" : "\n" + stderr)).trim());
            }
        }
    };

    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(buildUi());
        requestTermuxPermissionIfNeeded();
        appendChat("AgentO", "v0.2 pronta. Instale o Núcleo IA, configure sua chave da OpenAI e depois converse comigo normalmente.");
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

    private View buildUi() {
        int pad = dp(16);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(pad, pad, pad, pad);

        TextView title = new TextView(this);
        title.setText("AgentO Mobile Agent");
        title.setTextSize(25);
        title.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        root.addView(title);

        TextView subtitle = new TextView(this);
        subtitle.setText("v0.2.0 · ChatGPT + Termux + ferramentas do Android");
        subtitle.setTextSize(14);
        subtitle.setPadding(0, dp(4), 0, dp(10));
        root.addView(subtitle);

        statusView = new TextView(this);
        statusView.setText("Termux Bridge: aguardando configuração da IA.");
        statusView.setTextSize(15);
        statusView.setPadding(0, 0, 0, dp(10));
        root.addView(statusView);

        chatScroll = new ScrollView(this);
        chatView = new TextView(this);
        chatView.setTextSize(16);
        chatView.setTextIsSelectable(true);
        chatView.setPadding(dp(12), dp(12), dp(12), dp(12));
        chatScroll.addView(chatView);
        LinearLayout.LayoutParams chatLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f);
        root.addView(chatScroll, chatLp);

        messageInput = new EditText(this);
        messageInput.setHint("Ex.: Como está a bateria do meu celular?");
        messageInput.setMinLines(2);
        messageInput.setMaxLines(5);
        messageInput.setGravity(Gravity.TOP);
        messageInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_MULTI_LINE | InputType.TYPE_TEXT_FLAG_CAP_SENTENCES);
        root.addView(messageInput, new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT));

        sendButton = button("ENVIAR PARA A IA");
        sendButton.setOnClickListener(v -> sendChat());
        root.addView(sendButton);

        LinearLayout actions1 = horizontalRow();
        Button install = smallButton("INSTALAR NÚCLEO IA");
        install.setOnClickListener(v -> installAgentCore());
        actions1.addView(install, weightedButtonParams());
        Button key = smallButton("CONFIGURAR OPENAI");
        key.setOnClickListener(v -> showApiKeyDialog());
        actions1.addView(key, weightedButtonParams());
        root.addView(actions1);

        LinearLayout actions2 = horizontalRow();
        Button model = smallButton("MODELO IA");
        model.setOnClickListener(v -> showModelDialog());
        actions2.addView(model, weightedButtonParams());
        Button diagnostic = smallButton("DIAGNÓSTICO");
        diagnostic.setOnClickListener(v -> runAgent("--diagnostic", null, "diagnostic"));
        actions2.addView(diagnostic, weightedButtonParams());
        root.addView(actions2);

        LinearLayout actions3 = horizontalRow();
        Button reset = smallButton("RESETAR CONVERSA");
        reset.setOnClickListener(v -> runAgent("--reset", null, "reset"));
        actions3.addView(reset, weightedButtonParams());
        Button termux = smallButton("ABRIR TERMUX");
        termux.setOnClickListener(v -> openTermux());
        actions3.addView(termux, weightedButtonParams());
        root.addView(actions3);

        TextView note = new TextView(this);
        note.setText("Nesta v0.2 a IA possui ferramentas somente de leitura: bateria, dispositivo, armazenamento e rede. Nenhuma chave OpenAI fica embutida no APK.");
        note.setTextSize(12);
        note.setPadding(0, dp(8), 0, 0);
        root.addView(note);

        return root;
    }

    private LinearLayout horizontalRow() {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setPadding(0, dp(4), 0, 0);
        return row;
    }

    private LinearLayout.LayoutParams weightedButtonParams() {
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f);
        lp.setMargins(dp(2), 0, dp(2), 0);
        return lp;
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
        b.setTextSize(11);
        b.setAllCaps(false);
        return b;
    }

    private void appendChat(String who, String text) {
        if (text == null || text.trim().isEmpty()) return;
        String old = chatView.getText().toString();
        String block = who + ":\n" + text.trim();
        chatView.setText(old.isEmpty() ? block : old + "\n\n" + block);
        chatScroll.post(() -> chatScroll.fullScroll(View.FOCUS_DOWN));
    }

    private void sendChat() {
        String message = messageInput.getText().toString().trim();
        if (message.isEmpty()) {
            Toast.makeText(this, "Digite uma mensagem.", Toast.LENGTH_SHORT).show();
            return;
        }
        appendChat("Você", message);
        messageInput.setText("");
        sendButton.setEnabled(false);
        statusView.setText("AgentO está pensando e consultando ferramentas quando necessário...");
        runAgent("--chat-stdin", message, "chat");
    }

    private void installAgentCore() {
        String script = readRawResource(R.raw.agent_core);
        if (script.isEmpty()) {
            appendChat("Sistema", "Não foi possível ler o núcleo IA embutido no APK.");
            return;
        }
        statusView.setText("Instalando Núcleo IA e Python no Termux...");
        String cmd = "mkdir -p \"$HOME/.agentomobile\"; " +
                "cat > \"$HOME/.agentomobile/agent_core.py\"; " +
                "chmod 700 \"$HOME/.agentomobile/agent_core.py\"; " +
                "if ! command -v python >/dev/null 2>&1; then pkg install -y python; fi; " +
                "python \"$HOME/.agentomobile/agent_core.py\" --self-test";
        runTermuxShell(cmd, script, "install", "Instalar AgentO Core");
    }

    private void showApiKeyDialog() {
        final EditText input = new EditText(this);
        input.setHint("sk-...");
        input.setSingleLine(true);
        input.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);

        new AlertDialog.Builder(this)
                .setTitle("Configurar OpenAI")
                .setMessage("Cole uma chave da OpenAI API. Ela será enviada diretamente ao Termux via stdin e salva em ~/.agentomobile/openai_api_key com permissão privada. A assinatura do ChatGPT e a API são faturamentos separados.")
                .setView(input)
                .setNegativeButton("Cancelar", null)
                .setPositiveButton("Salvar", (dialog, which) -> {
                    String key = input.getText().toString().trim();
                    if (key.isEmpty()) {
                        Toast.makeText(MainActivity.this, "Chave vazia.", Toast.LENGTH_LONG).show();
                        return;
                    }
                    String cmd = "umask 077; mkdir -p \"$HOME/.agentomobile\"; " +
                            "cat > \"$HOME/.agentomobile/openai_api_key\"; " +
                            "chmod 600 \"$HOME/.agentomobile/openai_api_key\"; " +
                            "echo 'Chave OpenAI salva com segurança no Termux.'";
                    runTermuxShell(cmd, key, "api_key", "Configurar OpenAI");
                })
                .show();
    }

    private void showModelDialog() {
        String[] options = {
                "GPT-5.6 Luna — econômico para testes",
                "GPT-5.6 Sol — mais capaz"
        };
        new AlertDialog.Builder(this)
                .setTitle("Modelo da IA")
                .setItems(options, (dialog, which) -> {
                    String model = which == 1 ? "gpt-5.6-sol" : "gpt-5.6-luna";
                    String cmd = "umask 077; mkdir -p \"$HOME/.agentomobile\"; " +
                            "cat > \"$HOME/.agentomobile/model\"; chmod 600 \"$HOME/.agentomobile/model\"; " +
                            "echo 'Modelo configurado: " + model + "'";
                    runTermuxShell(cmd, model, "model", "Configurar modelo");
                })
                .show();
    }

    private void runAgent(String arg, String stdin, String purpose) {
        String cmd = "if [ ! -f \"$HOME/.agentomobile/agent_core.py\" ]; then " +
                "echo 'Núcleo IA não instalado. Toque em INSTALAR NÚCLEO IA.'; exit 2; fi; " +
                "if ! command -v python >/dev/null 2>&1; then echo 'Python não instalado no Termux.'; exit 3; fi; " +
                "python \"$HOME/.agentomobile/agent_core.py\" " + arg;
        runTermuxShell(cmd, stdin, purpose, "AgentO " + purpose);
    }

    private void runTermuxShell(String command, String stdin, String purpose, String label) {
        if (Build.VERSION.SDK_INT >= 23 && checkSelfPermission(TERMUX_PERMISSION) != PackageManager.PERMISSION_GRANTED) {
            statusView.setText("Permissão RUN_COMMAND não concedida.");
            requestTermuxPermissionIfNeeded();
            if ("chat".equals(purpose)) sendButton.setEnabled(true);
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
        if (stdin != null) intent.putExtra("com.termux.RUN_COMMAND_STDIN", stdin);

        try {
            startService(intent);
        } catch (SecurityException e) {
            statusView.setText("Acesso ao Termux negado. Verifique RUN_COMMAND e allow-external-apps=true.");
            appendChat("Sistema", e.toString());
            if ("chat".equals(purpose)) sendButton.setEnabled(true);
        } catch (Exception e) {
            statusView.setText("Não foi possível chamar o Termux.");
            appendChat("Sistema", e.toString());
            if ("chat".equals(purpose)) sendButton.setEnabled(true);
        }
    }

    private String readRawResource(int resourceId) {
        StringBuilder sb = new StringBuilder();
        try {
            InputStream in = getResources().openRawResource(resourceId);
            BufferedReader reader = new BufferedReader(new InputStreamReader(in));
            String line;
            while ((line = reader.readLine()) != null) sb.append(line).append('\n');
            reader.close();
        } catch (Exception e) {
            return "";
        }
        return sb.toString();
    }

    private void requestTermuxPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= 23 && checkSelfPermission(TERMUX_PERMISSION) != PackageManager.PERMISSION_GRANTED) {
            try { requestPermissions(new String[]{TERMUX_PERMISSION}, REQ_TERMUX_PERMISSION); }
            catch (Exception e) { statusView.setText("Conceda manualmente a permissão adicional do Termux."); }
        }
    }

    private void openTermux() {
        Intent launch = getPackageManager().getLaunchIntentForPackage("com.termux");
        if (launch != null) startActivity(launch);
        else Toast.makeText(this, "Termux não encontrado.", Toast.LENGTH_LONG).show();
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
