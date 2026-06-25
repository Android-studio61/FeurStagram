package com.feurstagram.extension;

import android.content.Context;
import android.content.res.Resources;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;

/**
 * UI-level hiders and the landing-page redirect, all installed on the main
 * tab bar. Each is a persistent global-layout listener that resolves its
 * target by resource name (with a clone fallback) so it survives Instagram
 * version bumps that reshuffle hex resource ids.
 */
public final class Hiders {

    private Hiders() {}

    /** Install every UI hider and the landing redirect on the tab-bar root. */
    public static void installAll(ViewGroup root) {
        if (root == null) return;
        ViewTreeObserver observer = root.getViewTreeObserver();
        // Reels tab, Notes tray, Instants entry-points.
        observer.addOnGlobalLayoutListener(new VisibilityHider(root, "block_reels", "clips_tab"));
        observer.addOnGlobalLayoutListener(new VisibilityHider(root, "block_notes", "cf_hub_recycler_view"));
        observer.addOnGlobalLayoutListener(new VisibilityHider(root, "block_instants",
                "creation_entrypoint", "direct_quick_snap_consumption_preview"));
        // Cold-start landing-page redirect.
        observer.addOnGlobalLayoutListener(new LandingWatcher(root));
    }

    static int resolveId(Context context, String name) {
        Resources resources = context.getResources();
        int id = resources.getIdentifier(name, "id", context.getPackageName());
        if (id == 0) {
            id = resources.getIdentifier(name, "id", "com.instagram.android");
        }
        return id;
    }

    /**
     * Applies GONE/VISIBLE to one or more named views on every layout pass,
     * driven by a block_* preference. Toggling the preference off restores the
     * views on the next pass.
     */
    static final class VisibilityHider implements ViewTreeObserver.OnGlobalLayoutListener {
        private final ViewGroup root;
        private final String key;
        private final String[] names;

        VisibilityHider(ViewGroup root, String key, String... names) {
            this.root = root;
            this.key = key;
            this.names = names;
        }

        @Override
        public void onGlobalLayout() {
            Context context = root.getContext();
            if (context == null) return;
            int visibility = Config.getBlocked(key, true) ? View.GONE : View.VISIBLE;
            for (String name : names) {
                int id = resolveId(context, name);
                if (id == 0) continue;
                View view = root.findViewById(id);
                if (view != null) view.setVisibility(visibility);
            }
        }
    }

    /**
     * Redirects to the chosen landing surface (search/direct/profile) once per
     * tab-bar build, then detaches. "home" needs no redirect.
     */
    static final class LandingWatcher implements ViewTreeObserver.OnGlobalLayoutListener {
        private static final int MAX_ATTEMPTS = 30;
        private ViewGroup container;
        private boolean done;
        private int attempts;

        LandingWatcher(ViewGroup container) {
            this.container = container;
        }

        @Override
        public void onGlobalLayout() {
            ViewGroup root = container;
            if (root == null) return;
            if (done) {
                detach();
                return;
            }

            Context context = root.getContext();
            if (context == null) return;

            String landing = Config.getLandingPage();
            String target;
            if ("search".equals(landing)) {
                target = "search_tab";
            } else if ("direct".equals(landing)) {
                target = "direct_tab";
            } else if ("profile".equals(landing)) {
                target = "profile_tab";
            } else {
                detach(); // "home" or unknown: nothing to do
                return;
            }

            int id = resolveId(context, target);
            if (id == 0) {
                detach(); // not present in this build
                return;
            }

            // Search the whole window so action-bar entries are reachable too.
            View view = root.getRootView().findViewById(id);
            if (view == null) {
                if (++attempts >= MAX_ATTEMPTS) detach();
                return; // not laid out yet; retry up to the bound
            }

            view.performClick();
            done = true;
            detach();
        }

        private void detach() {
            ViewGroup root = container;
            if (root != null) {
                root.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                container = null;
            }
        }
    }
}
