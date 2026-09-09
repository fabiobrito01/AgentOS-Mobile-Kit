package br.com.agentostudio.mobiletermux;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
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
    private EditText commandInput;
    private TextView statusView;
    private TextView outputView;

    private final BroadcastReceiver resultReceiver = new BroadcastReceiver() {
        @Override public void onReceive(Context context, Intent intent) {
            if (!PluginResultsService.ACTION_RESULT.equals(intent.getAction())) return;
            String output = intent.getStringExtra(PluginResultsService.EXTRA_DISPLAY_RESULT);
            outputView.setText(output == null ? "Sem retorno." : output);
            statusView.setText("Retorno recebido do Termux.");
        }
    };

    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(buildUi());
        requestTermuxPermissionIfNeeded();
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
        ScrollView scroll = new ScrollView(this);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(pad, pad, pad, pad);
        scroll.addView(root);

        TextView title = new TextView(this);
        title.setText("AgentO Mobile · Termux Bridge");
        title.setTextSize(24);
        title.setPadding(0, 0, 0, dp(8));
        root.addView(title);

        TextView subtitle = new TextView(this);
        subtitle.setText("Protótipo v0.1.0 — APK ↔ Termux com retorno de stdout/stderr");
        subtitle.setTextSize(14);
        subtitle.setPadding(0, 0, 0, dp(16));
        root.addView(subtitle);

        statusView = new TextView(this);
        statusView.setText("Status: pronto para configurar.");
        statusView.setTextSize(15);
        statusView.setPadding(0, 0, 0, dp(12));
        root.addView(statusView);

        commandInput = new EditText(this);
        commandInput.setHint("Digite um comando para executar no Termux");
        commandInput.setText("echo 'AgentO Mobile conectado ao Termux'; echo; whoami; pwd; uname -a");
        commandInput.setMinLines(4);
        commandInput.setGravity(Gravity.TOP);
        commandInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_MULTI_LINE);
        root.addView(commandInput, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));

        Button execute = button("Executar no Termux");
        execute.setOnClickListener(v -> runCommand(commandInput.getText().toString()));
        root.addView(execute);

        Button quickTest = button("Teste rápido da ponte");
        quickTest.setOnClickListener(v -> {
            String cmd = "echo '=== AGENTO MOBILE BRIDGE ==='; date; echo; echo 'Usuario:'; whoami; echo; echo 'Diretorio:'; pwd; echo; echo 'Sistema:'; uname -a";
            commandInput.setText(cmd);
            runCommand(cmd);
        });
        root.addView(quickTest);

        Button batteryTest = button("Teste de bateria (Termux:API)");
        batteryTest.setOnClickListener(v -> {
            String cmd = "if command -v termux-battery-status >/dev/null 2>&1; then termux-battery-status; else echo 'termux-battery-status nao encontrado. Instale Termux:API e execute: pkg install termux-api'; fi";
            commandInput.setText(cmd);
            runCommand(cmd);
        });
        root.addView(batteryTest);

        Button openTermux = button("Abrir Termux");
        openTermux.setOnClickListener(v -> openTermux());
        root.addView(openTermux);

        Button copySetup = button("Copiar configuração do Termux");
        copySetup.setOnClickListener(v -> copySetupCommand());
        root.addView(copySetup);

        Button appSettings = button("Abrir permissões deste APK");
        appSettings.setOnClickListener(v -> openAppSettings());
        root.addView(appSettings);

        TextView outLabel = new TextView(this);
        outLabel.setText("\nRetorno do Termux:");
        outLabel.setTextSize(18);
        root.addView(outLabel);

        outputView = new TextView(this);
        outputView.setText("Nenhum comando executado ainda.");
        outputView.setTextSize(14);
        outputView.setTextIsSelectable(true);
        outputView.setPadding(dp(10), dp(10), dp(10), dp(24));
        root.addView(outputView);

        TextView help = new TextView(this);
        help.setText("Primeira configuração:\n1) Toque em 'Copiar configuração do Termux', abra o Termux e cole.\n2) Nas permissões adicionais deste APK, permita executar comandos no Termux.\n3) Volte e toque em 'Teste rápido da ponte'.");
        help.setTextSize(14);
        root.addView(help);
        return scroll;
    }

    private Button button(String text) {
        Button b = new Button(this);
        b.setText(text);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.topMargin = dp(8);
        b.setLayoutParams(lp);
        return b;
    }

    private void requestTermuxPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= 23 && checkSelfPermission(TERMUX_PERMISSION) != PackageManager.PERMISSION_GRANTED) {
            try { requestPermissions(new String[]{TERMUX_PERMISSION}, REQ_TERMUX_PERMISSION); }
            catch (Exception e) { statusView.setText("Conceda manualmente a permissão adicional do Termux."); }
        }
    }

    private void runCommand(String command) {
        if (command == null || command.trim().isEmpty()) {
            Toast.makeText(this, "Digite um comando.", Toast.LENGTH_SHORT).show();
            return;
        }
        if (Build.VERSION.SDK_INT >= 23 && checkSelfPermission(TERMUX_PERMISSION) != PackageManager.PERMISSION_GRANTED) {
            statusView.setText("Permissão RUN_COMMAND não concedida.");
            requestTermuxPermissionIfNeeded();
            return;
        }

        int executionId = PluginResultsService.getNextExecutionId();
        Intent resultIntent = new Intent(this, PluginResultsService.class);
        resultIntent.putExtra(PluginResultsService.EXTRA_EXECUTION_ID, executionId);
        int flags = PendingIntent.FLAG_ONE_SHOT;
        if (Build.VERSION.SDK_INT >= 31) flags |= PendingIntent.FLAG_MUTABLE;
        PendingIntent pendingIntent = PendingIntent.getService(this, executionId, resultIntent, flags);

        Intent intent = new Intent();
        intent.setClassName("com.termux", "com.termux.app.RunCommandService");
        intent.setAction("com.termux.RUN_COMMAND");
        intent.putExtra("com.termux.RUN_COMMAND_PATH", "/data/data/com.termux/files/usr/bin/bash");
        intent.putExtra("com.termux.RUN_COMMAND_ARGUMENTS", new String[]{"-lc", command});
        intent.putExtra("com.termux.RUN_COMMAND_WORKDIR", "/data/data/com.termux/files/home");
        intent.putExtra("com.termux.RUN_COMMAND_BACKGROUND", true);
        intent.putExtra("com.termux.RUN_COMMAND_COMMAND_LABEL", "AgentO Mobile");
        intent.putExtra("com.termux.RUN_COMMAND_PENDING_INTENT", pendingIntent);

        try {
            statusView.setText("Executando no Termux...");
            outputView.setText("Aguardando retorno...");
            startService(intent);
        } catch (SecurityException e) {
            statusView.setText("Acesso negado. Ative allow-external-apps=true e conceda RUN_COMMAND.");
            outputView.setText(e.toString());
        } catch (Exception e) {
            statusView.setText("Não foi possível chamar o Termux.");
            outputView.setText(e.toString());
        }
    }

    private void openTermux() {
        Intent launch = getPackageManager().getLaunchIntentForPackage("com.termux");
        if (launch != null) startActivity(launch);
        else Toast.makeText(this, "Termux não encontrado.", Toast.LENGTH_LONG).show();
    }

    private void copySetupCommand() {
        String setup = "mkdir -p ~/.termux; if grep -q '^allow-external-apps=' ~/.termux/termux.properties 2>/dev/null; then sed -i 's/^allow-external-apps=.*/allow-external-apps=true/' ~/.termux/termux.properties; else echo 'allow-external-apps=true' >> ~/.termux/termux.properties; fi; termux-reload-settings; echo 'OK: allow-external-apps=true'";
        ClipboardManager clipboard = (ClipboardManager)getSystemService(CLIPBOARD_SERVICE);
        clipboard.setPrimaryClip(ClipData.newPlainText("AgentO Termux setup", setup));
        Toast.makeText(this, "Comando copiado. Abra o Termux e cole.", Toast.LENGTH_LONG).show();
    }

    private void openAppSettings() {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:" + getPackageName()));
        startActivity(intent);
    }

    private int dp(int value) { return Math.round(value * getResources().getDisplayMetrics().density); }
}
