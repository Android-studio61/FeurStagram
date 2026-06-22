.class public Lcom/feurstagram/FeurSettingsCancelListener;
.super Ljava/lang/Object;
.implements Landroid/content/DialogInterface$OnCancelListener;

# When the settings page is dismissed via Back, if a setting was changed this
# session we clear the Instagram cache and restart instead of dropping the user
# back into the now-stale app. Using OnCancelListener (rather than a key
# listener) means it fires for both the legacy Back key and the Android 13+
# predictive-back gesture, which never reaches an OnKeyListener.


# instance fields
.field private mContext:Landroid/content/Context;


.method public constructor <init>(Landroid/content/Context;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurSettingsCancelListener;->mContext:Landroid/content/Context;
    return-void
.end method


.method public onCancel(Landroid/content/DialogInterface;)V
    .locals 1

    invoke-static {}, Lcom/feurstagram/FeurConfig;->isRestartPending()Z
    move-result v0
    if-eqz v0, :done

    iget-object v0, p0, Lcom/feurstagram/FeurSettingsCancelListener;->mContext:Landroid/content/Context;
    if-eqz v0, :done
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->clearAndRestart(Landroid/content/Context;)V

    :done
    return-void
.end method
