.class public Lcom/feurstagram/FeurHardcoreClickListener;
.super Ljava/lang/Object;
.implements Landroid/content/DialogInterface$OnClickListener;

# "Permanent lock" button listener in FeurSettings dialog.
# Opens a custom confirmation dialog matching the same visual language.


# instance fields
.field private mContext:Landroid/content/Context;


.method public constructor <init>(Landroid/content/Context;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurHardcoreClickListener;->mContext:Landroid/content/Context;
    return-void
.end method


.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 6

    iget-object v0, p0, Lcom/feurstagram/FeurHardcoreClickListener;->mContext:Landroid/content/Context;
    if-nez v0, :cond_has_ctx
    return-void

    :cond_has_ctx
    invoke-static {}, Lcom/feurstagram/FeurConfig;->isHardcoreMode()Z
    move-result v1
    if-eqz v1, :cond_show

    const-string v1, "Permanent lock is already enabled"
    const/4 v2, 0x1
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v1
    invoke-virtual {v1}, Landroid/widget/Toast;->show()V
    return-void

    :cond_show
    :try_start_0
    new-instance v1, Landroid/app/Dialog;
    invoke-direct {v1, v0}, Landroid/app/Dialog;-><init>(Landroid/content/Context;)V

    invoke-static {v0, v1}, Lcom/feurstagram/FeurHardcoreClickListener;->buildContent(Landroid/content/Context;Landroid/app/Dialog;)Landroid/view/View;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/app/Dialog;->setContentView(Landroid/view/View;)V

    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/app/Dialog;->setCanceledOnTouchOutside(Z)V

    invoke-virtual {v1}, Landroid/app/Dialog;->getWindow()Landroid/view/Window;
    move-result-object v3
    if-eqz v3, :cond_dialog_show

    new-instance v4, Landroid/graphics/drawable/ColorDrawable;
    const/4 v5, 0x0
    invoke-direct {v4, v5}, Landroid/graphics/drawable/ColorDrawable;-><init>(I)V
    invoke-virtual {v3, v4}, Landroid/view/Window;->setBackgroundDrawable(Landroid/graphics/drawable/Drawable;)V

    const/4 v4, -0x1
    const/4 v5, -0x2
    invoke-virtual {v3, v4, v5}, Landroid/view/Window;->setLayout(II)V

    const v4, 0x3f19999a    # 0.6f
    invoke-virtual {v3, v4}, Landroid/view/Window;->setDimAmount(F)V

    :cond_dialog_show
    invoke-virtual {v1}, Landroid/app/Dialog;->show()V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v1
    const-string v2, "Unable to open Permanent lock confirmation"
    const/4 v3, 0x1
    invoke-static {v0, v2, v3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v2
    invoke-virtual {v2}, Landroid/widget/Toast;->show()V
    return-void
.end method


.method private static buildContent(Landroid/content/Context;Landroid/app/Dialog;)Landroid/view/View;
    .locals 14

    const v0, -0xe3e4e1      # surface
    const v1, -0x191e1b      # on surface
    const v2, -0x353b30      # on surface variant
    const v3, -0xd474b       # error
    const v4, -0x9febf0      # on error

    new-instance v5, Landroid/widget/FrameLayout;
    invoke-direct {v5, p0}, Landroid/widget/FrameLayout;-><init>(Landroid/content/Context;)V

    const/high16 v6, 0x41c00000    # 24.0f
    invoke-static {p0, v6}, Lcom/feurstagram/FeurSettings;->dp(Landroid/content/Context;F)I
    move-result v6
    invoke-virtual {v5, v6, v6, v6, v6}, Landroid/widget/FrameLayout;->setPadding(IIII)V

    new-instance v7, Landroid/widget/LinearLayout;
    invoke-direct {v7, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v8, 0x1
    invoke-virtual {v7, v8}, Landroid/widget/LinearLayout;->setOrientation(I)V

    const/high16 v8, 0x41e00000    # 28.0f
    invoke-static {v0, v8, p0}, Lcom/feurstagram/FeurSettings;->roundedRect(IFLandroid/content/Context;)Landroid/graphics/drawable/GradientDrawable;
    move-result-object v8
    invoke-virtual {v7, v8}, Landroid/widget/LinearLayout;->setBackground(Landroid/graphics/drawable/Drawable;)V
    invoke-virtual {v7, v6, v6, v6, v6}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    new-instance v8, Landroid/widget/FrameLayout$LayoutParams;
    const/4 v9, -0x1
    const/4 v10, -0x2
    invoke-direct {v8, v9, v10}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v5, v7, v8}, Landroid/widget/FrameLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    new-instance v8, Landroid/widget/TextView;
    invoke-direct {v8, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v9, "Enable Permanent lock?"
    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/4 v9, 0x2
    const/high16 v10, 0x41b00000    # 22.0f
    invoke-virtual {v8, v9, v10}, Landroid/widget/TextView;->setTextSize(IF)V
    invoke-virtual {v8, v1}, Landroid/widget/TextView;->setTextColor(I)V
    const-string v9, "sans-serif-medium"
    const/4 v10, 0x0
    invoke-static {v9, v10}, Landroid/graphics/Typeface;->create(Ljava/lang/String;I)Landroid/graphics/Typeface;
    move-result-object v9
    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    invoke-virtual {v7, v8}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    new-instance v8, Landroid/widget/TextView;
    invoke-direct {v8, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v9, "This is permanent for this installation. You will no longer be able to re-enable Home Feed, Explore, Reels, or Stories without reinstalling the app."
    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/4 v9, 0x2
    const/high16 v10, 0x41600000    # 14.0f
    invoke-virtual {v8, v9, v10}, Landroid/widget/TextView;->setTextSize(IF)V
    invoke-virtual {v8, v2}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v9, 0x41400000    # 12.0f
    invoke-static {p0, v9}, Lcom/feurstagram/FeurSettings;->dp(Landroid/content/Context;F)I
    move-result v9
    const/4 v10, 0x0
    invoke-virtual {v8, v10, v9, v10, v10}, Landroid/widget/TextView;->setPadding(IIII)V
    invoke-virtual {v7, v8}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    new-instance v9, Landroid/widget/LinearLayout;
    invoke-direct {v9, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v10, 0x0
    invoke-virtual {v9, v10}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const v10, 0x800005
    invoke-virtual {v9, v10}, Landroid/widget/LinearLayout;->setGravity(I)V

    new-instance v10, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v11, -0x1
    const/4 v12, -0x2
    invoke-direct {v10, v11, v12}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/high16 v11, 0x41c00000    # 24.0f
    invoke-static {p0, v11}, Lcom/feurstagram/FeurSettings;->dp(Landroid/content/Context;F)I
    move-result v11
    const/4 v12, 0x0
    invoke-virtual {v10, v12, v11, v12, v12}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v7, v9, v10}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    const-string v10, "Cancel"
    const/4 v11, 0x0
    const/4 v12, 0x0
    invoke-static {p0, v10, v11, v2, v12}, Lcom/feurstagram/FeurSettings;->makeButton(Landroid/content/Context;Ljava/lang/String;IIZ)Landroid/widget/Button;
    move-result-object v10
    new-instance v11, Lcom/feurstagram/FeurCancelClickListener;
    invoke-direct {v11, p1}, Lcom/feurstagram/FeurCancelClickListener;-><init>(Landroid/app/Dialog;)V
    invoke-virtual {v10, v11}, Landroid/widget/Button;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v9, v10}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    new-instance v11, Landroid/view/View;
    invoke-direct {v11, p0}, Landroid/view/View;-><init>(Landroid/content/Context;)V
    const/high16 v12, 0x41000000    # 8.0f
    invoke-static {p0, v12}, Lcom/feurstagram/FeurSettings;->dp(Landroid/content/Context;F)I
    move-result v12
    new-instance v13, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v10, 0x1
    invoke-direct {v13, v12, v10}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v11, v13}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v9, v11}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    const-string v12, "Enable"
    const/4 v13, 0x1
    invoke-static {p0, v12, v3, v4, v13}, Lcom/feurstagram/FeurSettings;->makeButton(Landroid/content/Context;Ljava/lang/String;IIZ)Landroid/widget/Button;
    move-result-object v12
    new-instance v13, Lcom/feurstagram/FeurHardcoreConfirmButtonClickListener;
    invoke-direct {v13, p0, p1}, Lcom/feurstagram/FeurHardcoreConfirmButtonClickListener;-><init>(Landroid/content/Context;Landroid/app/Dialog;)V
    invoke-virtual {v12, v13}, Landroid/widget/Button;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v9, v12}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    return-object v5
.end method
