package br.com.agentostudio.mobiletermux;

import android.app.IntentService;
import android.content.Intent;
import android.os.Bundle;

public class PluginResultsService extends IntentService {
    public static final String ACTION_RESULT = "br.com.agentostudio.mobiletermux.RESULT";
    public static final String EXTRA_DISPLAY_RESULT = "display_result";
    public static final String EXTRA_EXECUTION_ID = "execution_id";
    public static final String EXTRA_PURPOSE = "purpose";
    public static final String EXTRA_STDOUT = "stdout";
    public static final String EXTRA_STDERR = "stderr";
    public static final String EXTRA_EXIT_CODE = "exit_code";
    public static final String EXTRA_ERR = "err";
    private static int executionId = 2000;

    public PluginResultsService() {
        super("AgentOTermuxResults");
    }

    @Override protected void onHandleIntent(Intent intent) {
        if (intent == null) return;

        String purpose = intent.getStringExtra(EXTRA_PURPOSE);
        Bundle result = intent.getBundleExtra("result");
        String stdout = "";
        String stderr = "";
        String errmsg = "";
        int exitCode = -999;
        int err = -999;

        if (result != null) {
            stdout = result.getString("stdout", "");
            stderr = result.getString("stderr", "");
            errmsg = result.getString("errmsg", "");
            exitCode = result.getInt("exitCode", -999);
            err = result.getInt("err", -999);
        } else {
            stderr = "O Termux retornou sem o bundle de resultado.";
        }

        if (!errmsg.isEmpty()) {
            stderr = stderr.isEmpty() ? errmsg : stderr + "\n" + errmsg;
        }

        int id = intent.getIntExtra(EXTRA_EXECUTION_ID, 0);
        StringBuilder display = new StringBuilder();
        display.append("Execução #").append(id).append("\n");
        display.append("exitCode: ").append(exitCode).append(" | err: ").append(err).append("\n\n");
        if (!stdout.isEmpty()) display.append("STDOUT\n").append(stdout).append("\n");
        if (!stderr.isEmpty()) display.append("\nSTDERR\n").append(stderr).append("\n");

        Intent broadcast = new Intent(ACTION_RESULT);
        broadcast.setPackage(getPackageName());
        broadcast.putExtra(EXTRA_PURPOSE, purpose);
        broadcast.putExtra(EXTRA_STDOUT, stdout);
        broadcast.putExtra(EXTRA_STDERR, stderr);
        broadcast.putExtra(EXTRA_EXIT_CODE, exitCode);
        broadcast.putExtra(EXTRA_ERR, err);
        broadcast.putExtra(EXTRA_DISPLAY_RESULT, display.toString());
        sendBroadcast(broadcast);
    }

    public static synchronized int getNextExecutionId() {
        return executionId++;
    }
}
