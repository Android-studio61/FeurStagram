package com.feurstagram.extension;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Typeface;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.io.InputStream;
import java.util.Scanner;

/**
 * Checks GitHub for a newer Feurstagram release once per process and, if found,
 * invites the user to grab it. The download action opens the release page in a
 * browser rather than installing over the app, so it works whether or not the
 * build was cloned to a side-by-side package.
 */
public final class UpdateChecker implements Runnable {

    private static final String REPO = "jean-voila/Feurstagram";
    private static final String LATEST_API = "https://api.github.com/repos/" + REPO + "/releases/latest";
    private static final String LATEST_PAGE = "https://github.com/" + REPO + "/releases/latest";

    private static boolean checked;

    private final Context context;

    private UpdateChecker(Context context) {
        this.context = context;
    }

    /** Kick off a one-shot background check if enabled. Runs at most once per process. */
    public static void check(Context context) {
        if (context == null || checked) return;
        checked = true;
        if (!Config.isAutoUpdateEnabled()) return;
        new Thread(new UpdateChecker(context)).start();
    }

    @Override
    public void run() {
        try {
            java.net.HttpURLConnection connection =
                    (java.net.HttpURLConnection) new java.net.URL(LATEST_API).openConnection();
            connection.setRequestProperty("User-Agent", "Feurstagram-UpdateCheck");
            connection.setRequestProperty("Accept", "application/vnd.github+json");
            connection.setConnectTimeout(10000);
            connection.setReadTimeout(10000);

            String body;
            try (InputStream input = connection.getInputStream();
                 Scanner scanner = new Scanner(input).useDelimiter("\\A")) {
                body = scanner.hasNext() ? scanner.next() : "";
            } finally {
                connection.disconnect();
            }

            String tag = extractTagName(body);
            if (tag == null) return;

            if (isNewer(normalize(tag), installedVersion())) {
                new Handler(Looper.getMainLooper()).post(() -> showPrompt(context, tag));
            }
        } catch (Throwable ignored) {
            // Network/parse failures are non-fatal: just skip the check.
        }
    }

    /** Pull the first "tag_name":"..." value out of the release JSON. */
    private static String extractTagName(String json) {
        if (json == null) return null;
        int key = json.indexOf("\"tag_name\"");
        if (key < 0) return null;
        int colon = json.indexOf(':', key);
        if (colon < 0) return null;
        int open = json.indexOf('"', colon + 1);
        if (open < 0) return null;
        int close = json.indexOf('"', open + 1);
        if (close < 0) return null;
        return json.substring(open + 1, close);
    }

    /** "v434-0-0-44-74" -> "434.0.0.44.74" so it matches the installed versionName. */
    static String normalize(String tag) {
        if (tag == null) return "";
        String value = tag.trim();
        if (value.startsWith("v") || value.startsWith("V")) {
            value = value.substring(1);
        }
        return value.replace('-', '.');
    }

    /** Installed versionName (Instagram's), e.g. "435.0.0.37.76". "0" on failure. */
    private String installedVersion() {
        try {
            PackageManager pm = context.getPackageManager();
            String name = pm.getPackageInfo(context.getPackageName(), 0).versionName;
            return name == null ? "0" : name;
        } catch (Throwable t) {
            return "0";
        }
    }

    /** True if dotted version `latest` is strictly greater than `installed`. */
    static boolean isNewer(String latest, String installed) {
        String[] a = latest.split("\\.");
        String[] b = installed.split("\\.");
        int len = Math.max(a.length, b.length);
        for (int i = 0; i < len; i++) {
            int x = i < a.length ? parse(a[i]) : 0;
            int y = i < b.length ? parse(b[i]) : 0;
            if (x != y) return x > y;
        }
        return false;
    }

    private static int parse(String value) {
        try {
            return Integer.parseInt(value.trim());
        } catch (Throwable t) {
            return 0;
        }
    }

    private static void showPrompt(Context context, String tag) {
        try {
            Dialog dialog = new Dialog(context);
            dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
            dialog.setContentView(buildContent(context, dialog, tag));
            Window window = dialog.getWindow();
            if (window != null) {
                window.setBackgroundDrawable(new ColorDrawable(0));
                window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                window.setDimAmount(0.6f);
            }
            dialog.show();
        } catch (Throwable ignored) {
        }
    }

    private static View buildContent(Context context, Dialog dialog, String tag) {
        FrameLayout frame = new FrameLayout(context);
        int pad = Settings.dp(context, 24);
        frame.setPadding(pad, pad, pad, pad);

        LinearLayout card = new LinearLayout(context);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackground(Settings.roundedRect(Settings.SURFACE, 28, context));
        card.setPadding(pad, pad, pad, pad);
        frame.addView(card, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        TextView title = new TextView(context);
        title.setText("Update available");
        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 22f);
        title.setTextColor(Settings.ON_SURFACE);
        title.setTypeface(Typeface.create("sans-serif-medium", Typeface.NORMAL));
        card.addView(title);

        TextView body = new TextView(context);
        body.setText("Feurstagram " + tag + " is available. Open the release page to download it.");
        body.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f);
        body.setTextColor(Settings.ON_SURFACE_VARIANT);
        body.setPadding(0, Settings.dp(context, 12), 0, 0);
        card.addView(body);

        LinearLayout buttons = new LinearLayout(context);
        buttons.setOrientation(LinearLayout.HORIZONTAL);
        buttons.setGravity(Gravity.END);
        LinearLayout.LayoutParams buttonsLp =
                new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        buttonsLp.setMargins(0, Settings.dp(context, 24), 0, 0);
        card.addView(buttons, buttonsLp);

        Button later = Settings.makeButton(context, "Later", 0, Settings.ON_SURFACE_VARIANT, false);
        later.setOnClickListener(v -> dialog.dismiss());
        buttons.addView(later);

        View spacer = new View(context);
        spacer.setLayoutParams(new LinearLayout.LayoutParams(Settings.dp(context, 8), 1));
        buttons.addView(spacer);

        Button download = Settings.makeButton(context, "Download", Settings.PRIMARY, Settings.ON_PRIMARY, true);
        download.setOnClickListener(v -> {
            dialog.dismiss();
            openReleasePage(context);
        });
        buttons.addView(download);

        return frame;
    }

    private static void openReleasePage(Context context) {
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(LATEST_PAGE));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
        } catch (Throwable t) {
            Toast.makeText(context, "No browser available", Toast.LENGTH_LONG).show();
        }
    }
}
