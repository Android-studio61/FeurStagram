.class public Lcom/feurstagram/FeurUpdateChecker;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

# FeurStagram update checker.
#
# On the first UI launch of each process, check() spins up a background thread
# that asks GitHub for the latest release of jean-voila/FeurStagram. If that
# release's tag (e.g. "v434-0-0-44-74") normalizes to a version newer than the
# installed Instagram versionName (e.g. "434.0.0.44.74"), it posts a
# FeurUpdatePrompt to the main thread to invite the user to download it.
#
# Guarded by sChecked so it runs at most once per process, and gated by the
# "auto_update" toggle (on by default) in FeurConfig.


# Set once check() has fired this process so we never nag twice per launch.
.field private static sChecked:Z

# Activity context used to build the update dialog on the main thread.
.field private mContext:Landroid/content/Context;


.method public constructor <init>(Landroid/content/Context;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurUpdateChecker;->mContext:Landroid/content/Context;
    return-void
.end method


# check(Context): kick off a one-shot background update check if enabled.
.method public static check(Landroid/content/Context;)V
    .locals 2

    if-nez p0, :cond_ctx
    return-void

    :cond_ctx
    # Run at most once per process.
    sget-boolean v0, Lcom/feurstagram/FeurUpdateChecker;->sChecked:Z
    if-eqz v0, :cond_first
    return-void

    :cond_first
    const/4 v0, 0x1
    sput-boolean v0, Lcom/feurstagram/FeurUpdateChecker;->sChecked:Z

    # Respect the user's toggle (default on).
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isAutoUpdateEnabled()Z
    move-result v0
    if-nez v0, :cond_enabled
    return-void

    :cond_enabled
    new-instance v0, Lcom/feurstagram/FeurUpdateChecker;
    invoke-direct {v0, p0}, Lcom/feurstagram/FeurUpdateChecker;-><init>(Landroid/content/Context;)V

    new-instance v1, Ljava/lang/Thread;
    invoke-direct {v1, v0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V
    invoke-virtual {v1}, Ljava/lang/Thread;->start()V
    return-void
.end method


# Background work: fetch the latest release tag and, if newer, prompt.
.method public run()V
    .locals 8

    :try_start_0
    new-instance v0, Ljava/net/URL;
    const-string v1, "https://api.github.com/repos/jean-voila/FeurStagram/releases/latest"
    invoke-direct {v0, v1}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;
    move-result-object v0
    check-cast v0, Ljava/net/HttpURLConnection;

    # GitHub rejects requests without a User-Agent.
    const-string v1, "User-Agent"
    const-string v2, "FeurStagram-UpdateCheck"
    invoke-virtual {v0, v1, v2}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "Accept"
    const-string v2, "application/vnd.github+json"
    invoke-virtual {v0, v1, v2}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    const/16 v1, 0x2710    # 10000 ms
    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V
    const/16 v1, 0x2710
    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setReadTimeout(I)V

    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;
    move-result-object v1

    # Read the whole response body with a Scanner using the start-of-input
    # delimiter "\A", which yields the entire stream as one token.
    new-instance v2, Ljava/util/Scanner;
    invoke-direct {v2, v1}, Ljava/util/Scanner;-><init>(Ljava/io/InputStream;)V
    const-string v3, "\\A"
    invoke-virtual {v2, v3}, Ljava/util/Scanner;->useDelimiter(Ljava/lang/String;)Ljava/util/Scanner;
    move-result-object v2

    invoke-virtual {v2}, Ljava/util/Scanner;->hasNext()Z
    move-result v3
    if-nez v3, :cond_has_body
    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->disconnect()V
    return-void

    :cond_has_body
    invoke-virtual {v2}, Ljava/util/Scanner;->next()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->disconnect()V

    new-instance v4, Lorg/json/JSONObject;
    invoke-direct {v4, v3}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V
    const-string v5, "tag_name"
    invoke-virtual {v4, v5}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4

    # "v434-0-0-44-74" -> "434.0.0.44.74"
    invoke-static {v4}, Lcom/feurstagram/FeurUpdateChecker;->normalize(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4

    iget-object v5, p0, Lcom/feurstagram/FeurUpdateChecker;->mContext:Landroid/content/Context;
    invoke-static {v5}, Lcom/feurstagram/FeurUpdateChecker;->currentVersion(Landroid/content/Context;)Ljava/lang/String;
    move-result-object v5

    invoke-static {v4, v5}, Lcom/feurstagram/FeurUpdateChecker;->isNewer(Ljava/lang/String;Ljava/lang/String;)Z
    move-result v6
    if-nez v6, :cond_update
    return-void

    :cond_update
    # Hop to the main thread to show the dialog.
    iget-object v5, p0, Lcom/feurstagram/FeurUpdateChecker;->mContext:Landroid/content/Context;
    new-instance v6, Landroid/os/Handler;
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v7
    invoke-direct {v6, v7}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    new-instance v7, Lcom/feurstagram/FeurUpdatePrompt;
    invoke-direct {v7, v5, v4}, Lcom/feurstagram/FeurUpdatePrompt;-><init>(Landroid/content/Context;Ljava/lang/String;)V
    invoke-virtual {v6, v7}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "update check failed"
    invoke-static {v1}, Lcom/feurstagram/FeurHooks;->log(Ljava/lang/String;)V
    return-void
.end method


# Strip a leading "v" and turn dashes into dots so a release tag like
# "v434-0-0-44-74" matches the installed versionName "434.0.0.44.74".
.method static normalize(Ljava/lang/String;)Ljava/lang/String;
    .locals 3

    move-object v0, p0

    const-string v1, "v"
    invoke-virtual {v0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :cond_no_v
    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v0

    :cond_no_v
    const-string v1, "-"
    const-string v2, "."
    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method


# Installed versionName (Instagram's), e.g. "434.0.0.44.74". "0" on failure.
.method static currentVersion(Landroid/content/Context;)Ljava/lang/String;
    .locals 3

    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v0
    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;
    move-result-object v1
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;
    move-result-object v0
    iget-object v0, v0, Landroid/content/pm/PackageInfo;->versionName:Ljava/lang/String;
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0
    return-object v0

    :catch_0
    move-exception v0
    const-string v0, "0"
    return-object v0
.end method


# isNewer(latest, installed): true if dotted version `latest` > `installed`,
# comparing segment by segment numerically (missing segments count as 0).
.method static isNewer(Ljava/lang/String;Ljava/lang/String;)Z
    .locals 8

    const-string v0, "\\."
    invoke-virtual {p0, v0}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v1
    invoke-virtual {p1, v0}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v2

    array-length v3, v1
    array-length v4, v2

    # v5 = max(len latest, len installed)
    if-le v3, v4, :cond_use_b
    move v5, v3
    goto :max_done
    :cond_use_b
    move v5, v4
    :max_done

    const/4 v6, 0x0    # i

    :loop
    if-lt v6, v5, :body
    # all segments equal -> not newer
    const/4 v0, 0x0
    return v0

    :body
    invoke-static {v1, v6}, Lcom/feurstagram/FeurUpdateChecker;->seg([Ljava/lang/String;I)I
    move-result v7
    invoke-static {v2, v6}, Lcom/feurstagram/FeurUpdateChecker;->seg([Ljava/lang/String;I)I
    move-result v0

    if-le v7, v0, :cond_not_gt
    const/4 v0, 0x1
    return v0

    :cond_not_gt
    if-ge v7, v0, :cond_eq
    const/4 v0, 0x0
    return v0

    :cond_eq
    add-int/lit8 v6, v6, 0x1
    goto :loop
.end method


# seg(parts, index): the integer value of parts[index], or 0 if out of range
# or not a number.
.method static seg([Ljava/lang/String;I)I
    .locals 1

    array-length v0, p0
    if-lt p1, v0, :cond_in
    const/4 v0, 0x0
    return v0

    :cond_in
    :try_start_0
    aget-object v0, p0, p1
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v0
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0
    return v0

    :catch_0
    move-exception v0
    const/4 v0, 0x0
    return v0
.end method
