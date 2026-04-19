.class public Lcom/feurstagram/FeurHomeTabWatcher;
.super Ljava/lang/Object;
.implements Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;

# Watches the bottom tab_bar ViewGroup until the "feed_tab" child (the Home
# button at the bottom-left) has been inflated, then installs our long-press
# listener on it and detaches itself. Resolving the id via
# Resources.getIdentifier lets us survive Instagram version bumps that shuffle
# hex resource ids.


# instance fields
.field private mContainer:Landroid/view/ViewGroup;


# direct methods
.method public constructor <init>(Landroid/view/ViewGroup;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurHomeTabWatcher;->mContainer:Landroid/view/ViewGroup;
    return-void
.end method


# virtual methods
.method public onGlobalLayout()V
    .locals 7

    iget-object v0, p0, Lcom/feurstagram/FeurHomeTabWatcher;->mContainer:Landroid/view/ViewGroup;
    if-nez v0, :cond_has_container
    return-void

    :cond_has_container
    # Resolve "feed_tab" id dynamically: Instagram shuffles hex ids between
    # versions, but the resource name is stable.
    invoke-virtual {v0}, Landroid/view/ViewGroup;->getContext()Landroid/content/Context;
    move-result-object v1
    if-nez v1, :cond_has_ctx
    return-void

    :cond_has_ctx
    invoke-virtual {v1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;
    move-result-object v2

    const-string v4, "feed_tab"
    const-string v5, "id"

    # Look the id up under the running app's package first.
    invoke-virtual {v1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2, v4, v5, v3}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
    move-result v6

    if-nez v6, :cond_has_id

    # Under --clone, the app id is e.g. "com.instagram.android.feurstagram"
    # but resources.arsc still declares "com.instagram.android" as the
    # resource package, so the first lookup returns 0. Retry under the
    # Instagram resource package.
    const-string v3, "com.instagram.android"
    invoke-virtual {v2, v4, v5, v3}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
    move-result v6

    if-nez v6, :cond_has_id
    # Resource not found yet; keep waiting.
    return-void

    :cond_has_id
    invoke-virtual {v0, v6}, Landroid/view/ViewGroup;->findViewById(I)Landroid/view/View;
    move-result-object v3
    if-nez v3, :cond_found
    # feed_tab not yet inflated; keep waiting.
    return-void

    :cond_found
    # Found the Home tab - attach long-click and detach ourselves.
    invoke-static {v3}, Lcom/feurstagram/FeurSettings;->attachLongPress(Landroid/view/View;)V

    invoke-virtual {v0}, Landroid/view/ViewGroup;->getViewTreeObserver()Landroid/view/ViewTreeObserver;
    move-result-object v4
    invoke-virtual {v4, p0}, Landroid/view/ViewTreeObserver;->removeOnGlobalLayoutListener(Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;)V

    const/4 v5, 0x0
    iput-object v5, p0, Lcom/feurstagram/FeurHomeTabWatcher;->mContainer:Landroid/view/ViewGroup;
    return-void
.end method
