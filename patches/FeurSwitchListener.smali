.class public Lcom/feurstagram/FeurSwitchListener;
.super Ljava/lang/Object;
.implements Landroid/widget/CompoundButton$OnCheckedChangeListener;

# Per-row switch listener. Persists the toggled value immediately via
# FeurConfig.setBlocked using the preference key captured at construction.


# instance fields
.field private mKey:Ljava/lang/String;


.method public constructor <init>(Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurSwitchListener;->mKey:Ljava/lang/String;
    return-void
.end method


.method public onCheckedChanged(Landroid/widget/CompoundButton;Z)V
    .locals 3

    iget-object v0, p0, Lcom/feurstagram/FeurSwitchListener;->mKey:Ljava/lang/String;

    # Under the permanent lock, a block_* toggle may be tightened (turned on)
    # but never relaxed (turned off). If the user tries to switch one off,
    # snap it back on and skip persisting so the UI stays truthful.
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isHardcoreMode()Z
    move-result v1
    if-eqz v1, :persist
    if-nez p2, :persist
    if-eqz v0, :persist
    const-string v1, "block_"
    invoke-virtual {v0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :persist

    const/4 v1, 0x1
    invoke-virtual {p1, v1}, Landroid/widget/CompoundButton;->setChecked(Z)V
    return-void

    :persist
    invoke-static {v0, p2}, Lcom/feurstagram/FeurConfig;->setBlocked(Ljava/lang/String;Z)V
    return-void
.end method
