.class public Lcom/feurstagram/FeurConfig;
.super Ljava/lang/Object;

# FeurStagram Configuration
# Backed by SharedPreferences (file: feurstagram_prefs).
# Four independent toggles: feed, explore, reels, stories.
# All four default to true (blocked) on first launch.


# Set once any setting is changed in this process. While true, leaving the
# settings page (Back or Done) forces a clean restart instead of returning to
# the now-stale app. Reset implicitly every process (a restart clears it).
.field private static sNeedsRestart:Z


# Snapshot of every block_* toggle captured when the settings page opens, used
# by the permanent lock. The lock only freezes surfaces that were *already*
# blocked at this snapshot; a surface toggled on by mistake during the current
# session can still be turned back off until Done restarts the app and bakes the
# new state into the next snapshot. Null until the first captureBaseline() call.
.field private static sBaseline:Ljava/util/HashMap;


.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public static isHardcoreMode()Z
    .locals 2

    const-string v0, "hardcore_mode"
    const/4 v1, 0x0
    invoke-static {v0, v1}, Lcom/feurstagram/FeurConfig;->getBlocked(Ljava/lang/String;Z)Z
    move-result v0
    return v0
.end method


.method public static enableHardcoreMode()V
    .locals 4

    invoke-static {}, Lcom/feurstagram/FeurConfig;->getAppContext()Landroid/content/Context;
    move-result-object v0

    if-nez v0, :cond_has_ctx
    return-void

    :cond_has_ctx
    const-string v1, "feurstagram_prefs"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v0

    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;
    move-result-object v0

    const-string v1, "hardcore_mode"
    const/4 v2, 0x1
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences$Editor;->putBoolean(Ljava/lang/String;Z)Landroid/content/SharedPreferences$Editor;
    move-result-object v0

    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->apply()V
    return-void
.end method


