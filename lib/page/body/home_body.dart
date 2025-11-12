import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});
  @override
  State<HomeBody> createState() => _HomeBodyState();
}

// ===== Demo 数据模型 =====
class FeedItem {
  final String id;
  final String? networkImageUrl; // 远端图
  final String? localImagePath; // 本地图
  final String caption;

  const FeedItem({
    required this.id,
    required this.caption,
    this.networkImageUrl,
    this.localImagePath,
  });

  bool get isLocal => (localImagePath != null);
}

class _HomeBodyState extends State<HomeBody> {
  final List<FeedItem> _items = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 0;
  static const int _pageSize = 15;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    _page = 0;
    _items.clear();
    await _fetchNextPage();
    if (mounted) setState(() {});
  }

  Future<void> _fetchNextPage() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    setState(() {});

    // ---- 模拟网络请求延迟 & 批量构造 demo 数据 ----
    await Future.delayed(const Duration(milliseconds: 800));
    final newItems = List.generate(_pageSize, (i) {
      final index = _page * _pageSize + i;
      return FeedItem(
        id: 'demo_$index',
        caption: 'Demo item #$index',
        // 用 picsum 占位图。上线后换成你自己的 URL。
        networkImageUrl: 'https://picsum.photos/seed/$index/600/400',
      );
    });

    _items.addAll(newItems);
    _page += 1;
    // 模拟最多 4 页
    if (_page >= 4) _hasMore = false;

    _isLoadingMore = false;
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchNextPage();
    }
  }

  // ============ BottomSheet：详情/分析  ============
  // 通用的“可拖拽 Modal 底部浮层”，覆盖 ≥80% 高度
  Future<T?> _showDraggableModal<T>({
    required Widget Function(BuildContext ctx, ScrollController sc)
    builderWithScroll,
    bool enableDragToClose = true,
  }) {
    final media = MediaQuery.of(context);
    final minHeight = media.size.height * 0.8; // ≥ 80%
    final maxHeight = media.size.height * 0.95;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: maxHeight, // 给个最大高度
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: minHeight / maxHeight, // 初始 ≥80%
            minChildSize: 0.4,
            maxChildSize: 1.0,
            snap: true,
            builder: (sheetCtx, scrollController) {
              return Column(
                children: [
                  // 小拖拽手柄
                  const SizedBox(height: 8),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: builderWithScroll(sheetCtx, scrollController),
                  ),
                ],
              );
            },
          ),
        );
      },
      enableDrag: enableDragToClose,
      isDismissible: enableDragToClose,
    );
  }

  // 列表项点击：弹出详情浮层（内容先占位）
  void _openItemDetail(FeedItem item) {
    _showDraggableModal(
      builderWithScroll: (ctx, sc) {
        return ListView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text('记录详情', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 12),
            _FeedImage(item: item),
            const SizedBox(height: 12),
            Text(item.caption, style: Theme.of(ctx).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text(
              '此处展示你需要的详细内容（营养解析、识别结果等……）。'
              '\n你后续接入真实后端后，把这里替换为实际渲染组件即可。',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
          ],
        );
      },
    );
  }

  // ============ FAB：添加照片 → 上传 → 弹出“加载→结果”浮层 ============

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Picture'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final xfile = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 92,
                  );
                  if (xfile != null && mounted) {
                    _startUploadFlow(xfile);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select From Album'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final xfile = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 92,
                  );
                  if (xfile != null && mounted) {
                    _startUploadFlow(xfile);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // 入口：开始“上传并显示浮层”
  Future<void> _startUploadFlow(XFile xfile) async {
    // 打开分析浮层：先显示“上传中/分析中…”，Future 完成后刷新成结果
    _showDraggableModal(
      builderWithScroll: (ctx, sc) {
        return FutureBuilder<_AnalysisResult>(
          future: _fakeUploadAndAnalyze(File(xfile.path)),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // 加载中
              return ListView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: [
                  Text(
                    'Analyzing...',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(xfile.path),
                      fit: BoxFit.cover,
                      height: 220,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'This may need several seconds, hold on...',
                    style: Theme.of(ctx).textTheme.bodyMedium,
                  ),
                ],
              );
            }

            final result = snapshot.data!;
            return ListView(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                Text('分析结果', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(xfile.path),
                    fit: BoxFit.cover,
                    height: 220,
                  ),
                ),
                const SizedBox(height: 16),
                _ResultCard(text: result.summary),
                const SizedBox(height: 8),
                _ResultCard(text: '热量估算：${result.kcal} kcal'),
                const SizedBox(height: 8),
                _ResultCard(text: '提示：${result.hint}'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).maybePop(),
                  child: const Text('完成'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // BottomSheet 关闭后，如需额外操作可在这里写
    });
  }

  // 假后端：模拟上传与分析（替换为你的真实 API 调用）
  Future<_AnalysisResult> _fakeUploadAndAnalyze(File file) async {
    final res = await DI.I.suggestionSerivce.seekingSuggestion(file);
    /*
    final newItem = FeedItem(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      localImagePath: file.path,
      caption: '新上传的记录（示例）',
    );

    setState(() {
      _items.insert(0, newItem);
    });
    */
    // 4) 返回“分析结果”
    return _AnalysisResult(
      summary: '这是一份示例分析摘要：碳水、蛋白、脂肪比例均衡。',
      kcal: 520,
      hint: '建议搭配蔬菜或减少酱料。',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadInitial,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, index) {
                  if (index == _items.length) {
                    // 底部“加载更多/没有更多”
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: _hasMore
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                '没有更多了',
                                style: Theme.of(ctx).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                      ),
                    );
                  }

                  final item = _items[index];
                  return _FeedCard(
                    item: item,
                    onTap: () => _openItemDetail(item),
                  );
                },
                childCount: _items.length + 1, // 多一个“加载更多/没有更多”
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceActionSheet,
        tooltip: 'Add Photo',
        child: const Icon(Icons.add_a_photo),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ================== 子组件们 ==================

class _FeedCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;

  const _FeedCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FeedImage(item: item, height: 180),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Text(
                item.caption,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedImage extends StatelessWidget {
  final FeedItem item;
  final double height;
  const _FeedImage({required this.item, this.height = 220});

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (item.isLocal) {
      child = Image.file(
        File(item.localImagePath!),
        fit: BoxFit.cover,
        height: height,
      );
    } else {
      child = Image.network(
        item.networkImageUrl!,
        fit: BoxFit.cover,
        height: height,
        // 生产环境建议加上加载/错误占位
        loadingBuilder: (c, w, p) {
          if (p == null) return w;
          return SizedBox(
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (c, e, s) => SizedBox(
          height: height,
          child: const Center(child: Icon(Icons.broken_image_outlined)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: child,
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String text;
  const _ResultCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

// 假分析结果数据
class _AnalysisResult {
  final String summary;
  final int kcal;
  final String hint;
  _AnalysisResult({
    required this.summary,
    required this.kcal,
    required this.hint,
  });
}
