.class public Lcom/feurstagram/FeurHardcoreConfirmClickListener;
.super Ljava/lang/Object;
.implements Landroid/content/DialogInterface$OnClickListener;

# Confirmation listener: enables irreversible Permanent lock.


# instance fields
.field private mContext:Landroid/content/Context;


.method public constructor <init>(Landroid/content/Context;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurHardcoreConfirmClickListener;->mContext:Landroid/content/Context;
    return-void
.end method


.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3

    invoke-static {}, Lcom/feurstagram/FeurConfig;->enableHardcoreMode()V

    iget-object v0, p0, Lcom/feurstagram/FeurHardcoreConfirmClickListener;->mContext:Landroid/content/Context;
    if-eqz v0, :end

    const-string v1, "Permanent lock enabled. Reinstall app to unlock content."
    const/4 v2, 0x1
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v1
    invoke-virtual {v1}, Landroid/widget/Toast;->show()V

    :end
    return-void
.end method
