package com.pichiplayer.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathFillType
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.pichiplayer.ui.theme.AppColors

/**
 * High-fidelity mathematical recreation of the PIchiPlayer emblem from brand specifications.
 * Features the electric blue (#4F8CFF) to subtle violet (#8B6CFF) diagonal gradient
 * on a rounded play triangle with an inner cinematic cutout.
 */
@Composable
fun PichiEmblem(
    size: Dp,
    modifier: Modifier = Modifier
) {
    Canvas(modifier = modifier.size(size)) {
        val w = this.size.width
        val h = this.size.height

        val brandBrush = Brush.linearGradient(
            colors = listOf(AppColors.electricBlue, AppColors.violetAccent),
            start = Offset(0f, 0f),
            end = Offset(w, h)
        )

        // Subtle ambient glow behind emblem
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(AppColors.electricBlueGlow, Color.Transparent),
                center = Offset(w * 0.45f, h * 0.5f),
                radius = w * 0.65f
            ),
            radius = w * 0.65f,
            center = Offset(w * 0.5f, h * 0.5f)
        )

        // Outer smooth play badge (Optically centered)
        val outerPath = Path().apply {
            val left = w * 0.20f
            val right = w * 0.84f
            val top = h * 0.16f
            val bottom = h * 0.84f
            val centerY = h * 0.5f
            val corner = w * 0.14f

            moveTo(left + corner, top)
            lineTo(right - corner, centerY - corner * 0.6f)
            quadraticTo(right, centerY, right - corner, centerY + corner * 0.6f)
            lineTo(left + corner, bottom)
            quadraticTo(left, bottom, left, bottom - corner)
            lineTo(left, top + corner)
            quadraticTo(left, top, left + corner, top)
            close()
        }

        // Inner triangular cutout (Optically centered)
        val innerPath = Path().apply {
            val inLeft = w * 0.38f
            val inRight = w * 0.68f
            val inTop = h * 0.34f
            val inBottom = h * 0.66f
            val inCenterY = h * 0.5f
            val inCorner = w * 0.05f

            moveTo(inLeft + inCorner, inTop)
            lineTo(inRight - inCorner, inCenterY - inCorner * 0.5f)
            quadraticTo(inRight, inCenterY, inRight - inCorner, inCenterY + inCorner * 0.5f)
            lineTo(inLeft + inCorner, inBottom)
            quadraticTo(inLeft, inBottom, inLeft, inBottom - inCorner)
            lineTo(inLeft, inTop + inCorner)
            quadraticTo(inLeft, inTop, inLeft + inCorner, inTop)
            close()
        }

        // Combined path using EvenOdd fill for perfect cutout
        val emblemPath = Path().apply {
            fillType = PathFillType.EvenOdd
            addPath(outerPath)
            addPath(innerPath)
        }

        drawPath(
            path = emblemPath,
            brush = brandBrush,
            style = Fill
        )

        // Subtle specular highlight stroke
        drawPath(
            path = outerPath,
            brush = Brush.linearGradient(
                colors = listOf(Color.White.copy(alpha = 0.25f), Color.Transparent),
                start = Offset(0f, 0f),
                end = Offset(w * 0.5f, h * 0.5f)
            ),
            style = Stroke(width = 1.5.dp.toPx())
        )
    }
}

/**
 * Standard PIchiPlayer Brand Header & Logo
 * Combines the geometric gradient emblem with the crisp dual-tone wordmark.
 */
@Composable
fun PichiLogo(
    modifier: Modifier = Modifier,
    emblemSize: Dp = 28.dp,
    fontSize: TextUnit = 21.sp,
    showWordmark: Boolean = true
) {
    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        PichiEmblem(size = emblemSize)

        if (showWordmark) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = "Pichi",
                    style = TextStyle(
                        fontFamily = FontFamily.SansSerif,
                        fontWeight = FontWeight.Bold,
                        fontSize = fontSize,
                        letterSpacing = (-0.4).sp,
                        color = AppColors.textPrimary
                    )
                )
                Text(
                    text = "Player",
                    style = TextStyle(
                        fontFamily = FontFamily.SansSerif,
                        fontWeight = FontWeight.Bold,
                        fontSize = fontSize,
                        letterSpacing = (-0.4).sp,
                        brush = AppColors.brandGradient
                    )
                )
            }
        }
    }
}
