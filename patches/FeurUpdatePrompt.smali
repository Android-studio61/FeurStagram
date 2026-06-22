.class public Lcom/feurstagram/FeurUpdatePrompt;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

# Shown on the main thread when FeurUpdateChecker finds a newer release.
# Builds a custom dialog in the same Material 3 dark style as the FeurStagram
# settings page (rounded surface card, no resources), reusing the FeurSettings
# dp / roundedRect / makeButton helpers so the look stays consistent.


.field private mContext:Landroid/content/Context;
.field private mVersion:Ljava/lang/String;


.method public constructor <init>(Landroid/content/Context;Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurUpdatePrompt;->mContext:Landroid/content/Context;
    iput-object p2, p0, Lcom/feurstagram/FeurUpdatePrompt;->mVersion:Ljava/lang/String;
    return-void
.end method


.method public run()V
    .locals 5

    iget-object v0, p0, Lcom/feurstagram/FeurUpdatePrompt;->mContext:Landroid/content/Context;
    if-nez v0, :cond_ok
    return-void

    :cond_ok
    :try_start_0
    new-instance v1, Landroid/app/Dialog;
    invoke-direct {v1, v0}, Landroid/app/Dialog;-><init>(Landroid/content/Context;)V

    # No title bar - the card carries its own title, like the settings dialog.
    const/4 v2, 0x1                       # Window.FEATURE_NO_TITLE
    invoke-virtual {v1, v2}, Landroid/app/Dialog;->requestWindowFeature(I)Z

    invoke-direct {p0, v0, v1}, Lcom/feurstagram/FeurUpdatePrompt;->buildContent(Landroid/content/Context;Landroid/app/Dialog;)Landroid/view/View;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/app/Dialog;->setContentView(Landroid/view/View;)V

    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/app/Dialog;->setCanceledOnTouchOutside(Z)V

    invoke-virtual {v1}, Landroid/app/Dialog;->getWindow()Landroid/view/Window;
    move-result-object v2
    if-eqz v2, :cond_show

    # Transparent window so only the rounded card shows, with a dim scrim
    # behind it - identical to the old settings dialog.
    new-instance v3, Landroid/graphics/drawable/ColorDrawable;
    const/4 v4, 0x0
    invoke-direct {v3, v4}, Landroid/graphics/drawable/ColorDrawable;-><init>(I)V
    invoke-virtual {v2, v3}, Landroid/view/Window;->setBackgroundDrawable(Landroid/graphics/drawable/Drawable;)V

    const/4 v3, -0x1                       # MATCH_PARENT width
    const/4 v4, -0x2                       # WRAP_CONTENT height
    invoke-virtual {v2, v3, v4}, Landroid/view/Window;->setLayout(II)V

    const v3, 0x3f19999a                   # 0.6f dim
    invoke-virtual {v2, v3}, Landroid/view/Window;->setDimAmount(F)V

    :cond_show
    invoke-virtual {v1}, Landroid/app/Dialog;->show()V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    return-void
.end method


# Builds the dialog's rounded surface card: title, message, and a right-aligned
# Later / Download button row.
.method private buildContent(Landroid/content/Context;Landroid/app/Dialog;)Landroid/view/View;
    .locals 9

    # 24dp padding used for both the outer frame and the card.
    const/high16 v0, 0x41c00000    # 24.0f
    invoke-static {p1, v0}, Lcom/feurstagram/FeurSettings;->dp(Landroid/content/Context;F)I
    move-result v0

    # ---- outer frame (gives the card breathing room from screen edges) ----
    new-instance v1, Landroid/widget/FrameLayout;
    invoke-direct {v1, p1}, Landroid/widget/FrameLayout;-><init>(Landroid/content/Context;)V
    invoke-virtual {v1, v0, v0, v0, v0}, Landroid/widget/FrameLayout;->setPadding(IIII)V

    # ---- rounded surface card ----
    new-instance v2, Landroid/widget/LinearLayout;
    invoke-direct {v2, p1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V

    const v3, -0xe3e4e1            # surface
    const/high16 v4, 0x41e00000    # 28.0f corner radius
    invoke-static {v3, v4, p1}, Lcom/feurstagram/FeurSettings;->roundedRect(IFLandroid/content/Context;)Landroid/graphics/drawable/GradientDrawable;
    move-result-object v3
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setBackground(Landroid/graphics/drawable/Drawable;)V
    invoke-virtual {v2, v0, v0, v0, v0}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    new-instance v3, Landroid/widget/FrameLayout$LayoutParams;
    const/4 v4, -0x1
    const/4 v5, -0x2
    invoke-direct {v3, v4, v5}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v1, v2, v3}, Landroid/widget/FrameLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    # ---- title ----
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, p1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, "Update available"
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/4 v4, 0x2
    const/high16 v5, 0x41b00000    # 22.0f
    invoke-virtual {v3, v4, v5}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x191e1b            # on surface
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const-string v5, "sans-serif-medium"
    const/4 v6, 0x0
    invoke-static {v5, v6}, Landroid/graphics/Typeface;->create(Ljava/lang/String;I)Landroid/graphics/Typeface;
    move-result-object v5
    invoke-virtual {v3, v5}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ---- message ("FeurStagram <ver> is available. Tap Download to update.") ----
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, p1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "FeurStagram "
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget-object v5, p0, Lcom/feurstagram/FeurUpdatePrompt;->mVersion:Ljava/lang/String;
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, " is available. Tap Download to update."
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/4 v4, 0x2
    const/high16 v5, 0x41600000    # 14.0f
    invoke-virtual {v3, v4, v5}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x353b30            # on surface variant
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v5, 0x41000000    # 8.0f top padding
    invoke-static {p1, v5}, Lcom/feurstagram/FeurSettings;->dp(Landroid/content/Context;F)I
    move-result v5
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v5, v6, v6}, Landroid/widget/TextView;->setPadding(IIII)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ---- button row (right-aligned) ----
    new-instance v3, Landroid/widget/LinearLayout;
    invoke-direct {v3, p1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v4, 0x0
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const v4, 0x800005             # Gravity.END
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->setGravity(I)V

    # Later (subtle surface-container button) - just dismisses.
    const-string v4, "Later"
    const v5, -0xd4d6d0            # surface container
    const v6, -0x353b30            # on surface variant
    const/4 v7, 0x0
    invoke-static {p1, v4, v5, v6, v7}, Lcom/feurstagram/FeurSettings;->makeButton(Landroid/content/Context;Ljava/lang/String;IIZ)Landroid/widget/Button;
    move-result-object v4
    new-instance v5, Lcom/feurstagram/FeurCancelClickListener;
    invoke-direct {v5, p2}, Lcom/feurstagram/FeurCancelClickListener;-><init>(Landroid/app/Dialog;)V
    invoke-virtual {v4, v5}, Landroid/widget/Button;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # spacer between the two buttons
    new-instance v4, Landroid/view/View;
    invoke-direct {v4, p1}, Landroid/view/View;-><init>(Landroid/content/Context;)V
    const/high16 v5, 0x41000000    # 8.0f
    invoke-static {p1, v5}, Lcom/feurstagram/FeurSettings;->dp(Landroid/content/Context;F)I
    move-result v5
    new-instance v6, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v7, 0x1
    invoke-direct {v6, v5, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v4, v6}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Download (primary filled button) - opens the release page, then dismisses.
    const-string v4, "Download"
    const v5, -0x2f4301            # primary
    const v6, -0xc8e18d            # on primary
    const/4 v7, 0x0
    invoke-static {p1, v4, v5, v6, v7}, Lcom/feurstagram/FeurSettings;->makeButton(Landroid/content/Context;Ljava/lang/String;IIZ)Landroid/widget/Button;
    move-result-object v4
    new-instance v5, Lcom/feurstagram/FeurUpdateDownloadListener;
    invoke-direct {v5, p1, p2}, Lcom/feurstagram/FeurUpdateDownloadListener;-><init>(Landroid/content/Context;Landroid/app/Dialog;)V
    invoke-virtual {v4, v5}, Landroid/widget/Button;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # add the button row with a 20dp top margin
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v5, -0x1
    const/4 v6, -0x2
    invoke-direct {v4, v5, v6}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/high16 v5, 0x41a00000    # 20.0f
    invoke-static {p1, v5}, Lcom/feurstagram/FeurSettings;->dp(Landroid/content/Context;F)I
    move-result v5
    const/4 v6, 0x0
    invoke-virtual {v4, v6, v5, v6, v6}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v2, v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    return-object v1
.end method
