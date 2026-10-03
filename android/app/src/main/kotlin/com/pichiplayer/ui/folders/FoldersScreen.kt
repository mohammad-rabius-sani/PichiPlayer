package com.pichiplayer.ui.folders

import android.content.Intent
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForwardIos
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.pichiplayer.PichiPlayerApp
import com.pichiplayer.data.database.FolderEntity
import com.pichiplayer.ui.components.*
import com.pichiplayer.ui.theme.AppColors
import com.pichiplayer.ui.theme.AppTypography
import kotlinx.coroutines.launch

@Composable
fun FoldersScreen(
    onFolderClick: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val repository = PichiPlayerApp.instance.repository
    val coroutineScope = rememberCoroutineScope()

    val folders by repository.allFolders.collectAsState(initial = emptyList())

    // SAF Document Tree picker for custom folders / SD cards
    val folderPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.OpenDocumentTree()
    ) { uri: Uri? ->
        if (uri != null) {
            val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            try {
                context.contentResolver.takePersistableUriPermission(uri, flags)
            } catch (_: Exception) {}

            coroutineScope.launch {
                repository.rescan(customFolderUris = listOf(uri))
            }
        }
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(AppColors.background)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .displayCutoutPadding()
        ) {
            // Header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 14.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column {
                    Text(
                        text = "Folders",
                        style = AppTypography.heroTitle
                    )
                    Text(
                        text = "${folders.size} storage locations",
                        style = AppTypography.caption.copy(color = AppColors.textSecondary)
                    )
                }

                PichiButton(
                    text = "Add Folder",
                    icon = Icons.Default.CreateNewFolder,
                    onClick = { folderPickerLauncher.launch(null) },
                    contentPadding = PaddingValues(horizontal = 14.dp, vertical = 8.dp)
                )
            }

            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(bottom = 16.dp),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(folders, key = { it.folderPath }) { folder ->
                    FolderRowItem(
                        folder = folder,
                        onClick = { onFolderClick(folder.folderName) }
                    )
                }
            }
        }
    }
}

@Composable
private fun FolderRowItem(
    folder: FolderEntity,
    onClick: () -> Unit
) {
    PichiGlassCard(
        modifier = Modifier
            .fillMaxWidth()
            .height(78.dp),
        onClick = onClick
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(14.dp),
                modifier = Modifier.weight(1f)
            ) {
                Box(
                    modifier = Modifier
                        .size(46.dp)
                        .clip(CircleShape)
                        .background(AppColors.surfaceGlass),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Filled.Folder,
                        contentDescription = null,
                        tint = AppColors.electricBlueBright,
                        modifier = Modifier.size(24.dp)
                    )
                }

                Column {
                    Text(
                        text = folder.folderName,
                        style = AppTypography.cardTitle.copy(fontSize = 15.sp, fontWeight = FontWeight.SemiBold)
                    )
                    Spacer(modifier = Modifier.height(3.dp))
                    Text(
                        text = "${folder.videoCount} videos • ${folder.formattedTotalSize}",
                        style = AppTypography.caption.copy(color = AppColors.textSecondary)
                    )
                }
            }

            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowForwardIos,
                contentDescription = null,
                tint = AppColors.textMuted,
                modifier = Modifier.size(14.dp)
            )
        }
    }
}
