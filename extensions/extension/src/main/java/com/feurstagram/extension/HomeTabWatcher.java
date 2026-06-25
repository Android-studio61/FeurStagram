package com.feurstagram.extension;

import android.content.Context;
import android.content.res.Resources;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;

/**
 * Watches the bottom tab bar until the "feed_tab" child (the Home button at the
 * bottom-left) is inflated, attaches the long-press settings listener to it,
 * then detaches itself. The id is resolved by name via getIdentifier so the
 * patch survives Instagram version bumps that reshuffle hex resource ids.
 */
public final class HomeTabWatcher implements ViewTreeObserver.OnGlobalLayoutListener {

    private ViewGroup container;

    public HomeTabWatcher(ViewGroup container) {
        this.container = container;
    }

    @Override
    public void onGlobalLayout() {
        ViewGroup root = container;
        if (root == null) return;

        Context context = root.getContext();
        if (context == null) return;

        Resources resources = context.getResources();
        // Look up under the running package first, then fall back to the
        // Instagram resource package (a clone keeps "com.instagram.android" as
        // the resource package even though the app id changed).
        int id = resources.getIdentifier("feed_tab", "id", context.getPackageName());
        if (id == 0) {
            id = resources.getIdentifier("feed_tab", "id", "com.instagram.android");
        }
        if (id == 0) return; // resources not ready yet; keep waiting

        View homeTab = root.findViewById(id);
        if (homeTab == null) return; // feed_tab not inflated yet; keep waiting

        Settings.attachLongPress(homeTab);

        root.getViewTreeObserver().removeOnGlobalLayoutListener(this);
        container = null;
    }
}
