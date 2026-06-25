package com.feurstagram.extension;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.RippleDrawable;
import android.content.res.ColorStateList;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;

/**
 * Watches the view tree for the home feed's top action bar and inserts the
 * Feurstagram settings button just left of the notifications (heart) icon.
 *
 * The action bar is rebuilt whenever the user leaves and returns to the feed, so
 * the listener stays attached and re-inserts the button (guarded by a tag) each
 * time the bar reappears, rather than detaching after the first insert. Views are
 * resolved by resource name via getIdentifier so the patch survives Instagram
 * version bumps that reshuffle the hex resource ids.
 */
public final class ActionBarWatcher implements ViewTreeObserver.OnGlobalLayoutListener {

    private static final String BUTTON_TAG = "feurstagram_settings_button";
    private static final String SPACER_TAG = "feurstagram_title_spacer";

    /** Width of the injected button; the left-side spacer matches it. */
    private static final int BUTTON_WIDTH_DP = 44;

    private final View root;

    public ActionBarWatcher(View root) {
        this.root = root;
    }

    @Override
    public void onGlobalLayout() {
        if (root == null) return;
        Context context = root.getContext();
        if (context == null) return;

        View actionBar = findByName(root, "main_feed_action_bar", context);
        if (!(actionBar instanceof ViewGroup)) return; // feed bar not present (other tab)

        View rightContainer = findByName(actionBar, "action_bar_buttons_container_right", context);
        if (!(rightContainer instanceof ViewGroup)) return;

        ViewGroup container = (ViewGroup) rightContainer;
        if (container.findViewWithTag(BUTTON_TAG) != null) return; // already added

        int color = resolveForegroundColor((ViewGroup) actionBar, context);
        // Build with the action bar's own context (derived from the hosting
        // Activity) so the settings dialog gets a valid window token — the decor
        // view's root context is a bare ContextImpl and can't host a dialog.
        container.addView(buildButton(container.getContext(), color), 0); // index 0 = left of the heart

        // The title is centred in the gap between the left/right button groups,
        // so widening the right side shifts it. Re-balance with an equal-width
        // invisible spacer on the left (right of the "+").
        View leftContainer = findByName(actionBar, "action_bar_buttons_container_left", context);
        if (leftContainer instanceof ViewGroup) {
            ViewGroup left = (ViewGroup) leftContainer;
            if (left.findViewWithTag(SPACER_TAG) == null) {
                View spacer = new View(left.getContext());
                spacer.setTag(SPACER_TAG);
                spacer.setLayoutParams(new LinearLayout.LayoutParams(
                        Settings.dp(left.getContext(), BUTTON_WIDTH_DP),
                        ViewGroup.LayoutParams.MATCH_PARENT));
                left.addView(spacer);
            }
        }
    }

    /** Resolve a view by resource name, trying the running package then Instagram's. */
    private static View findByName(View scope, String name, Context context) {
        Resources resources = context.getResources();
        int id = resources.getIdentifier(name, "id", context.getPackageName());
        if (id == 0) {
            id = resources.getIdentifier(name, "id", "com.instagram.android");
        }
        return id == 0 ? null : scope.findViewById(id);
    }

    /** Use the action-bar title colour so the icon matches Instagram's light/dark theme. */
    private static int resolveForegroundColor(ViewGroup actionBar, Context context) {
        View title = findByName(actionBar, "title_text", context);
        if (title instanceof android.widget.TextView) {
            return ((android.widget.TextView) title).getCurrentTextColor();
        }
        return Color.WHITE;
    }

    private static View buildButton(Context context, int color) {
        FrameLayout button = new FrameLayout(context);
        button.setTag(BUTTON_TAG);
        button.setClickable(true);
        button.setFocusable(true);
        button.setBackground(new RippleDrawable(
                ColorStateList.valueOf(Settings.RIPPLE), null, null));
        button.setContentDescription("Feurstagram settings");
        button.setLayoutParams(new LinearLayout.LayoutParams(
                Settings.dp(context, BUTTON_WIDTH_DP), ViewGroup.LayoutParams.MATCH_PARENT));

        ImageView icon = new ImageView(context);
        icon.setImageDrawable(new SettingsIcon(context, color));
        int size = Settings.dp(context, 24);
        FrameLayout.LayoutParams iconLp = new FrameLayout.LayoutParams(size, size);
        iconLp.gravity = Gravity.CENTER;
        button.addView(icon, iconLp);

        button.setOnClickListener(v -> {
            Context activity = Settings.getActivityContext(v);
            if (activity != null) Settings.show(activity);
        });
        return button;
    }
}
