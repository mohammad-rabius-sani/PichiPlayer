package com.pichiplayer.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AutoMode
import androidx.compose.material.icons.outlined.Check
import androidx.compose.material.icons.outlined.Memory
import androidx.compose.material.icons.outlined.Speed
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.pichiplayer.media.playback.DecoderMode
import com.pichiplayer.ui.theme.AppColors
import com.pichiplayer.ui.theme.AppTypography

@Composable
fun DecoderSelectionDialog(
    currentMode: DecoderMode,
    onSelectMode: (DecoderMode) -> Unit,
    onDismiss: () -> Unit
) {
    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth(0.92f)
                .clip(RoundedCornerShape(22.dp))
                .background(AppColors.backgroundElevated)
                .border(1.dp, AppColors.glassBorderSubtle, RoundedCornerShape(22.dp))
                .padding(22.dp)
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                // Top Icon
                Box(
                    modifier = Modifier
                        .size(54.dp)
                        .clip(CircleShape)
                        .background(AppColors.brandGradient)
                        .border(1.5.dp, AppColors.electricBlueBright, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Memory,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(28.dp)
                    )
                }

                // Title & Subtitle
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "Decoder Engine",
                        style = AppTypography.sectionHeader.copy(
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center
                        )
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Select how video streams are processed and rendered",
                        style = AppTypography.caption.copy(
                            color = AppColors.textSecondary,
                            textAlign = TextAlign.Center
                        )
                    )
                }

                // Options List
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    DecoderOptionRow(
                        mode = DecoderMode.AUTO,
                        badge = "Recommended",
                        badgeColor = AppColors.emerald,
                        icon = Icons.Outlined.AutoMode,
                        isSelected = currentMode == DecoderMode.AUTO,
                        onClick = {
                            onSelectMode(DecoderMode.AUTO)
                            onDismiss()
                        }
                    )

                    DecoderOptionRow(
                        mode = DecoderMode.HW,
                        badge = "High Speed",
                        badgeColor = AppColors.electricBlueBright,
                        icon = Icons.Outlined.Speed,
                        isSelected = currentMode == DecoderMode.HW,
                        onClick = {
                            onSelectMode(DecoderMode.HW)
                            onDismiss()
                        }
                    )

                    DecoderOptionRow(
                        mode = DecoderMode.SW,
                        badge = "Fallback",
                        badgeColor = AppColors.amberAccent,
                        icon = Icons.Outlined.Memory,
                        isSelected = currentMode == DecoderMode.SW,
                        onClick = {
                            onSelectMode(DecoderMode.SW)
                            onDismiss()
                        }
                    )
                }

                TextButton(
                    onClick = onDismiss,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = "Cancel",
                        style = AppTypography.cardTitle.copy(
                            color = AppColors.textSecondary,
                            fontSize = 14.sp
                        )
                    )
                }
            }
        }
    }
}

@Composable
private fun DecoderOptionRow(
    mode: DecoderMode,
    badge: String,
    badgeColor: Color,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    val borderColor = if (isSelected) AppColors.electricBlueBright else AppColors.glassBorderSubtle
    val bgColor = if (isSelected) AppColors.electricBlue.copy(alpha = 0.12f) else AppColors.surfaceSubtle

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(bgColor)
            .border(1.2.dp, borderColor, RoundedCornerShape(14.dp))
            .clickable(onClick = onClick)
            .padding(14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.weight(1f)
        ) {
            Box(
                modifier = Modifier
                    .size(38.dp)
                    .clip(CircleShape)
                    .background(if (isSelected) AppColors.electricBlue else AppColors.surfaceElevated),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = if (isSelected) Color.White else AppColors.textSecondary,
                    modifier = Modifier.size(20.dp)
                )
            }

            Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = mode.title,
                        style = AppTypography.cardTitle.copy(
                            fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = if (isSelected) AppColors.electricBlueBright else AppColors.textPrimary
                        )
                    )
                    PichiBadge(text = badge, highlight = isSelected, color = badgeColor)
                }
                Text(
                    text = mode.description,
                    style = AppTypography.caption.copy(
                        fontSize = 11.5.sp,
                        color = AppColors.textSecondary,
                        lineHeight = 15.sp
                    )
                )
            }
        }

        if (isSelected) {
            Icon(
                imageVector = Icons.Outlined.Check,
                contentDescription = "Selected",
                tint = AppColors.electricBlueBright,
                modifier = Modifier
                    .size(20.dp)
                    .padding(start = 6.dp)
            )
        }
    }
}
