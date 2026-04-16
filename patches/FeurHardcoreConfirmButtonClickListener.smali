.class public Lcom/feurstagram/FeurHardcoreConfirmButtonClickListener;
.super Ljava/lang/Object;
.implements Landroid/view/View$OnClickListener;

# Bridges View.OnClick to existing DialogInterface confirmation listener.


# instance fields
.field private mContext:Landroid/content/Context;
.field private mDialog:Landroid/app/Dialog;


.method public constructor <init>(Landroid/content/Context;Landroid/app/Dialog;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurHardcoreConfirmButtonClickListener;->mContext:Landroid/content/Context;
    iput-object p2, p0, Lcom/feurstagram/FeurHardcoreConfirmButtonClickListener;->mDialog:Landroid/app/Dialog;
    return-void
.end method


.method public onClick(Landroid/view/View;)V
    .locals 4

    iget-object v0, p0, Lcom/feurstagram/FeurHardcoreConfirmButtonClickListener;->mDialog:Landroid/app/Dialog;
    iget-object v1, p0, Lcom/feurstagram/FeurHardcoreConfirmButtonClickListener;->mContext:Landroid/content/Context;

    if-eqz v0, :skip_dismiss
    invoke-virtual {v0}, Landroid/app/Dialog;->dismiss()V

    :skip_dismiss
    new-instance v2, Lcom/feurstagram/FeurHardcoreConfirmClickListener;
    invoke-direct {v2, v1}, Lcom/feurstagram/FeurHardcoreConfirmClickListener;-><init>(Landroid/content/Context;)V
    const/4 v3, 0x0
    invoke-virtual {v2, v0, v3}, Lcom/feurstagram/FeurHardcoreConfirmClickListener;->onClick(Landroid/content/DialogInterface;I)V
    return-void
.end method
