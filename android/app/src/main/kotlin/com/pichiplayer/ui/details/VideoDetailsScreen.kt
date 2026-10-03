package com.pichiplayer.ui.details

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.pichiplayer.PichiPlayerApp
import com.pichiplayer.data.database.VideoEntity
import com.pichiplayer.ui.components.*
import com.pichiplayer.ui.theme.AppColors
import com.pichiplayer.ui.theme.AppTypography
import kotlinx.coroutines.launch

@Composable
fun VideoDetailsScreen(
    videoId: Long,
    onPlayVideo: (VideoEntity) -> Unit,
    onBackClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val repository = PichiPlayerApp.instance.repository
    val coroutineScope = rememberCoroutineScope()

    val video by repository.getVideoByIdFlow(videoId).collectAsState(initial = null)

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(AppColors.background)
            .statusBarsPadding()
            .displayCutoutPadding()
    ) {
        if (video == null) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = AppColors.electricBlueBright)
            }
        } else {
            val currentVideo = video!!

            Column(modifier = Modifier.fillMaxSize()) {
                // Top Bar
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    PichiIconButton(
                        icon = Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = "Back",
                        onClick = onBackClick,
                        size = 40.dp
                    )

                    Text(
                        text = "Video Details",
                        style = AppTypography.sectionHeader.copy(fontSize = 18.sp)
                    )

                    PichiIconButton(
                        icon = if (currentVideo.isFavorite) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder,
                        contentDescription = "Favorite",
                        tint = if (currentVideo.isFavorite) AppColors.errorBright else AppColors.textPrimary,
                        onClick = {
                            coroutineScope.launch { repository.toggleFavorite(currentVideo.id) }
                        },
                        size = 40.dp
                    )
                }

                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 20.dp),
                    contentPadding = PaddingValues(bottom = 32.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    // Hero Thumbnail Preview
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(220.dp)
                        ) {
                            PichiVideoThumbnail(
                                video = currentVideo,
                                thumbnailPath = currentVideo.thumbnailPath,
                                modifier = Modifier.fillMaxSize()
                            )
                        }
                    }

                    // Title & Location
                    item {
                        Column {
                            Text(
                                text = currentVideo.displayName,
                                style = AppTypography.heroTitle.copy(fontSize = 20.sp)
                            )
                            Spacer(modifier = Modifier.height(6.dp))
                            Text(
                                text = currentVideo.filePath ?: currentVideo.contentUri,
                                style = AppTypography.caption.copy(color = AppColors.textMuted),
                                maxLines = 2,
                                overflow = TextOverflow.Ellipsis
                            )
                        }
                    }

                    // Play Action Buttons
                    item {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            val playText = if (currentVideo.lastPositionMs > 1000L && currentVideo.watchedPercentage < 0.95f) {
                                "Resume (${currentVideo.formattedLastPosition})"
                            } else "Play Video"

                            PichiButton(
                                text = playText,
                                icon = Icons.Filled.PlayArrow,
                                onClick = { onPlayVideo(currentVideo) },
                                modifier = Modifier.weight(1f)
                            )

                            PichiIconButton(
                                icon = Icons.Outlined.Share,
                                contentDescription = "Share",
                                onClick = {
                                    val shareIntent = Intent(Intent.ACTION_SEND).apply {
                                        type = "video/*"
                                        putExtra(Intent.EXTRA_STREAM, Uri.parse(currentVideo.contentUri))
                                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                    }
                                    context.startActivity(Intent.createChooser(shareIntent, "Share Video"))
                                },
                                size = 46.dp
                            )
                        }
                    }

                    // Technical Metadata Grid
                    item {
                        Text(
                            text = "TECHNICAL SPECIFICATIONS",
                            style = AppTypography.caption.copy(
                                fontWeight = FontWeight.Bold,
                                letterSpacing = 1.2.sp,
                                color = AppColors.textMuted
                            )
                        )
                        Spacer(modifier = Modifier.height(10.dp))

                        PichiGlassCard(modifier = Modifier.fillMaxWidth()) {
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(16.dp),
                                verticalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                SpecRow(label = "Resolution", value = currentVideo.resolutionBadge)
                                SpecRow(label = "Dimensions", value = "${currentVideo.width} × ${currentVideo.height} px")
                                SpecRow(label = "Video Codec", value = currentVideo.videoCodec ?: "Unknown")
                                SpecRow(label = "Audio Codec", value = currentVideo.audioCodec ?: "Unknown")
                                SpecRow(label = "Duration", value = currentVideo.formattedDuration)
                                SpecRow(label = "File Size", value = currentVideo.formattedFileSize)
                                if (currentVideo.frameRate != null && currentVideo.frameRate!! > 0) {
                                    SpecRow(label = "Frame Rate", value = "${currentVideo.frameRate} FPS")
                                }
                                if (currentVideo.bitrate != null && currentVideo.bitrate!! > 0) {
                                    SpecRow(
                                        label = "Bitrate",
                                        value = "%.1f Mbps".format(currentVideo.bitrate!!.toDouble() / 1_000_000)
                                    )
                                }
                                SpecRow(label = "Color Profile", value = if (currentVideo.isHdr) "HDR (High Dynamic Range)" else "SDR (Standard)")
                                SpecRow(label = "Folder Location", value = currentVideo.folderName)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun SpecRow(label: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            style = AppTypography.bodyMedium.copy(color = AppColors.textSecondary)
        )
        Text(
            text = value,
            style = AppTypography.bodyMedium.copy(
                fontWeight = FontWeight.SemiBold,
                color = AppColors.textPrimary
            )
        )
    }
}
