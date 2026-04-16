.class public Lcom/feurstagram/FeurSettingsLongClick;
.super Ljava/lang/Object;
.implements Landroid/view/View$OnLongClickListener;

# View long-click listener that opens the FeurStagram settings dialog.


.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public onLongClick(Landroid/view/View;)Z
    .locals 2

    const-string v0, "LONG-PRESS"
    invoke-static {v0}, Lcom/feurstagram/FeurHooks;->log(Ljava/lang/String;)V

    invoke-static {p1}, Lcom/feurstagram/FeurSettings;->getActivityContext(Landroid/view/View;)Landroid/content/Context;
    move-result-object v0

    if-nez v0, :cond_has_ctx
    const/4 v0, 0x0
    return v0

    :cond_has_ctx
    invoke-static {v0}, Lcom/feurstagram/FeurSettings;->show(Landroid/content/Context;)V
    const/4 v1, 0x1
    return v1
.end method
