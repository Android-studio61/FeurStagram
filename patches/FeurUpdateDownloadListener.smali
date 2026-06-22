.class public Lcom/feurstagram/FeurUpdateDownloadListener;
.super Ljava/lang/Object;
.implements Landroid/view/View$OnClickListener;

# "Download" button handler for the update dialog: opens the latest release
# page in a browser so the user can grab the new APK, then dismisses the dialog.


.field private mContext:Landroid/content/Context;
.field private mDialog:Landroid/app/Dialog;


.method public constructor <init>(Landroid/content/Context;Landroid/app/Dialog;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurUpdateDownloadListener;->mContext:Landroid/content/Context;
    iput-object p2, p0, Lcom/feurstagram/FeurUpdateDownloadListener;->mDialog:Landroid/app/Dialog;
    return-void
.end method


.method public onClick(Landroid/view/View;)V
    .locals 4

    iget-object v0, p0, Lcom/feurstagram/FeurUpdateDownloadListener;->mContext:Landroid/content/Context;
    if-nez v0, :cond_ok
    return-void

    :cond_ok
    :try_start_0
    new-instance v1, Landroid/content/Intent;
    const-string v2, "android.intent.action.VIEW"
    const-string v3, "https://github.com/jean-voila/FeurStagram/releases/latest"
    invoke-static {v3}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v3
    invoke-direct {v1, v2, v3}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V

    const/high16 v2, 0x10000000    # FLAG_ACTIVITY_NEW_TASK
    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    invoke-virtual {v0, v1}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    goto :dismiss

    :catch_0
    move-exception v1
    const-string v2, "No browser available"
    const/4 v3, 0x1
    invoke-static {v0, v2, v3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v2
    invoke-virtual {v2}, Landroid/widget/Toast;->show()V

    :dismiss
    iget-object v0, p0, Lcom/feurstagram/FeurUpdateDownloadListener;->mDialog:Landroid/app/Dialog;
    if-eqz v0, :end
    invoke-virtual {v0}, Landroid/app/Dialog;->dismiss()V

    :end
    return-void
.end method