# Retrieve the process Application context via reflection on ActivityThread.
# Returns null if we cannot resolve it.
.method public static getAppContext()Landroid/content/Context;
    .locals 4

    :try_start_0
    const-string v0, "android.app.ActivityThread"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v0

    const-string v1, "currentApplication"
    const/4 v2, 0x0
    new-array v2, v2, [Ljava/lang/Class;
    invoke-virtual {v0, v1, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;
    move-result-object v0

    const/4 v1, 0x0
    const/4 v2, 0x0
    new-array v2, v2, [Ljava/lang/Object;
    invoke-virtual {v0, v1, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0

    check-cast v0, Landroid/content/Context;

    return-object v0
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    move-exception v0
    const/4 v1, 0x0
    return-object v1
.end method


# getBlocked(String key, boolean defaultValue) -> boolean
.method public static getBlocked(Ljava/lang/String;Z)Z
    .locals 3

    invoke-static {}, Lcom/feurstagram/FeurConfig;->getAppContext()Landroid/content/Context;
    move-result-object v0

    if-nez v0, :cond_has_ctx
    return p1

    :cond_has_ctx
    const-string v1, "feurstagram_prefs"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v0

    invoke-interface {v0, p0, p1}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z
    move-result v0
    return v0
.end method


# setBlocked(String key, boolean value)
.method public static setBlocked(Ljava/lang/String;Z)V
    .locals 3

    # Hardcore lock: freeze any block_* toggle at its current value.
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isHardcoreMode()Z
    move-result v0
    if-eqz v0, :guard_done
    if-eqz p0, :guard_done

    const-string v1, "block_"
    invoke-virtual {p0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :guard_done

    # Hardcore only forbids *relaxing* a block (turning it off). Turning a
    # block on (p1 == true) is always allowed so users can still tighten.
    if-nez p1, :guard_done

    # Turning a block off is allowed only when this surface was already
    # unblocked at the start of the current settings session: that lets the
    # user undo a mis-toggle made this session. A surface that was blocked at
    # session open stays frozen until a reinstall.
    invoke-static {p0}, Lcom/feurstagram/FeurConfig;->isBaselineBlocked(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :guard_done
    return-void

    :guard_done

    invoke-static {}, Lcom/feurstagram/FeurConfig;->getAppContext()Landroid/content/Context;
    move-result-object v0

    if-nez v0, :cond_has_ctx
    return-void

    :cond_has_ctx
    const-string v1, "feurstagram_prefs"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v0

    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;
    move-result-object v0

    invoke-interface {v0, p0, p1}, Landroid/content/SharedPreferences$Editor;->putBoolean(Ljava/lang/String;Z)Landroid/content/SharedPreferences$Editor;
    move-result-object v0

    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->apply()V
    return-void
.end method


# Whether to check GitHub for a newer release on launch. On by default.
.method public static isAutoUpdateEnabled()Z
    .locals 2

    const-string v0, "auto_update"
    const/4 v1, 0x1
    invoke-static {v0, v1}, Lcom/feurstagram/FeurConfig;->getBlocked(Ljava/lang/String;Z)Z
    move-result v0
    return v0
.end method


.method public static isFeedBlocked()Z
    .locals 2

    const-string v0, "block_feed"
    const/4 v1, 0x1
    invoke-static {v0, v1}, Lcom/feurstagram/FeurConfig;->getBlocked(Ljava/lang/String;Z)Z
    move-result v0
    return v0
.end method


.method public static isExploreBlocked()Z
    .locals 2

    const-string v0, "block_explore"
    const/4 v1, 0x1
    invoke-static {v0, v1}, Lcom/feurstagram/FeurConfig;->getBlocked(Ljava/lang/String;Z)Z
    move-result v0
    return v0
.end method


.method public static isReelsBlocked()Z
    .locals 2

    const-string v0, "block_reels"
    const/4 v1, 0x1
    invoke-static {v0, v1}, Lcom/feurstagram/FeurConfig;->getBlocked(Ljava/lang/String;Z)Z
    move-result v0
    return v0
.end method


.method public static isStoriesBlocked()Z
    .locals 2

    const-string v0, "block_stories"
    const/4 v1, 0x0
    invoke-static {v0, v1}, Lcom/feurstagram/FeurConfig;->getBlocked(Ljava/lang/String;Z)Z
    move-result v0
    return v0
.end method


.method public static isInstantsBlocked()Z
    .locals 2

    const-string v0, "block_instants"
    const/4 v1, 0x1
    invoke-static {v0, v1}, Lcom/feurstagram/FeurConfig;->getBlocked(Ljava/lang/String;Z)Z
    move-result v0
    return v0
.end method


.method public static isNotesBlocked()Z
    .locals 2

    const-string v0, "block_notes"
    const/4 v1, 0x1
    invoke-static {v0, v1}, Lcom/feurstagram/FeurConfig;->getBlocked(Ljava/lang/String;Z)Z
    move-result v0
    return v0
.end method


.method public static isSuggestedBlocked()Z
    .locals 2

    const-string v0, "block_suggested"
    const/4 v1, 0x1
    invoke-static {v0, v1}, Lcom/feurstagram/FeurConfig;->getBlocked(Ljava/lang/String;Z)Z
    move-result v0
    return v0
.end method


# Snapshot the current value of every block_* toggle. Called once when the
# settings page opens so the permanent lock can tell which surfaces were
# already blocked (frozen) versus toggled on during this session (still
# reversible until Done restarts the app).
.method public static captureBaseline()V
    .locals 3

    new-instance v0, Ljava/util/HashMap;
    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V
    sput-object v0, Lcom/feurstagram/FeurConfig;->sBaseline:Ljava/util/HashMap;

    const-string v1, "block_feed"
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isFeedBlocked()Z
    move-result v2
    invoke-static {v0, v1, v2}, Lcom/feurstagram/FeurConfig;->putBaseline(Ljava/util/HashMap;Ljava/lang/String;Z)V

    const-string v1, "block_explore"
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isExploreBlocked()Z
    move-result v2
    invoke-static {v0, v1, v2}, Lcom/feurstagram/FeurConfig;->putBaseline(Ljava/util/HashMap;Ljava/lang/String;Z)V

    const-string v1, "block_reels"
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isReelsBlocked()Z
    move-result v2
    invoke-static {v0, v1, v2}, Lcom/feurstagram/FeurConfig;->putBaseline(Ljava/util/HashMap;Ljava/lang/String;Z)V

    const-string v1, "block_stories"
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isStoriesBlocked()Z
    move-result v2
    invoke-static {v0, v1, v2}, Lcom/feurstagram/FeurConfig;->putBaseline(Ljava/util/HashMap;Ljava/lang/String;Z)V

    const-string v1, "block_instants"
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isInstantsBlocked()Z
    move-result v2
    invoke-static {v0, v1, v2}, Lcom/feurstagram/FeurConfig;->putBaseline(Ljava/util/HashMap;Ljava/lang/String;Z)V

    const-string v1, "block_notes"
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isNotesBlocked()Z
    move-result v2
    invoke-static {v0, v1, v2}, Lcom/feurstagram/FeurConfig;->putBaseline(Ljava/util/HashMap;Ljava/lang/String;Z)V

    const-string v1, "block_suggested"
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isSuggestedBlocked()Z
    move-result v2
    invoke-static {v0, v1, v2}, Lcom/feurstagram/FeurConfig;->putBaseline(Ljava/util/HashMap;Ljava/lang/String;Z)V

    return-void
.end method


# Helper: box a boolean and store it under key in the given baseline map.
.method private static putBaseline(Ljava/util/HashMap;Ljava/lang/String;Z)V
    .locals 1

    invoke-static {p2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;
    move-result-object v0
    invoke-virtual {p0, p1, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    return-void
.end method


# True if the given block_* key was already blocked at the start of the current
# settings session. When no baseline was captured (calls outside the settings
# page), falls back to the live persisted value.
.method public static isBaselineBlocked(Ljava/lang/String;)Z
    .locals 3

    sget-object v0, Lcom/feurstagram/FeurConfig;->sBaseline:Ljava/util/HashMap;
    if-nez v0, :cond_have_baseline

    const/4 v1, 0x0
    invoke-static {p0, v1}, Lcom/feurstagram/FeurConfig;->getBlocked(Ljava/lang/String;Z)Z
    move-result v1
    return v1

    :cond_have_baseline
    invoke-virtual {v0, p0}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0
    if-nez v0, :cond_present
    const/4 v1, 0x0
    return v1

    :cond_present
    check-cast v0, Ljava/lang/Boolean;
    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z
    move-result v1
    return v1
.end method


# getLandingPage() -> String. One of "home" (default), "search", "direct",
# "profile": the surface the app should jump to on cold start.
.method public static getLandingPage()Ljava/lang/String;
    .locals 3

    invoke-static {}, Lcom/feurstagram/FeurConfig;->getAppContext()Landroid/content/Context;
    move-result-object v0

    if-nez v0, :cond_has_ctx
    const-string v0, "home"
    return-object v0

    :cond_has_ctx
    const-string v1, "feurstagram_prefs"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v0

    const-string v1, "landing_page"
    const-string v2, "home"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method


# Mark that a setting changed and a restart is required to apply it cleanly.
.method public static setNeedsRestart()V
    .locals 1

    const/4 v0, 0x1
    sput-boolean v0, Lcom/feurstagram/FeurConfig;->sNeedsRestart:Z
    return-void
.end method


# True if a setting was changed this process and a restart is still pending.
.method public static isRestartPending()Z
    .locals 1

    sget-boolean v0, Lcom/feurstagram/FeurConfig;->sNeedsRestart:Z
    return v0
.end method


# setLandingPage(String value)
.method public static setLandingPage(Ljava/lang/String;)V
    .locals 3

    invoke-static {}, Lcom/feurstagram/FeurConfig;->getAppContext()Landroid/content/Context;
    move-result-object v0

    if-nez v0, :cond_has_ctx
    return-void

    :cond_has_ctx
    const-string v1, "feurstagram_prefs"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v0

    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;
    move-result-object v0

    const-string v1, "landing_page"
    invoke-interface {v0, v1, p0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;
    move-result-object v0

    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->apply()V
    return-void
.end method
