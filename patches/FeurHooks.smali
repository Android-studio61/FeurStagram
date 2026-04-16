.class public Lcom/feurstagram/FeurHooks;
.super Ljava/lang/Object;

# FeurStagram Network Hooks
#
# Content blocks are gated on FeurConfig (runtime toggles):
#   - /feed/timeline/         -> isFeedBlocked()
#   - /feed/reels_tray        -> isStoriesBlocked()
#   - /discover/topical_explore -> isExploreBlocked()
#   - /clips/home/, /clips/discover -> isReelsBlocked()
#
# Analytics / commerce endpoints are always blocked regardless of toggles:
#   - /logging/
#   - /async_ads_privacy/
#   - /async_critical_notices/
#   - /api/v1/media/.../seen/
#   - /api/v1/fbupload/
#   - /api/v1/stats/
#   - /api/v1/commerce/, /api/v1/shopping/, /api/v1/sellable_items/


.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


# Log with tag "Feurstagram" (adb logcat -s "Feurstagram:D")
.method public static log(Ljava/lang/String;)V
    .locals 0
    return-void
.end method


.method public static logRequest(Ljava/net/URI;)V
    .locals 0
    return-void
.end method


# True when path matches /api/v1/media/.../seen/ (post "seen" tracking).
.method private static shouldBlockMediaSeen(Ljava/lang/String;)Z
    .locals 2

    if-eqz p0, :cond_false

    const-string v0, "/api/v1/media/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-eqz v1, :cond_false

    const-string v0, "/seen"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    :cond_false
    const/4 v0, 0x0
    return v0

    :cond_true
    const/4 v0, 0x1
    return v0
.end method


# Main hook: Throws IOException if request should be blocked.
# Called from TigonServiceLayer before each network request.
.method public static throwIfBlocked(Ljava/net/URI;)V
    .locals 4

    invoke-virtual {p0}, Ljava/net/URI;->getPath()Ljava/lang/String;
    move-result-object v0

    if-eqz v0, :cond_return

    # Home feed (toggleable)
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isFeedBlocked()Z
    move-result v2
    if-eqz v2, :skip_feed
    const-string v1, "/feed/timeline/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block
    :skip_feed

    # Stories (toggleable) - Instagram loads the story tray from /feed/reels_tray/
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isStoriesBlocked()Z
    move-result v2
    if-eqz v2, :skip_stories
    const-string v1, "/feed/reels_tray"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block
    :skip_stories

    # Explore tab (toggleable)
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isExploreBlocked()Z
    move-result v2
    if-eqz v2, :skip_explore
    const-string v1, "/discover/topical_explore"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block
    :skip_explore

    # Reels (toggleable) - block clips surfaces only.
    # Note: /feed/reels_media_stream/ and /feed/injected_reels_media/
    # are shared with stories delivery, so they are intentionally not
    # controlled by the Reels toggle.
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isReelsBlocked()Z
    move-result v2
    if-eqz v2, :skip_reels
    const-string v1, "/clips/home/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block
    const-string v1, "/clips/discover"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block
    :skip_reels

    # --- Always-blocked analytics / commerce ---

    const-string v1, "/logging/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block

    const-string v1, "/async_ads_privacy/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block

    const-string v1, "/async_critical_notices/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block

    invoke-static {v0}, Lcom/feurstagram/FeurHooks;->shouldBlockMediaSeen(Ljava/lang/String;)Z
    move-result v2
    if-nez v2, :cond_block

    const-string v1, "/api/v1/fbupload/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block

    const-string v1, "/api/v1/stats/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block

    const-string v1, "/api/v1/commerce/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block

    const-string v1, "/api/v1/shopping/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block

    const-string v1, "/api/v1/sellable_items/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block

    :cond_return
    return-void

    :cond_block
    const-string v1, "BLOCKED!"
    invoke-static {v1}, Lcom/feurstagram/FeurHooks;->log(Ljava/lang/String;)V

    new-instance v3, Ljava/io/IOException;
    const-string v1, "Blocked by Feurstagram"
    invoke-direct {v3, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V
    throw v3
.end method
