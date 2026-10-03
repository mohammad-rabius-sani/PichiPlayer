package com.pichiplayer.ui.navigation

import android.app.Activity
import android.net.Uri
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.*
import androidx.navigation.navArgument
import com.pichiplayer.PichiPlayerApp
import com.pichiplayer.data.database.VideoEntity
import com.pichiplayer.ui.components.ExitConfirmationDialog
import com.pichiplayer.ui.components.PichiBottomNavBar
import com.pichiplayer.ui.components.PichiNavDestination
import com.pichiplayer.ui.details.VideoDetailsScreen
import com.pichiplayer.ui.folders.FoldersScreen
import com.pichiplayer.ui.home.HomeScreen
import com.pichiplayer.ui.library.LibraryScreen
import com.pichiplayer.ui.player.PlayerScreen
import com.pichiplayer.ui.search.SearchScreen
import com.pichiplayer.ui.settings.SettingsScreen
import com.pichiplayer.ui.theme.AppColors
import kotlinx.coroutines.launch

object PichiRoutes {
    const val HOME = "home"
    const val LIBRARY = "library"
    const val FOLDERS = "folders"
    const val SETTINGS = "settings"
    const val SEARCH = "search"
    const val DETAILS = "details/{videoId}"
    const val PLAYER = "player"

    fun details(videoId: Long) = "details/$videoId"
}

@Composable
fun PichiNavHost(
    navController: NavHostController = rememberNavController(),
    onEnterPiP: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val activity = context as? Activity
    val coroutineScope = rememberCoroutineScope()
    val repository = PichiPlayerApp.instance.repository
    val playerManager = PichiPlayerApp.instance.playerManager

    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    // Exit confirmation dialog state
    var showExitDialog by remember { mutableStateOf(false) }

    // Intercept back on HOME to show exit or play-in-background dialog
    BackHandler(enabled = currentRoute == PichiRoutes.HOME) {
        showExitDialog = true
    }

    if (showExitDialog) {
        val isPlaying = playerManager.uiState.collectAsState().value.isPlaying
        ExitConfirmationDialog(
            isPlaying = isPlaying,
            onPlayInBackground = {
                showExitDialog = false
                activity?.moveTaskToBack(true)
            },
            onStopAndExit = {
                showExitDialog = false
                playerManager.player.stop()
                activity?.finishAffinity()
            },
            onDismiss = { showExitDialog = false }
        )
    }

    // SAF Document Tree picker for custom folders
    val folderPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.OpenDocumentTree()
    ) { uri: Uri? ->
        if (uri != null) {
            coroutineScope.launch {
                repository.rescan(customFolderUris = listOf(uri))
            }
        }
    }

    // Determine current destination for bottom nav
    val currentNavDestination = when (currentRoute) {
        PichiRoutes.HOME -> PichiNavDestination.HOME
        PichiRoutes.LIBRARY -> PichiNavDestination.LIBRARY
        PichiRoutes.FOLDERS -> PichiNavDestination.FOLDERS
        PichiRoutes.SETTINGS -> PichiNavDestination.SETTINGS
        else -> null
    }

    val isPlayerRoute = currentRoute == PichiRoutes.PLAYER

    Scaffold(
        modifier = modifier.fillMaxSize(),
        containerColor = if (isPlayerRoute) Color.Black else AppColors.background,
        contentWindowInsets = WindowInsets(0, 0, 0, 0),
        bottomBar = {
            if (currentNavDestination != null && !isPlayerRoute) {
                PichiBottomNavBar(
                    currentDestination = currentNavDestination,
                    onNavigate = { destination ->
                        val targetRoute = when (destination) {
                            PichiNavDestination.HOME -> PichiRoutes.HOME
                            PichiNavDestination.LIBRARY -> PichiRoutes.LIBRARY
                            PichiNavDestination.FOLDERS -> PichiRoutes.FOLDERS
                            PichiNavDestination.SETTINGS -> PichiRoutes.SETTINGS
                        }
                        if (currentRoute != targetRoute) {
                            navController.navigate(targetRoute) {
                                popUpTo(PichiRoutes.HOME) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    }
                )
            }
        }
    ) { paddingValues ->
        NavHost(
            navController = navController,
            startDestination = PichiRoutes.HOME,
            modifier = Modifier
                .fillMaxSize()
                .padding(if (isPlayerRoute) PaddingValues(0.dp) else paddingValues)
        ) {
            // 1. Home Screen
            composable(PichiRoutes.HOME) {
                HomeScreen(
                    onPlayVideo = { video, playlist ->
                        playerManager.playVideo(video, playlist)
                        navController.navigate(PichiRoutes.PLAYER)
                    },
                    onExpandFullscreen = {
                        navController.navigate(PichiRoutes.PLAYER)
                    },
                    onVideoDetails = { videoId ->
                        navController.navigate(PichiRoutes.details(videoId))
                    },
                    onNavigateSearch = { navController.navigate(PichiRoutes.SEARCH) },
                    onNavigateLibrary = { navController.navigate(PichiRoutes.LIBRARY) },
                    onSelectCustomFolder = { folderPickerLauncher.launch(null) }
                )
            }

            // 2. Library Screen
            composable(PichiRoutes.LIBRARY) {
                LibraryScreen(
                    onPlayVideo = { video, playlist ->
                        playerManager.playVideo(video, playlist)
                        navController.navigate(PichiRoutes.PLAYER)
                    },
                    onVideoDetails = { videoId ->
                        navController.navigate(PichiRoutes.details(videoId))
                    },
                    onNavigateSearch = { navController.navigate(PichiRoutes.SEARCH) },
                    onSelectCustomFolder = { folderPickerLauncher.launch(null) }
                )
            }

            // 3. Folders Screen
            composable(PichiRoutes.FOLDERS) {
                FoldersScreen(
                    onFolderClick = { folderName ->
                        navController.navigate(PichiRoutes.LIBRARY)
                    }
                )
            }

            // 4. Settings Screen
            composable(PichiRoutes.SETTINGS) {
                SettingsScreen()
            }

            // 5. Search Screen
            composable(PichiRoutes.SEARCH) {
                SearchScreen(
                    onPlayVideo = { video, playlist ->
                        playerManager.playVideo(video, playlist)
                        navController.navigate(PichiRoutes.PLAYER)
                    },
                    onVideoDetails = { videoId ->
                        navController.navigate(PichiRoutes.details(videoId))
                    },
                    onBackClick = { navController.popBackStack() }
                )
            }

            // 6. Video Details Screen
            composable(
                route = PichiRoutes.DETAILS,
                arguments = listOf(navArgument("videoId") { type = NavType.LongType })
            ) { backStackEntry ->
                val videoId = backStackEntry.arguments?.getLong("videoId") ?: 0L
                VideoDetailsScreen(
                    videoId = videoId,
                    onPlayVideo = { video ->
                        playerManager.playVideo(video)
                        navController.navigate(PichiRoutes.PLAYER)
                    },
                    onBackClick = { navController.popBackStack() }
                )
            }

            // 7. Fullscreen Player Screen
            composable(PichiRoutes.PLAYER) {
                PlayerScreen(
                    onBackClick = { navController.popBackStack() },
                    onEnterPiP = onEnterPiP
                )
            }
        }
    }
}
