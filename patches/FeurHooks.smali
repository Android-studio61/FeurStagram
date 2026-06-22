.class public Lcom/feurstagram/FeurHooks;
.super Ljava/lang/Object;

# FeurStagram Network Hooks
#
# Content blocks are gated on FeurConfig (runtime toggles):
#   - /feed/timeline/         -> isFeedBlocked()
#   - /feed/reels_tray        -> isStoriesBlocked()
#   - /discover/topical_explore -> isExploreBlocked()
#   - /clips/home/, /clips/discover, /clips/get_blend_medias/ -> isReelsBlocked()
#   - account/user recommendation endpoints (see shouldBlockSuggested) ->
#       isSuggestedBlocked()
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


# True when the path is an account/user recommendation surface. These feed the
# "Suggested for you" rows on profiles, the suggested accounts injected into the
# stories tray, the search null-state recs, post-follow "discover people"
# chaining, and friend/business suggestions. Gated on isSuggestedBlocked().
# Action endpoints (dismiss_*) are deliberately left alone.
.method private static shouldBlockSuggested(Ljava/lang/String;)Z
    .locals 2

    if-eqz p0, :cond_false

    const-string v0, "/discover/ayml/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/discover/sectioned_ayml/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/discover/chaining/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/discover/recommended_accounts_for_category/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/discover/suggested_businesses/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/discover/recs_from_friends_suggestions/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/discover/recs_from_friends_user_info/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/discover/surface_with_su/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/discover/fetch_suggestion_details/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/discover/account_discovery/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/discover/reshare_suggestions/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/fbsearch/accounts_recs/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/friendships/feed_favorites_suggestions/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/friendships/share_to_friends_story_suggested_users/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/direct_v2/search_friending_suggestions/"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :cond_true

    const-string v0, "/business/discovery/suggest_business/"
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
    # Reels served inside a Blend (friends/group blends) - issue #2.
    # Blend reels are fetched from /api/v1/clips/get_blend_medias/ with a
    # blend_id param, a separate surface from the main /clips/home feed.
    const-string v1, "/clips/get_blend_medias/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block
    :skip_reels

    # Suggested accounts (toggleable) - account/user recommendation surfaces:
    # the "Suggested for you" carousels on profiles, the accounts injected into
    # the stories tray and search, post-follow chaining, etc.
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isSuggestedBlocked()Z
    move-result v2
    if-eqz v2, :skip_suggested
    invoke-static {v0}, Lcom/feurstagram/FeurHooks;->shouldBlockSuggested(Ljava/lang/String;)Z
    move-result v2
    if-nez v2, :cond_block
    :skip_suggested

    # --- Always-blocked analytics / commerce ---

    const-string v1, "/api/v1/ads/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block

    const-string v1, "/feed/injected_reels_media/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-nez v2, :cond_block

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
