package com.pichiplayer.ui.components

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.CloudDownload
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.outlined.CheckCircle
import androidx.compose.material.icons.outlined.OpenInBrowser
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.pichiplayer.data.update.AppUpdateInfo
import com.pichiplayer.ui.theme.AppColors
import com.pichiplayer.ui.theme.AppTypography

@Composable
fun UpdateDialog(
    updateInfo: AppUpdateInfo,
    isUpdateAvailable: Boolean,
    onDismiss: () -> Unit
) {
    val context = LocalContext.current

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
                verticalArrangement = Arrangement.spacedBy(14.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
            ) {
                // Top Glowing Icon
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(CircleShape)
                        .background(AppColors.brandGradient)
                        .border(1.5.dp, AppColors.electricBlueBright, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = if (isUpdateAvailable) Icons.Default.CloudDownload else Icons.Outlined.CheckCircle,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(28.dp)
                    )
                }

                // Title & Version Badge
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = if (isUpdateAvailable) "Update Available!" else "You're Up to Date",
                        style = AppTypography.sectionHeader.copy(
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center
                        )
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    PichiBadge(
                        text = "v${updateInfo.versionName} • ${updateInfo.apkSize}",
                        highlight = true,
                        color = if (isUpdateAvailable) AppColors.brandPrimary else AppColors.emerald
                    )
                }

                // Custom Message
                Text(
                    text = updateInfo.message,
                    style = AppTypography.bodyMedium.copy(
                        color = AppColors.textSecondary,
                        textAlign = TextAlign.Center,
                        lineHeight = 20.sp
                    ),
                    modifier = Modifier.padding(horizontal = 4.dp)
                )

                // Changelog Card
                if (updateInfo.changelog.isNotEmpty()) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(14.dp))
                            .background(AppColors.surfaceSubtle)
                            .border(1.dp, AppColors.glassBorderSubtle, RoundedCornerShape(14.dp))
                            .padding(14.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(
                            text = "WHAT'S NEW IN THIS RELEASE",
                            style = AppTypography.caption.copy(
                                fontWeight = FontWeight.Bold,
                                color = AppColors.electricBlueBright,
                                fontSize = 11.sp
                            )
                        )
                        updateInfo.changelog.forEach { logItem ->
                            Row(
                                verticalAlignment = Alignment.Top,
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                Text(
                                    text = "•",
                                    color = AppColors.electricBlueBright,
                                    fontWeight = FontWeight.Bold
                                )
                                Text(
                                    text = logItem,
                                    style = AppTypography.caption.copy(
                                        color = AppColors.textPrimary,
                                        lineHeight = 18.sp
                                    )
                                )
                            }
                        }
                    }
                }

                // Buttons
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    if (isUpdateAvailable) {
                        PichiButton(
                            text = "Download PichiPlayer.apk (${updateInfo.apkSize})",
                            icon = Icons.Default.Download,
                            onClick = {
                                openUrl(context, updateInfo.downloadUrl)
                                onDismiss()
                            },
                            modifier = Modifier.fillMaxWidth()
                        )
                    }

                    PichiButton(
                        text = "View Release on GitHub",
                        icon = Icons.Outlined.OpenInBrowser,
                        onClick = {
                            openUrl(context, updateInfo.releasesPageUrl)
                            onDismiss()
                        },
                        modifier = Modifier.fillMaxWidth(),
                        isSecondary = isUpdateAvailable
                    )

                    TextButton(
                        onClick = onDismiss,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(
                            text = if (isUpdateAvailable) "Remind Me Later" else "Close",
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
}

@Composable
fun WhatsNewDialog(
    updateInfo: AppUpdateInfo,
    onGotIt: () -> Unit
) {
    Dialog(
        onDismissRequest = onGotIt,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth(0.92f)
                .clip(RoundedCornerShape(22.dp))
                .background(AppColors.backgroundElevated)
                .border(1.dp, AppColors.electricBlueGlow, RoundedCornerShape(22.dp))
                .padding(22.dp)
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(14.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
            ) {
                // Top Rocket / Sparkle
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(CircleShape)
                        .background(AppColors.brandGradient)
                        .border(1.5.dp, AppColors.electricBlueBright, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.AutoAwesome,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(28.dp)
                    )
                }

                // Title
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "What's New in v${updateInfo.versionName}!",
                        style = AppTypography.sectionHeader.copy(
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center
                        )
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    PichiBadge(text = "Updated to Build ${updateInfo.versionCode}", highlight = true)
                }

                Text(
                    text = updateInfo.message,
                    style = AppTypography.bodyMedium.copy(
                        color = AppColors.textSecondary,
                        textAlign = TextAlign.Center,
                        lineHeight = 20.sp
                    )
                )

                // Changelog Card
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(14.dp))
                        .background(AppColors.surfaceSubtle)
                        .border(1.dp, AppColors.glassBorderSubtle, RoundedCornerShape(14.dp))
                        .padding(14.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    updateInfo.changelog.forEach { logItem ->
                        Row(
                            verticalAlignment = Alignment.Top,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Text(
                                text = "•",
                                color = AppColors.electricBlueBright,
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                text = logItem,
                                style = AppTypography.caption.copy(
                                    color = AppColors.textPrimary,
                                    lineHeight = 18.sp
                                )
                            )
                        }
                    }
                }

                // Action
                PichiButton(
                    text = "Awesome, Let's Play!",
                    onClick = onGotIt,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}

private fun openUrl(context: Context, url: String) {
    try {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    } catch (_: Exception) {}
}
