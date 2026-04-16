.class public Lcom/feurstagram/FeurDoneClickListener;
.super Ljava/lang/Object;
.implements Landroid/content/DialogInterface$OnClickListener;

# Positive ("Done") button listener: flushes the Instagram cache so
# pre-fetched feed/reels/stories/explore items disappear, then kills
# the process so Instagram relaunches with a clean state.


# instance fields
.field private mContext:Landroid/content/Context;


.method public constructor <init>(Landroid/content/Context;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/feurstagram/FeurDoneClickListener;->mContext:Landroid/content/Context;
    return-void
.end method


.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1

    iget-object v0, p0, Lcom/feurstagram/FeurDoneClickListener;->mContext:Landroid/content/Context;
    invoke-static {v0}, Lcom/feurstagram/FeurCacheCleaner;->clearAndRestart(Landroid/content/Context;)V
    return-void
.end method
