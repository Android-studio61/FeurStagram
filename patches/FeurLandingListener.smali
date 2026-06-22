.class public Lcom/feurstagram/FeurLandingListener;
.super Ljava/lang/Object;
.implements Landroid/widget/RadioGroup$OnCheckedChangeListener;

# Persists the landing-page choice when one of the radio options is picked.
# The RadioButton id encodes the value (1=home, 2=search, 3=direct, 4=profile).


.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public onCheckedChanged(Landroid/widget/RadioGroup;I)V
    .locals 1

    const/4 v0, 0x1
    if-ne p2, v0, :cond_search
    const-string v0, "home"
    goto :set

    :cond_search
    const/4 v0, 0x2
    if-ne p2, v0, :cond_direct
    const-string v0, "search"
    goto :set

    :cond_direct
    const/4 v0, 0x3
    if-ne p2, v0, :cond_profile
    const-string v0, "direct"
    goto :set

    :cond_profile
    const-string v0, "profile"

    :set
    invoke-static {v0}, Lcom/feurstagram/FeurConfig;->setLandingPage(Ljava/lang/String;)V
    return-void
.end method
