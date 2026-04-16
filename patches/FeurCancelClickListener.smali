.class public Lcom/feurstagram/FeurCancelClickListener;
.super Ljava/lang/Object;
.implements Landroid/view/View$OnClickListener;

# Dismisses the custom dialog on button tap.


# instance fields
.field private mDialog:Landroid/app/Dialog;


.method public constructor <init>(Landroid/app/Dialog;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurCancelClickListener;->mDialog:Landroid/app/Dialog;
    return-void
.end method


.method public onClick(Landroid/view/View;)V
    .locals 1

    iget-object v0, p0, Lcom/feurstagram/FeurCancelClickListener;->mDialog:Landroid/app/Dialog;
    if-eqz v0, :end
    invoke-virtual {v0}, Landroid/app/Dialog;->dismiss()V

    :end
    return-void
.end method
