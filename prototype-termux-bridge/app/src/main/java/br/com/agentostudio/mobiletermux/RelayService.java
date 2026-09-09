package br.com.agentostudio.mobiletermux;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.IBinder;

public class RelayService extends Service {
    public static final String ACTION_INCOMING = "br.com.agentostudio.mobiletermux.RELAY_COMMAND";
    public static final String EXTRA_REQUEST_ID = "relay_request_id";
    public static final String EXTRA_ACTION = "relay_action";
    private static final String CHANNEL_ID = "agentomobile_relay";
    private static final int NOTIFICATION_ID = 4304;

    private volatile boolean running;
    private Thread loopThread;

    @Override public void onCreate() {
        super.onCreate();
        createChannel();
        startForeground(NOTIFICATION_ID, notification("Relay conectado", "Aguardando solicitações do ChatGPT."));
    }

    @Override public int onStartCommand(Intent intent, int flags, int startId) {
        running = true;
        if (loopThread == null || !loopThread.isAlive()) {
            loopThread = new Thread(this::pollLoop, "AgentOMobileRelay");
            loopThread.start();
        }
        return START_STICKY;
    }

    private void pollLoop() {
        while (running) {
            SharedPreferences p = RelayHttp.prefs(this);
            if (!p.getBoolean(RelayHttp.KEY_ENABLED, false)) break;
            try {
                String pendingId = p.getString(RelayHttp.KEY_PENDING_ID, "");
                if (pendingId == null || pendingId.trim().isEmpty()) {
                    RelayHttp.RelayCommand cmd = RelayHttp.pull(this);
                    if (cmd != null) {
                        p.edit()
                                .putString(RelayHttp.KEY_PENDING_ID, cmd.id)
                                .putString(RelayHttp.KEY_PENDING_ACTION, cmd.action)
                                .apply();
                        announceCommand(cmd.id, cmd.action);
                    }
                }
            } catch (Exception e) {
                updateNotification("Relay aguardando conexão", shortMessage(e));
            }

            try { Thread.sleep(4000); }
            catch (InterruptedException e) { Thread.currentThread().interrupt(); break; }
        }
        running = false;
        stopSelf();
    }

    private void announceCommand(String requestId, String action) {
        Intent broadcast = new Intent(ACTION_INCOMING);
        broadcast.setPackage(getPackageName());
        broadcast.putExtra(EXTRA_REQUEST_ID, requestId);
        broadcast.putExtra(EXTRA_ACTION, action);
        sendBroadcast(broadcast);

        Intent open = new Intent(this, MainActivity.class);
        open.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        open.putExtra(EXTRA_REQUEST_ID, requestId);
        open.putExtra(EXTRA_ACTION, action);
        int piFlags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= 23) piFlags |= PendingIntent.FLAG_IMMUTABLE;
        PendingIntent pi = PendingIntent.getActivity(this, requestId.hashCode(), open, piFlags);

        Notification.Builder b = Build.VERSION.SDK_INT >= 26
                ? new Notification.Builder(this, CHANNEL_ID)
                : new Notification.Builder(this);
        b.setSmallIcon(android.R.drawable.stat_notify_sync)
                .setContentTitle("AgentO: confirmação necessária")
                .setContentText("Solicitação: " + friendlyAction(action))
                .setContentIntent(pi)
                .setAutoCancel(true)
                .setOngoing(true);
        NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        nm.notify(NOTIFICATION_ID, b.build());
    }

    private Notification notification(String title, String text) {
        Intent open = new Intent(this, MainActivity.class);
        int piFlags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= 23) piFlags |= PendingIntent.FLAG_IMMUTABLE;
        PendingIntent pi = PendingIntent.getActivity(this, 4304, open, piFlags);
        Notification.Builder b = Build.VERSION.SDK_INT >= 26
                ? new Notification.Builder(this, CHANNEL_ID)
                : new Notification.Builder(this);
        return b.setSmallIcon(android.R.drawable.stat_notify_sync)
                .setContentTitle(title)
                .setContentText(text)
                .setContentIntent(pi)
                .setOngoing(true)
                .build();
    }

    private void updateNotification(String title, String text) {
        NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        nm.notify(NOTIFICATION_ID, notification(title, text));
    }

    private void createChannel() {
        if (Build.VERSION.SDK_INT >= 26) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID, "AgentO Mobile Relay", NotificationManager.IMPORTANCE_LOW);
            channel.setDescription("Mantém a conexão do AgentO Mobile com o relay HTTPS.");
            NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
            nm.createNotificationChannel(channel);
        }
    }

    private String shortMessage(Exception e) {
        String m = e.getMessage();
        if (m == null || m.trim().isEmpty()) return e.getClass().getSimpleName();
        return m.length() > 90 ? m.substring(0, 90) + "…" : m;
    }

    private String friendlyAction(String action) {
        if ("battery".equals(action)) return "Consultar bateria";
        if ("device".equals(action)) return "Consultar dispositivo";
        if ("storage".equals(action)) return "Consultar armazenamento";
        if ("network".equals(action)) return "Consultar rede";
        if ("status".equals(action)) return "Diagnóstico geral";
        return action;
    }

    @Override public void onDestroy() {
        running = false;
        if (loopThread != null) loopThread.interrupt();
        super.onDestroy();
    }

    @Override public IBinder onBind(Intent intent) { return null; }
}
