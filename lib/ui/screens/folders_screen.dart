import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock_folder_data.dart';
import '../../models/local_folder.dart';
import '../../models/storage_source.dart';
import '../widgets/ambient_background.dart';
import '../widgets/folder_list_row.dart';
import '../widgets/folder_management_sheet.dart';
import '../widgets/folder_skeleton_loader.dart';
import '../widgets/pichi_bottom_nav.dart';
import '../widgets/storage_source_card.dart';
import 'folder_detail_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';

/// The official Folders screen for PIchiPlayer.
/// Offline-first media browser that indexes, discovers, and manages physical
/// video directories across internal storage and removable media.
class FoldersScreen extends StatefulWidget {
  final bool initialLoading;
  final bool enableBackgroundAnimation;

  const FoldersScreen({
    super.key,
    this.initialLoading = false,
    this.enableBackgroundAnimation = true,
  });

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  late bool _isLoading;
  late List<StorageSource> _storageSources;
  late List<LocalFolder> _folders;
  bool _showHiddenFolders = false;
  NavDestination _currentDestination = NavDestination.folders;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.initialLoading;
    _storageSources = List<StorageSource>.from(MockFolderData.sampleStorageSources);
    _folders = List<LocalFolder>.from(MockFolderData.sampleFolders);

    if (_isLoading) {
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  // Filter folders based on hidden preference
  List<LocalFolder> get _visibleFolders {
    return _folders.where((f) {
      if (f.isHidden) {
        return _showHiddenFolders;
      }
      return true;
    }).toList();
  }

  void _handleRescan({bool full = false}) {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _folders = List<LocalFolder>.from(MockFolderData.sampleFolders);
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.glassBorderSubtle),
            ),
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.electricBlueBright,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  full
                      ? 'Re-indexed ${_visibleFolders.length} folders successfully'
                      : 'Scan complete. All videos up to date.',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  void _openFolderDetail(LocalFolder folder) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, _, __) => FolderDetailScreen(
          folder: folder,
          enableBackgroundAnimation: widget.enableBackgroundAnimation,
        ),
        transitionDuration: const Duration(milliseconds: 260),
        transitionsBuilder: (context, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _handleGrantPermission(LocalFolder folder) {
    setState(() {
      final index = _folders.indexWhere((f) => f.id == folder.id);
      if (index != -1) {
        _folders[index] = _folders[index].copyWith(hasPermission: true);
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.verified_user_rounded,
              color: AppColors.electricBlueBright,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Access granted to ${folder.name}. Media indexed.',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddFolderPicker() {
    showDialog(
      context: context,
      builder: (ctx) {
        final textController = TextEditingController(text: 'Anime');
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.glassBorderSubtle),
          ),
          title: const Row(
            children: [
              Icon(Icons.create_new_folder_rounded, color: AppColors.electricBlueBright, size: 22),
              SizedBox(width: 10),
              Text(
                'Add Video Folder',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Grant PIchiPlayer access to an additional device directory containing videos.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Folder Path / Name',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.folder_open_rounded, color: AppColors.electricBlueBright, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceGlass,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.glassBorderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.electricBlue),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final folderName = textController.text.trim();
                Navigator.pop(ctx);
                if (folderName.isNotEmpty) {
                  setState(() {
                    _folders.add(
                      LocalFolder(
                        id: 'folder_${folderName.toLowerCase().replaceAll(' ', '_')}',
                        name: folderName,
                        path: '/storage/emulated/0/$folderName',
                        videoCount: 24,
                        totalSizeBytes: 3 * 1024 * 1024 * 1024,
                        customIcon: Icons.folder_special_rounded,
                      ),
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.surface,
                      content: Text('Added folder "$folderName" to monitored library'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Add & Scan'),
            ),
          ],
        );
      },
    );
  }

  void _openFolderManagementSheet() {
    FolderManagementSheet.show(
      context,
      showHiddenFolders: _showHiddenFolders,
      onToggleHiddenFolders: (val) {
        setState(() {
          _showHiddenFolders = val;
        });
      },
      onScanNewVideos: () => _handleRescan(full: false),
      onRescanAll: () => _handleRescan(full: true),
      onManageFolders: _openManageFoldersDialog,
      onStoragePermissions: _showStoragePermissionsDialog,
    );
  }

  void _openManageFoldersDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        title: const Text(
          'Monitored Folders',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _folders.length,
            separatorBuilder: (_, __) => const Divider(color: AppColors.glassBorderSubtle, height: 1),
            itemBuilder: (context, index) {
              final f = _folders[index];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(f.customIcon ?? Icons.folder_rounded, color: AppColors.electricBlueBright, size: 20),
                title: Text(f.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5)),
                subtitle: Text(f.path, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done', style: TextStyle(color: AppColors.electricBlueBright)),
          ),
        ],
      ),
    );
  }

  void _showStoragePermissionsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        title: const Row(
          children: [
            Icon(Icons.security_rounded, color: AppColors.electricBlueBright, size: 22),
            SizedBox(width: 10),
            Text('Storage Access Status', style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PIchiPlayer requires READ_MEDIA_VIDEO permission to discover and play local videos on your device.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.electricBlueBright, size: 18),
                SizedBox(width: 8),
                Text('Media Audio & Video: Granted', style: TextStyle(color: AppColors.textPrimary, fontSize: 12.5)),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.electricBlueBright, size: 18),
                SizedBox(width: 8),
                Text('Scoped Storage: Active', style: TextStyle(color: AppColors.textPrimary, fontSize: 12.5)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.electricBlueBright)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableStorage = _storageSources.where((s) => s.isAvailable).toList();
    final visibleFolders = _visibleFolders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientBackground(
        enableAnimation: widget.enableBackgroundAnimation,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Compact Header
              _buildHeader(),

              // 2. Main Content (Storage + Video Folders)
              Expanded(
                child: _isLoading
                    ? const FolderSkeletonLoader()
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        children: [
                          // A. STORAGE SECTION
                          _buildSectionLabel('STORAGE'),
                          const SizedBox(height: 8),
                          for (int i = 0; i < availableStorage.length; i++) ...[
                            StorageSourceCard(
                              source: availableStorage[i],
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.surface,
                                    content: Text('${availableStorage[i].name} volume selected'),
                                  ),
                                );
                              },
                            ),
                            if (i < availableStorage.length - 1) const SizedBox(height: 10),
                          ],

                          const SizedBox(height: 24),

                          // B. VIDEO FOLDERS SECTION
                          _buildSectionLabel('VIDEO FOLDERS'),
                          const SizedBox(height: 8),

                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceGlass,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.glassBorderSubtle,
                                width: 0.8,
                              ),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              itemCount: visibleFolders.length,
                              separatorBuilder: (_, __) => const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Divider(color: AppColors.glassBorderSubtle, height: 1),
                              ),
                              itemBuilder: (context, index) {
                                final folder = visibleFolders[index];
                                return FolderListRow(
                                  folder: folder,
                                  onTap: () => _openFolderDetail(folder),
                                  onGrantAccess: () => _handleGrantPermission(folder),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // C. + Add Folder Action
                          _buildAddFolderButton(),

                          const SizedBox(height: 24),
                        ],
                      ),
              ),

              // 3. Bottom Navigation Bar (Folders destination active)
              PichiBottomNav(
                currentDestination: _currentDestination,
                onDestinationSelected: (dest) {
                  if (dest == NavDestination.home) {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) => const HomeScreen(),
                        transitionDuration: const Duration(milliseconds: 300),
                        transitionsBuilder: (context, anim, _, child) =>
                            FadeTransition(opacity: anim, child: child),
                      ),
                    );
                  } else if (dest == NavDestination.library) {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) => const LibraryScreen(),
                        transitionDuration: const Duration(milliseconds: 300),
                        transitionsBuilder: (context, anim, _, child) =>
                            FadeTransition(opacity: anim, child: child),
                      ),
                    );
                  } else {
                    setState(() {
                      _currentDestination = dest;
                    });
                    if (dest != NavDestination.folders) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surface,
                          duration: const Duration(seconds: 1),
                          content: Text('${dest.name.toUpperCase()} tab selected'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Folders',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Browse your local video folders',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Rescan',
            onPressed: () => _handleRescan(full: false),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            tooltip: 'Folder Options',
            onPressed: _openFolderManagementSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildAddFolderButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openAddFolderPicker,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.electricBlue.withOpacity(0.12),
        highlightColor: AppColors.electricBlue.withOpacity(0.06),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.electricBlue.withOpacity(0.40),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricBlue.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: AppColors.electricBlueBright,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Add Folder',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
