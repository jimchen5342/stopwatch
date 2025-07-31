import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class StoragePermissionExample extends StatefulWidget {
  const StoragePermissionExample({super.key});

  @override
  State<StoragePermissionExample> createState() =>
      _StoragePermissionExampleState();
}

class _StoragePermissionExampleState extends State<StoragePermissionExample> {
  PermissionStatus _storagePermissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    // _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    // 对于 Android 13+，建议分别检查媒体权限
    PermissionStatus status;
    // 检查图片权限
    status = await Permission.photos.status;
    if (status.isGranted) {
      setState(() {
        _storagePermissionStatus = status;
      });
      return;
    }
    // 检查视频权限
    status = await Permission.videos.status;
    if (status.isGranted) {
      setState(() {
        _storagePermissionStatus = status;
      });
      return;
    }
    // 检查音频权限
    status = await Permission.audio.status;
    if (status.isGranted) {
      setState(() {
        _storagePermissionStatus = status;
      });
      return;
    }

    // 如果上面任何一个都未授予，则检查传统的存储权限 (适用于旧版本Android或通用文件访问)
    status = await Permission.storage.status;

    setState(() {
      _storagePermissionStatus = status;
    });
  }

  Future<void> _requestStoragePermission() async {
    PermissionStatus status;
    // 优先请求新的媒体权限
    status = await Permission.photos.request();
    if (!status.isGranted) {
      status = await Permission.videos.request();
    }
    if (!status.isGranted) {
      status = await Permission.audio.request();
    }
    // 如果新的媒体权限未授予，则尝试请求传统的存储权限
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    setState(() {
      _storagePermissionStatus = status;
    });

    if (_storagePermissionStatus.isPermanentlyDenied) {
      // 如果用户永久拒绝，引导他们到应用设置
      _showSettingsDialog();
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('需要权限'),
            content: const Text('您已永久拒绝了存储权限。请前往应用设置启用。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings(); // 打开应用设置
                },
                child: const Text('设置'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('存储权限示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('存储权限状态: '),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestStoragePermission,
              child: const Text('请求存储权限'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPermissionStatus,
              child: const Text('检查权限状态'),
            ),
            const SizedBox(height: 20),
            if (_storagePermissionStatus.isGranted)
              const Text('您现在可以访问存储空间了！')
            else if (_storagePermissionStatus.isDenied)
              const Text('请授予存储权限以继续。')
            else if (_storagePermissionStatus.isPermanentlyDenied)
              const Text('权限被永久拒绝，请手动启用。'),
          ],
        ),
      ),
    );
  }
}
