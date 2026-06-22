.class public Lcom/feurstagram/FeurLandingWatcher;
.super Ljava/lang/Object;
.implements Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;

# Redirects the app to the user-chosen landing surface on cold start.
#
# Installed alongside the Home-tab watcher on the main tab_bar. On the first
# layout passes it resolves the target tab by resource name (search_tab /
# direct_tab / profile_tab), performs a click to switch to it, and detaches.
# An instance flag makes it fire at most once per watcher, so within a session
# it never fights the user once they navigate away. Because a new watcher is
# created on every tab-bar (re)build, each fresh app entry re-arms it. "home"
# is the default and needs no redirect.


# Fired-once guard, per instance. A fresh watcher is created every time the
# main activity rebuilds its tab bar, so each genuine app entry re-arms the
# redirect; a process-wide static flag would wrongly suppress it whenever
# Android keeps the process alive across an app close/reopen.
.field private mDone:Z

# The tab_bar ViewGroup we were attached to.
.field private mContainer:Landroid/view/ViewGroup;

# Bounded retries while the target tab is still being inflated.
.field private mAttempts:I


.method public constructor <init>(Landroid/view/ViewGroup;)V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurLandingWatcher;->mContainer:Landroid/view/ViewGroup;
    const/4 v0, 0x0
    iput v0, p0, Lcom/feurstagram/FeurLandingWatcher;->mAttempts:I
    iput-boolean v0, p0, Lcom/feurstagram/FeurLandingWatcher;->mDone:Z
    return-void
.end method


# Resolve a resource id by name under the running app's package, falling back
# to "com.instagram.android" for --clone builds. Returns 0 if not found.
.method private static resolveId(Landroid/content/Context;Ljava/lang/String;)I
    .locals 5

    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;
    move-result-object v0

    const-string v1, "id"

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v0, p1, v1, v2}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
    move-result v3

    if-nez v3, :return

    const-string v2, "com.instagram.android"
    invoke-virtual {v0, p1, v1, v2}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
    move-result v3

    :return
    return v3
.end method


# Stop listening and release the container reference.
.method private detach()V
    .locals 2

    iget-object v0, p0, Lcom/feurstagram/FeurLandingWatcher;->mContainer:Landroid/view/ViewGroup;
    if-eqz v0, :done

    invoke-virtual {v0}, Landroid/view/ViewGroup;->getViewTreeObserver()Landroid/view/ViewTreeObserver;
    move-result-object v1
    invoke-virtual {v1, p0}, Landroid/view/ViewTreeObserver;->removeOnGlobalLayoutListener(Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;)V

    const/4 v1, 0x0
    iput-object v1, p0, Lcom/feurstagram/FeurLandingWatcher;->mContainer:Landroid/view/ViewGroup;

    :done
    return-void
.end method


.method public onGlobalLayout()V
    .locals 6

    # Already handled by this watcher: unhook and stop.
    iget-boolean v0, p0, Lcom/feurstagram/FeurLandingWatcher;->mDone:Z
    if-eqz v0, :cond_go
    invoke-direct {p0}, Lcom/feurstagram/FeurLandingWatcher;->detach()V
    return-void

    :cond_go
    iget-object v0, p0, Lcom/feurstagram/FeurLandingWatcher;->mContainer:Landroid/view/ViewGroup;
    if-nez v0, :have_container
    return-void

    :have_container
    invoke-virtual {v0}, Landroid/view/ViewGroup;->getContext()Landroid/content/Context;
    move-result-object v1
    if-nez v1, :have_ctx
    return-void

    :have_ctx
    invoke-static {}, Lcom/feurstagram/FeurConfig;->getLandingPage()Ljava/lang/String;
    move-result-object v2

    const-string v3, "search"
    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-eqz v4, :not_search
    const-string v2, "search_tab"
    goto :have_target

    :not_search
    const-string v3, "direct"
    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-eqz v4, :not_direct
    const-string v2, "direct_tab"
    goto :have_target

    :not_direct
    const-string v3, "profile"
    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-eqz v4, :no_redirect
    const-string v2, "profile_tab"
    goto :have_target

    :no_redirect
    # "home" or anything unknown: nothing to do, stop listening.
    const/4 v2, 0x1
    iput-boolean v2, p0, Lcom/feurstagram/FeurLandingWatcher;->mDone:Z
    invoke-direct {p0}, Lcom/feurstagram/FeurLandingWatcher;->detach()V
    return-void

    :have_target
    # v2 = target resource name. Search the whole window so action-bar entries
    # (e.g. the DM inbox) are reachable too, not just the bottom tab_bar.
    invoke-virtual {v0}, Landroid/view/ViewGroup;->getRootView()Landroid/view/View;
    move-result-object v3
    if-nez v3, :have_root
    return-void

    :have_root
    invoke-static {v1, v2}, Lcom/feurstagram/FeurLandingWatcher;->resolveId(Landroid/content/Context;Ljava/lang/String;)I
    move-result v4
    if-nez v4, :have_id
    # Id not present in this build: give up permanently.
    const/4 v4, 0x1
    iput-boolean v4, p0, Lcom/feurstagram/FeurLandingWatcher;->mDone:Z
    invoke-direct {p0}, Lcom/feurstagram/FeurLandingWatcher;->detach()V
    return-void

    :have_id
    invoke-virtual {v3, v4}, Landroid/view/View;->findViewById(I)Landroid/view/View;
    move-result-object v5
    if-nez v5, :have_view

    # Target not laid out yet: retry up to a bound, then give up.
    iget v4, p0, Lcom/feurstagram/FeurLandingWatcher;->mAttempts:I
    add-int/lit8 v4, v4, 0x1
    iput v4, p0, Lcom/feurstagram/FeurLandingWatcher;->mAttempts:I
    const/16 v0, 0x28
    if-lt v4, v0, :wait_more
    const/4 v4, 0x1
    iput-boolean v4, p0, Lcom/feurstagram/FeurLandingWatcher;->mDone:Z
    invoke-direct {p0}, Lcom/feurstagram/FeurLandingWatcher;->detach()V

    :wait_more
    return-void

    :have_view
    # Switch surface once, then unhook.
    const/4 v0, 0x1
    iput-boolean v0, p0, Lcom/feurstagram/FeurLandingWatcher;->mDone:Z
    invoke-virtual {v5}, Landroid/view/View;->performClick()Z
    invoke-direct {p0}, Lcom/feurstagram/FeurLandingWatcher;->detach()V
    return-void
.end method
