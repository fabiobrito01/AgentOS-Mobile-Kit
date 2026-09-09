package br.com.agentostudio.mobiletermux;

import android.app.IntentService;
import android.content.Intent;
import android.os.Bundle;

public class PluginResultsService extends IntentService {
    public static final String ACTION_RESULT = "br.com.agentostudio.mobiletermux.RESULT";
    public static final String EXTRA_DISPLAY_RESULT = "display_result";
    public static final String EXTRA_EXECUTION_ID = "execution_id";
    private static int executionId = 1000;

    public PluginResultsService() { super("AgentOTermuxResults"); }

    @Override protected void onHandleIntent(Intent intent) {
        if (intent == null) return;
        Bundle result = intent.getBundleExtra("result");
        String display;
        if (result == null) {
            display = "O Termux retornou sem o bundle de resultado.";
        } else {
            String stdout = result.getString("stdout", "");
            String stderr = result.getString("stderr", "");
            String errmsg = result.getString("errmsg", "");
            int exitCode = result.getInt("exitCode", -999);
            int err = result.getInt("err", -999);
            int id = intent.getIntExtra(EXTRA_EXECUTION_ID, 0);
            StringBuilder sb = new StringBuilder();
            sb.append("Execução #").append(id).append("\n");
            sb.append("exitCode: ").append(exitCode).append(" | err: ").append(err).append("\n\n");
            if (!stdout.isEmpty()) sb.append("STDOUT\n").append(stdout).append("\n");
            if (!stderr.isEmpty()) sb.append("\nSTDERR\n").append(stderr).append("\n");
            if (!errmsg.isEmpty()) sb.append("\nERRO INTERNO\n").append(errmsg).append("\n");
            if (stdout.isEmpty() && stderr.isEmpty() && errmsg.isEmpty()) sb.append("Sem texto de retorno.");
            display = sb.toString();
        }
        Intent broadcast = new Intent(ACTION_RESULT);
        broadcast.setPackage(getPackageName());
        broadcast.putExtra(EXTRA_DISPLAY_RESULT, display);
        sendBroadcast(broadcast);
    }

    public static synchronized int getNextExecutionId() { return executionId++; }
}
