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
    .locals 1

    iget-object v0, p0, Lcom/feurstagram/FeurSwitchListener;->mKey:Ljava/lang/String;
    invoke-static {v0, p2}, Lcom/feurstagram/FeurConfig;->setBlocked(Ljava/lang/String;Z)V
    return-void
.end method
