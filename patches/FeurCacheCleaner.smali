.class public Lcom/feurstagram/FeurCacheCleaner;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

# Clears Instagram's cache directories on a background thread, then
# kills the process so every pre-fetched reel/story/feed item is gone
# and the app relaunches from a clean slate.


# instance fields
.field private mContext:Landroid/content/Context;


.method private constructor <init>(Landroid/content/Context;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurCacheCleaner;->mContext:Landroid/content/Context;
    return-void
.end method


# Public entry: show a toast on the UI thread, spawn the worker thread.
.method public static clearAndRestart(Landroid/content/Context;)V
    .locals 3

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    :try_start_0
    const-string v0, "FeurStagram: clearing cache..."
    const/4 v1, 0x1
    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    goto :start_thread

    :catch_0
    move-exception v0

    :start_thread
    new-instance v0, Lcom/feurstagram/FeurCacheCleaner;
    invoke-direct {v0, p0}, Lcom/feurstagram/FeurCacheCleaner;-><init>(Landroid/content/Context;)V
    new-instance v1, Ljava/lang/Thread;
    invoke-direct {v1, v0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V
    invoke-virtual {v1}, Ljava/lang/Thread;->start()V
    return-void
.end method


.method public run()V
    .locals 4

    const-string v0, "cache-clear: start"
    invoke-static {v0}, Lcom/feurstagram/FeurHooks;->log(Ljava/lang/String;)V

    :try_start_0
    iget-object v0, p0, Lcom/feurstagram/FeurCacheCleaner;->mContext:Landroid/content/Context;

    # Explicit first pass for known reels prefetch cache path.
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeKnownVideoCaches(Landroid/content/Context;)V
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeKnownReelsArtifacts(Landroid/content/Context;)V

    # getCacheDir() - app cache
    invoke-virtual {v0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;
    move-result-object v1
    invoke-static {v1}, Lcom/feurstagram/FeurCacheCleaner;->deleteContents(Ljava/io/File;)V

    # getCodeCacheDir() - dex / JIT cache (API 21+)
    invoke-virtual {v0}, Landroid/content/Context;->getCodeCacheDir()Ljava/io/File;
    move-result-object v1
    invoke-static {v1}, Lcom/feurstagram/FeurCacheCleaner;->deleteContents(Ljava/io/File;)V

    # getExternalCacheDir() - may be null (no SD / unmounted)
    invoke-virtual {v0}, Landroid/content/Context;->getExternalCacheDir()Ljava/io/File;
    move-result-object v1
    if-eqz v1, :skip_ext
    invoke-static {v1}, Lcom/feurstagram/FeurCacheCleaner;->deleteContents(Ljava/io/File;)V

    :skip_ext
    # getFilesDir() - Instagram stores pre-fetched reel/story videos here
    # but also auth tokens. We cannot nuke the whole directory (would log
    # the user out); we only wipe SUBDIRECTORIES whose name looks like a
    # media / video / prefetch cache.
    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v1
    invoke-static {v1}, Lcom/feurstagram/FeurCacheCleaner;->wipeMediaCaches(Ljava/io/File;)V

    # Explicit second pass after generic wipes to catch recreated chunks.
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeKnownVideoCaches(Landroid/content/Context;)V
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeKnownReelsArtifacts(Landroid/content/Context;)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    goto :after_clear

    :catch_0
    move-exception v0
    const-string v1, "cache-clear: error"
    invoke-static {v1}, Lcom/feurstagram/FeurHooks;->log(Ljava/lang/String;)V

    :after_clear
    # Give the Toast time to render before we kill the process.
    :try_start_1
    iget-object v2, p0, Lcom/feurstagram/FeurCacheCleaner;->mContext:Landroid/content/Context;
    invoke-static {v2}, Lcom/feurstagram/FeurCacheCleaner;->wipeKnownVideoCaches(Landroid/content/Context;)V
    invoke-static {v2}, Lcom/feurstagram/FeurCacheCleaner;->wipeKnownReelsArtifacts(Landroid/content/Context;)V
    invoke-static {v2}, Lcom/feurstagram/FeurCacheCleaner;->stopAllAppProcesses(Landroid/content/Context;)V

    const-wide/16 v0, 0x1f4
    invoke-static {v0, v1}, Ljava/lang/Thread;->sleep(J)V
    :try_end_1
    .catch Ljava/lang/Throwable; {:try_start_1 .. :try_end_1} :catch_1

    goto :do_kill

    :catch_1
    move-exception v0

    :do_kill
    iget-object v2, p0, Lcom/feurstagram/FeurCacheCleaner;->mContext:Landroid/content/Context;
    invoke-static {v2}, Lcom/feurstagram/FeurCacheCleaner;->stopAllAppProcesses(Landroid/content/Context;)V

    const-string v0, "cache-clear: killing process"
    invoke-static {v0}, Lcom/feurstagram/FeurHooks;->log(Ljava/lang/String;)V

    invoke-static {}, Landroid/os/Process;->myPid()I
    move-result v0
    invoke-static {v0}, Landroid/os/Process;->killProcess(I)V
    return-void
.end method


# Instagram reels video chunks are stored in cacheDir/ExoPlayerCacheDir/
# videocache/*.v2.exo. Wipe this path explicitly (plus close variants)
# in addition to generic cache clearing.
.method private static wipeKnownVideoCaches(Landroid/content/Context;)V
    .locals 1

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    invoke-virtual {p0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;
    move-result-object v0
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeKnownVideoCachesUnder(Ljava/io/File;)V

    invoke-virtual {p0}, Landroid/content/Context;->getExternalCacheDir()Ljava/io/File;
    move-result-object v0
    if-eqz v0, :end
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeKnownVideoCachesUnder(Ljava/io/File;)V

    :end
    return-void
.end method


# Extra reel-related state/caches observed in Instagram internals:
# - ExoPlayerCacheDir/videoprefetchcache and videocachemetadata
# - pending_reel_* / pending_clips_* stores
# - most_recent_reels_cache and ig_pando_response_cache
# - Room DB files containing delivery_media_room_db / user_reel_medias_room_db
.method private static wipeKnownReelsArtifacts(Landroid/content/Context;)V
    .locals 1

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    invoke-virtual {p0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;
    move-result-object v0
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeKnownReelsArtifactsUnder(Ljava/io/File;)V

    invoke-virtual {p0}, Landroid/content/Context;->getExternalCacheDir()Ljava/io/File;
    move-result-object v0
    if-eqz v0, :skip_ext
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeKnownReelsArtifactsUnder(Ljava/io/File;)V

    :skip_ext
    invoke-virtual {p0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v0
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeKnownReelsArtifactsUnder(Ljava/io/File;)V

    invoke-static {p0}, Lcom/feurstagram/FeurCacheCleaner;->wipeReelsDatabases(Landroid/content/Context;)V
    return-void
.end method


.method private static wipeKnownVideoCachesUnder(Ljava/io/File;)V
    .locals 1

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    const-string v0, "ExoPlayerCacheDir/videocache"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "ExoPlayerCacheDir/videoprefetchcache"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "ExoPlayerCacheDir/videocachemetadata"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "videocache"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "videoprefetchcache"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "videocachemetadata"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "ExoPlayerCacheDir"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    return-void
.end method


.method private static wipeKnownReelsArtifactsUnder(Ljava/io/File;)V
    .locals 1

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    const-string v0, "most_recent_reels_cache"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "ig_pando_response_cache"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "direct_background_prefetch_cache"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "pending_reel_tray_seen_states"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "pending_reel_seen_states"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "pending_clips_seen_states"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "pending_reel_quiz_responses"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "pending_reel_slider_votes"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "pending_reel_countdown_follow_requests"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "ExoPlayerCacheDir/videoprefetchcache"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "ExoPlayerCacheDir/videocachemetadata"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    const-string v0, "files/ExoPlayerCacheDir"
    invoke-static {p0, v0}, Lcom/feurstagram/FeurCacheCleaner;->wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    return-void
.end method


.method private static wipeRelativePath(Ljava/io/File;Ljava/lang/String;)V
    .locals 2

    if-eqz p0, :end
    if-eqz p1, :end

    new-instance v0, Ljava/io/File;
    invoke-direct {v0, p0, p1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v0}, Ljava/io/File;->exists()Z
    move-result v1
    if-eqz v1, :end
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->logWipe(Ljava/io/File;)V
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->deleteRecursive(Ljava/io/File;)V

    :end
    return-void
.end method


.method private static wipeReelsDatabases(Landroid/content/Context;)V
    .locals 8

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    const-string v0, "delivery_media_room_db"
    invoke-virtual {p0, v0}, Landroid/content/Context;->getDatabasePath(Ljava/lang/String;)Ljava/io/File;
    move-result-object v1
    if-eqz v1, :end

    invoke-virtual {v1}, Ljava/io/File;->getParentFile()Ljava/io/File;
    move-result-object v2
    if-eqz v2, :end

    invoke-virtual {v2}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v3
    if-eqz v3, :end

    array-length v4, v3
    const/4 v5, 0x0

    :loop
    if-ge v5, v4, :end
    aget-object v6, v3, v5

    invoke-virtual {v6}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v7
    invoke-virtual {v7}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v7

    const-string v0, "delivery_media_room_db"
    invoke-virtual {v7, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v0
    if-nez v0, :wipe

    const-string v0, "reels_tray_delivery_media_room_db"
    invoke-virtual {v7, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v0
    if-nez v0, :wipe

    const-string v0, "user_reel_medias_room_db"
    invoke-virtual {v7, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v0
    if-nez v0, :wipe

    const-string v0, "flash_media_"
    invoke-virtual {v7, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v0
    if-nez v0, :wipe

    const-string v0, "clips_"
    invoke-virtual {v7, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v0
    if-eqz v0, :next

    :wipe
    invoke-static {v6}, Lcom/feurstagram/FeurCacheCleaner;->logWipe(Ljava/io/File;)V
    invoke-static {v6}, Lcom/feurstagram/FeurCacheCleaner;->deleteRecursive(Ljava/io/File;)V

    :next
    add-int/lit8 v5, v5, 0x1
    goto :loop

    :end
    return-void
.end method


# Best-effort force-close: try to kill every process belonging to this app,
# not only the current PID. This mimics manual "Force stop" more closely.
.method private static stopAllAppProcesses(Landroid/content/Context;)V
    .locals 10

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    :try_start_0
    const-string v0, "activity"
    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/app/ActivityManager;
    if-eqz v1, :end

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;
    move-result-object v2
    if-eqz v2, :end

    # May be denied on some Android versions; ignore failures.
    :try_start_1
    invoke-virtual {v1, v2}, Landroid/app/ActivityManager;->killBackgroundProcesses(Ljava/lang/String;)V
    :try_end_1
    .catch Ljava/lang/Throwable; {:try_start_1 .. :try_end_1} :catch_inner

    goto :after_bg

    :catch_inner
    move-exception v9

    :after_bg
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v4, ":"
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3

    invoke-virtual {v1}, Landroid/app/ActivityManager;->getRunningAppProcesses()Ljava/util/List;
    move-result-object v4
    if-eqz v4, :end

    invoke-interface {v4}, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v4

    :loop
    invoke-interface {v4}, Ljava/util/Iterator;->hasNext()Z
    move-result v5
    if-eqz v5, :end

    invoke-interface {v4}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v5
    check-cast v5, Landroid/app/ActivityManager$RunningAppProcessInfo;
    if-eqz v5, :loop

    iget-object v6, v5, Landroid/app/ActivityManager$RunningAppProcessInfo;->processName:Ljava/lang/String;
    if-eqz v6, :loop

    invoke-virtual {v6, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v7
    if-nez v7, :kill

    invoke-virtual {v6, v3}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v7
    if-eqz v7, :loop

    :kill
    iget v8, v5, Landroid/app/ActivityManager$RunningAppProcessInfo;->pid:I
    if-lez v8, :loop
    invoke-static {v8}, Landroid/os/Process;->killProcess(I)V
    goto :loop

    :end
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    return-void
.end method


# ---------------------------------------------------------------------------
# Diagnostics: dump every entry under filesDir / cacheDir to logcat so we can
# identify the exact dir names Instagram uses for video / reel prefetches.
# Call from FeurSettings.show() at dialog-open time (never deletes anything).
# ---------------------------------------------------------------------------

.method public static dumpAllCaches(Landroid/content/Context;)V
    .locals 3

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    :try_start_0
    # depth = 4 is enough to reveal Instagram's video cache paths.
    const/4 v2, 0x4

    invoke-virtual {p0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v0
    const-string v1, "fd"
    invoke-static {v0, v1, v2}, Lcom/feurstagram/FeurCacheCleaner;->dumpTree(Ljava/io/File;Ljava/lang/String;I)V

    invoke-virtual {p0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;
    move-result-object v0
    const-string v1, "cd"
    invoke-static {v0, v1, v2}, Lcom/feurstagram/FeurCacheCleaner;->dumpTree(Ljava/io/File;Ljava/lang/String;I)V

    invoke-virtual {p0}, Landroid/content/Context;->getExternalCacheDir()Ljava/io/File;
    move-result-object v0
    if-eqz v0, :skip_ext
    const-string v1, "ecd"
    invoke-static {v0, v1, v2}, Lcom/feurstagram/FeurCacheCleaner;->dumpTree(Ljava/io/File;Ljava/lang/String;I)V

    :skip_ext
    # Extra diagnostics for paths outside files/cache/externalCache.
    invoke-static {p0}, Lcom/feurstagram/FeurCacheCleaner;->dumpInterestingDataDirs(Landroid/content/Context;)V

    const-string v0, "dump: end"
    invoke-static {v0}, Lcom/feurstagram/FeurHooks;->log(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "dump: error"
    invoke-static {v1}, Lcom/feurstagram/FeurHooks;->log(Ljava/lang/String;)V
    return-void
.end method


.method private static dumpIfExists(Ljava/io/File;Ljava/lang/String;I)V
    .locals 1

    if-eqz p0, :end
    invoke-virtual {p0}, Ljava/io/File;->exists()Z
    move-result v0
    if-eqz v0, :end
    invoke-static {p0, p1, p2}, Lcom/feurstagram/FeurCacheCleaner;->dumpTree(Ljava/io/File;Ljava/lang/String;I)V

    :end
    return-void
.end method


# Dump additional app-private locations where Instagram may keep persisted
# reel metadata outside files/cache/externalCache.
.method private static dumpInterestingDataDirs(Landroid/content/Context;)V
    .locals 6

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    :try_start_0
    const/4 v5, 0x4

    # /data/.../databases
    const-string v0, "delivery_media_room_db"
    invoke-virtual {p0, v0}, Landroid/content/Context;->getDatabasePath(Ljava/lang/String;)Ljava/io/File;
    move-result-object v1
    if-eqz v1, :skip_db
    invoke-virtual {v1}, Ljava/io/File;->getParentFile()Ljava/io/File;
    move-result-object v2
    const-string v3, "db"
    invoke-static {v2, v3, v5}, Lcom/feurstagram/FeurCacheCleaner;->dumpIfExists(Ljava/io/File;Ljava/lang/String;I)V

    :skip_db
    # /data/.../no_backup
    invoke-virtual {p0}, Landroid/content/Context;->getNoBackupFilesDir()Ljava/io/File;
    move-result-object v2
    const-string v3, "nbd"
    invoke-static {v2, v3, v5}, Lcom/feurstagram/FeurCacheCleaner;->dumpIfExists(Ljava/io/File;Ljava/lang/String;I)V

    # /data/.../<app_*> and other top-level candidates.
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;
    move-result-object v0
    if-eqz v0, :end
    iget-object v0, v0, Landroid/content/pm/ApplicationInfo;->dataDir:Ljava/lang/String;
    if-eqz v0, :end
    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    new-instance v2, Ljava/io/File;
    const-string v0, "app_databases"
    invoke-direct {v2, v1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    const-string v3, "dd/app_databases"
    invoke-static {v2, v3, v5}, Lcom/feurstagram/FeurCacheCleaner;->dumpIfExists(Ljava/io/File;Ljava/lang/String;I)V

    new-instance v2, Ljava/io/File;
    const-string v0, "app_image_scoped"
    invoke-direct {v2, v1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    const-string v3, "dd/app_image_scoped"
    invoke-static {v2, v3, v5}, Lcom/feurstagram/FeurCacheCleaner;->dumpIfExists(Ljava/io/File;Ljava/lang/String;I)V

    new-instance v2, Ljava/io/File;
    const-string v0, "app_ras_blobs"
    invoke-direct {v2, v1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    const-string v3, "dd/app_ras_blobs"
    invoke-static {v2, v3, v5}, Lcom/feurstagram/FeurCacheCleaner;->dumpIfExists(Ljava/io/File;Ljava/lang/String;I)V

    new-instance v2, Ljava/io/File;
    const-string v0, "app_webview"
    invoke-direct {v2, v1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    const-string v3, "dd/app_webview"
    invoke-static {v2, v3, v5}, Lcom/feurstagram/FeurCacheCleaner;->dumpIfExists(Ljava/io/File;Ljava/lang/String;I)V

    new-instance v2, Ljava/io/File;
    const-string v0, "app_browser_proc_webview"
    invoke-direct {v2, v1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    const-string v3, "dd/app_browser_proc_webview"
    invoke-static {v2, v3, v5}, Lcom/feurstagram/FeurCacheCleaner;->dumpIfExists(Ljava/io/File;Ljava/lang/String;I)V

    new-instance v2, Ljava/io/File;
    const-string v0, "rendered_videos"
    invoke-direct {v2, v1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    const-string v3, "dd/rendered_videos"
    invoke-static {v2, v3, v5}, Lcom/feurstagram/FeurCacheCleaner;->dumpIfExists(Ljava/io/File;Ljava/lang/String;I)V

    new-instance v2, Ljava/io/File;
    const-string v0, "frame_capture"
    invoke-direct {v2, v1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    const-string v3, "dd/frame_capture"
    invoke-static {v2, v3, v5}, Lcom/feurstagram/FeurCacheCleaner;->dumpIfExists(Ljava/io/File;Ljava/lang/String;I)V

    new-instance v2, Ljava/io/File;
    const-string v0, "boomerang_frame_capture"
    invoke-direct {v2, v1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    const-string v3, "dd/boomerang_frame_capture"
    invoke-static {v2, v3, v5}, Lcom/feurstagram/FeurCacheCleaner;->dumpIfExists(Ljava/io/File;Ljava/lang/String;I)V

    new-instance v2, Ljava/io/File;
    const-string v0, "original_frame_capture"
    invoke-direct {v2, v1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    const-string v3, "dd/original_frame_capture"
    invoke-static {v2, v3, v5}, Lcom/feurstagram/FeurCacheCleaner;->dumpIfExists(Ljava/io/File;Ljava/lang/String;I)V

    :end
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v4
    const-string v0, "dump: extra error"
    invoke-static {v0}, Lcom/feurstagram/FeurHooks;->log(Ljava/lang/String;)V
    return-void
.end method


# Recursively dump entries under root, up to maxDepth. Logs one line per
# entry with the form "<prefix>/<relPath> <(d)|(size)>".
.method private static dumpTree(Ljava/io/File;Ljava/lang/String;I)V
    .locals 8

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    # Log this entry.
    invoke-static {p1, p0}, Lcom/feurstagram/FeurCacheCleaner;->logEntry(Ljava/lang/String;Ljava/io/File;)V

    if-lez p2, :return
    invoke-virtual {p0}, Ljava/io/File;->isDirectory()Z
    move-result v0
    if-eqz v0, :return

    invoke-virtual {p0}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v0
    if-eqz v0, :return

    array-length v1, v0
    const/4 v2, 0x0
    add-int/lit8 v7, p2, -0x1

    :loop
    if-ge v2, v1, :return
    aget-object v3, v0, v2

    # Build child prefix = p1 + "/" + child.getName()
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, "/"
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v5
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4

    invoke-static {v3, v4, v7}, Lcom/feurstagram/FeurCacheCleaner;->dumpTree(Ljava/io/File;Ljava/lang/String;I)V

    add-int/lit8 v2, v2, 0x1
    goto :loop

    :return
    return-void
.end method


.method private static logEntry(Ljava/lang/String;Ljava/io/File;)V
    .locals 6

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/io/File;->isDirectory()Z
    move-result v1
    if-eqz v1, :is_file

    const-string v2, " (d)"
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    goto :done

    :is_file
    const-string v2, " ("
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {p1}, Ljava/io/File;->length()J
    move-result-wide v2
    invoke-virtual {v0, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;
    const-string v4, "b)"
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    :done
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lcom/feurstagram/FeurHooks;->log(Ljava/lang/String;)V
    return-void
.end method


# Delete everything inside the directory, but keep the directory itself.
.method private static deleteContents(Ljava/io/File;)V
    .locals 4

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    invoke-virtual {p0}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v0
    if-eqz v0, :end

    array-length v1, v0
    const/4 v2, 0x0

    :loop
    if-ge v2, v1, :end
    aget-object v3, v0, v2
    invoke-static {v3}, Lcom/feurstagram/FeurCacheCleaner;->deleteRecursive(Ljava/io/File;)V
    add-int/lit8 v2, v2, 0x1
    goto :loop

    :end
    return-void
.end method


# Surgical wipe for filesDir: only delete subdirectories whose name looks
# like a media / video / prefetch cache, and never delete loose files
# (those often hold auth / session data). Every child is logged so we can
# refine the keyword list from logcat if needed.
.method private static wipeMediaCaches(Ljava/io/File;)V
    .locals 7

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    invoke-virtual {p0}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v0
    if-eqz v0, :end

    array-length v1, v0
    const/4 v2, 0x0

    :loop
    if-ge v2, v1, :end
    aget-object v3, v0, v2

    invoke-virtual {v3}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v4
    invoke-static {v4}, Lcom/feurstagram/FeurCacheCleaner;->logChild(Ljava/lang/String;)V

    # Only consider directories.
    invoke-virtual {v3}, Ljava/io/File;->isDirectory()Z
    move-result v5
    if-eqz v5, :next

    # Lowercase the name once for keyword matching.
    invoke-virtual {v4}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v6

    # Defensive skip list: anything that looks like auth / user / session
    # data stays untouched, even if it also matches a media keyword.
    invoke-static {v6}, Lcom/feurstagram/FeurCacheCleaner;->looksLikeAuth(Ljava/lang/String;)Z
    move-result v5
    if-nez v5, :next

    # Only wipe if the name matches a media / cache keyword.
    invoke-static {v6}, Lcom/feurstagram/FeurCacheCleaner;->looksLikeMediaCache(Ljava/lang/String;)Z
    move-result v5
    if-eqz v5, :next

    invoke-static {v3}, Lcom/feurstagram/FeurCacheCleaner;->logWipe(Ljava/lang/String;)V
    invoke-static {v3}, Lcom/feurstagram/FeurCacheCleaner;->deleteRecursive(Ljava/io/File;)V

    :next
    add-int/lit8 v2, v2, 0x1
    goto :loop

    :end
    return-void
.end method


.method private static logChild(Ljava/lang/String;)V
    .locals 2

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "fd: "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lcom/feurstagram/FeurHooks;->log(Ljava/lang/String;)V
    return-void
.end method


.method private static logWipe(Ljava/io/File;)V
    .locals 3

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "wipe: "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {p0}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lcom/feurstagram/FeurHooks;->log(Ljava/lang/String;)V
    return-void
.end method


# Returns true if the (lowercase) dir name contains any auth / user / session
# marker. Such directories are ALWAYS preserved.
.method private static looksLikeAuth(Ljava/lang/String;)Z
    .locals 2

    if-nez p0, :cond_ok
    const/4 v0, 0x0
    return v0

    :cond_ok
    const-string v0, "auth"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "session"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "login"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "token"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "account"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "cred"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "cookie"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "secure"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "profile"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "pref"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "mqtt"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "device"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "user"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const/4 v0, 0x0
    return v0

    :match
    const/4 v0, 0x1
    return v0
.end method


# Returns true if the (lowercase) dir name matches a media / video /
# prefetch cache pattern.
.method private static looksLikeMediaCache(Ljava/lang/String;)Z
    .locals 2

    if-nez p0, :cond_ok
    const/4 v0, 0x0
    return v0

    :cond_ok
    const-string v0, "cache"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "video"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "media"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "exo"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "clip"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "reel"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "story"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "prefetch"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "thumb"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "image"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "feed"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "blob"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "temp"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "tmp"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const-string v0, "download"
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :match

    const/4 v0, 0x0
    return v0

    :match
    const/4 v0, 0x1
    return v0
.end method


# Recursively delete a file or directory tree.
.method private static deleteRecursive(Ljava/io/File;)V
    .locals 4

    if-nez p0, :cond_ok
    return-void

    :cond_ok
    invoke-virtual {p0}, Ljava/io/File;->isDirectory()Z
    move-result v0
    if-eqz v0, :do_delete
    invoke-virtual {p0}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v0
    if-eqz v0, :do_delete
    array-length v1, v0
    const/4 v2, 0x0

    :loop
    if-ge v2, v1, :do_delete
    aget-object v3, v0, v2
    invoke-static {v3}, Lcom/feurstagram/FeurCacheCleaner;->deleteRecursive(Ljava/io/File;)V
    add-int/lit8 v2, v2, 0x1
    goto :loop

    :do_delete
    invoke-virtual {p0}, Ljava/io/File;->delete()Z
    return-void
.end method
