package com.feurstagram.extension;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;

/**
 * The Material Symbols "tune" glyph, drawn in code so the action-bar settings
 * button needs no bundled drawable resource. The path is the official 24dp
 * "tune" outline (three horizontal sliders), filled in a single colour to match
 * Instagram's other action-bar icons.
 */
public final class SettingsIcon extends Drawable {

    // Each row is one closed sub-path of the 24x24 "tune" glyph, as (x,y) pairs.
    private static final float[][] GLYPH = {
            {3, 17, 3, 19, 9, 19, 9, 17},
            {3, 5, 3, 7, 13, 7, 13, 5},
            {13, 21, 13, 19, 21, 19, 21, 17, 13, 17, 13, 15, 11, 15, 11, 21},
            {7, 9, 7, 11, 3, 11, 3, 13, 7, 13, 7, 15, 9, 15, 9, 9},
            {21, 13, 21, 11, 11, 11, 11, 13},
            {15, 9, 17, 9, 17, 7, 21, 7, 21, 5, 17, 5, 17, 3, 15, 3},
    };

    private final Paint paint;
    private final int sizePx;

    public SettingsIcon(Context context, int color) {
        float density = context.getResources().getDisplayMetrics().density;
        this.sizePx = Math.round(24 * density);
        this.paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(color);
        paint.setStyle(Paint.Style.FILL);
    }

    @Override
    public int getIntrinsicWidth() {
        return sizePx;
    }

    @Override
    public int getIntrinsicHeight() {
        return sizePx;
    }

    @Override
    public void draw(Canvas canvas) {
        Rect bounds = getBounds();
        float unit = Math.min(bounds.width(), bounds.height()) / 24f;
        float ox = bounds.left;
        float oy = bounds.top;

        Path path = new Path();
        path.setFillType(Path.FillType.WINDING);
        for (float[] subPath : GLYPH) {
            path.moveTo(ox + subPath[0] * unit, oy + subPath[1] * unit);
            for (int i = 2; i < subPath.length; i += 2) {
                path.lineTo(ox + subPath[i] * unit, oy + subPath[i + 1] * unit);
            }
            path.close();
        }
        canvas.drawPath(path, paint);
    }

    @Override
    public void setAlpha(int alpha) {
        paint.setAlpha(alpha);
    }

    @Override
    public void setColorFilter(ColorFilter colorFilter) {
        paint.setColorFilter(colorFilter);
    }

    @Override
    public int getOpacity() {
        return PixelFormat.TRANSLUCENT;
    }
}
