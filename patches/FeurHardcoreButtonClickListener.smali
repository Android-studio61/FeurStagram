.class public Lcom/feurstagram/FeurHardcoreButtonClickListener;
.super Ljava/lang/Object;
.implements Landroid/view/View$OnClickListener;

# Bridges View.OnClick to existing DialogInterface Permanent lock listener.


# instance fields
.field private mContext:Landroid/content/Context;
.field private mDialog:Landroid/app/Dialog;


.method public constructor <init>(Landroid/content/Context;Landroid/app/Dialog;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurHardcoreButtonClickListener;->mContext:Landroid/content/Context;
    iput-object p2, p0, Lcom/feurstagram/FeurHardcoreButtonClickListener;->mDialog:Landroid/app/Dialog;
    return-void
.end method


.method public onClick(Landroid/view/View;)V
    .locals 4

    iget-object v0, p0, Lcom/feurstagram/FeurHardcoreButtonClickListener;->mDialog:Landroid/app/Dialog;
    iget-object v1, p0, Lcom/feurstagram/FeurHardcoreButtonClickListener;->mContext:Landroid/content/Context;

    if-eqz v0, :skip_dismiss
    invoke-virtual {v0}, Landroid/app/Dialog;->dismiss()V

    :skip_dismiss
    new-instance v2, Lcom/feurstagram/FeurHardcoreClickListener;
    invoke-direct {v2, v1}, Lcom/feurstagram/FeurHardcoreClickListener;-><init>(Landroid/content/Context;)V
    const/4 v3, 0x0
    invoke-virtual {v2, v0, v3}, Lcom/feurstagram/FeurHardcoreClickListener;->onClick(Landroid/content/DialogInterface;I)V
    return-void
.end method
