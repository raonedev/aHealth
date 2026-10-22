import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BodyMapWidget extends StatefulWidget {
  final String? selectedTarget;
  final ValueChanged<String?> onTargetSelected;

  const BodyMapWidget({
    super.key,
    required this.selectedTarget,
    required this.onTargetSelected,
  });

  @override
  State<BodyMapWidget> createState() => _BodyMapWidgetState();
}

class _BodyMapWidgetState extends State<BodyMapWidget> {
  bool _showBack = false;

  // Cached raw SVGs loaded from rootBundle
  static String? _cachedFrontSvg;
  static String? _cachedBackSvg;

  static const List<Map<String, String>> _frontMuscles = [
    {'id': 'chest', 'name': 'Chest', 'target': 'pectorals'},
    {'id': 'front-shoulders', 'name': 'Shoulders', 'target': 'delts'},
    {'id': 'biceps', 'name': 'Biceps', 'target': 'biceps'},
    {'id': 'abdominals', 'name': 'Abs', 'target': 'abs'},
    {'id': 'obliques', 'name': 'Obliques', 'target': 'obliques'},
    {'id': 'quads', 'name': 'Quads', 'target': 'quads'},
    {'id': 'forearms', 'name': 'Forearms', 'target': 'forearms'},
    {'id': 'calves', 'name': 'Calves', 'target': 'calves'},
  ];

  static const List<Map<String, String>> _backMuscles = [
    {'id': 'traps', 'name': 'Traps', 'target': 'traps'},
    {'id': 'rear-shoulders', 'name': 'Rear Delts', 'target': 'rear deltoids'},
    {'id': 'triceps', 'name': 'Triceps', 'target': 'triceps'},
    {'id': 'lats', 'name': 'Lats', 'target': 'lats'},
    {'id': 'lowerback', 'name': 'Lower Back', 'target': 'erector spinae'},
    {'id': 'glutes', 'name': 'Glutes', 'target': 'glutes'},
    {'id': 'hamstrings', 'name': 'Hamstrings', 'target': 'hamstrings'},
    {'id': 'calves', 'name': 'Calves', 'target': 'calves'},
  ];

  @override
  void initState() {
    super.initState();
    _checkInitialOrientation();
    _loadSvgAssets();
  }

  @override
  void didUpdateWidget(covariant BodyMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTarget != widget.selectedTarget && widget.selectedTarget != null) {
      if (_isBackTarget(widget.selectedTarget)) {
        _showBack = true;
      } else {
        _showBack = false;
      }
    }
  }

  void _checkInitialOrientation() {
    if (widget.selectedTarget != null && _isBackTarget(widget.selectedTarget)) {
      _showBack = true;
    }
  }

  Future<void> _loadSvgAssets() async {
    if (_cachedFrontSvg != null && _cachedBackSvg != null) return;

    try {
      final front = await rootBundle.loadString('assets/front.svg');
      final back = await rootBundle.loadString('assets/back.svg');
      if (mounted) {
        setState(() {
          _cachedFrontSvg = front;
          _cachedBackSvg = back;
        });
      }
    } catch (_) {}
  }

  static String? _targetToSvgId(String? target) {
    if (target == null) return null;
    final t = target.toLowerCase().trim();
    if (t.contains('chest') || t.contains('pectoral')) return 'chest';
    if (t.contains('abdom') || t.contains('abs') || t.contains('rectus') || t.contains('core')) {
      return 'abdominals';
    }
    if (t.contains('oblique')) return 'obliques';
    if (t.contains('bicep')) return 'biceps';
    if (t.contains('tricep')) return 'triceps';
    if (t.contains('rear delt') || t.contains('posterior delt')) return 'rear-shoulders';
    if (t.contains('delt') || t.contains('shoulder')) return 'front-shoulders';
    if (t.contains('trap') || t.contains('rhomboid') || t.contains('upper back')) return 'traps';
    if (t.contains('lat') || t.contains('middle back')) return 'lats';
    if (t.contains('erector') || t.contains('lower back') || t.contains('spine')) return 'lowerback';
    if (t.contains('glute')) return 'glutes';
    if (t.contains('hamstring')) return 'hamstrings';
    if (t.contains('quad')) return 'quads';
    if (t.contains('calv') || t.contains('peroneal')) return 'calves';
    if (t.contains('forearm') || t.contains('wrist')) return 'forearms';
    return t;
  }

  static bool _isBackTarget(String? target) {
    final id = _targetToSvgId(target);
    return id == 'traps' ||
        id == 'traps-middle' ||
        id == 'rear-shoulders' ||
        id == 'triceps' ||
        id == 'lats' ||
        id == 'lowerback' ||
        id == 'glutes' ||
        id == 'hamstrings';
  }

  /// Colorizes the SVG string by replacing CSS variables with visible hex colors
  /// and highlighting the active target muscle group.
  String _colorizeSvg(String rawSvg, String? activeId) {
    // 1. Replace unsupported CSS variables with concrete hex values
    var result = rawSvg
        .replaceAll('rgb(var(--bodymap-stroke))', '#334155')
        .replaceAll('rgb(var(--muscle-primary))', '#EF4444')
        .replaceAll('rgb(var(--canvas))', '#FFFFFF')
        .replaceAll('class="hidden"', 'display="none"');

    // 2. Colorize all bodymap muscle groups (<g class="bodymap..." ...>)
    final groupRegex = RegExp(r'<g\s+([^>]*?)class="bodymap[^"]*"([^>]*?)>(.*?)</g>', dotAll: true);
    result = result.replaceAllMapped(groupRegex, (m) {
      final prefix = m.group(1) ?? '';
      final suffix = m.group(2) ?? '';
      final inner = m.group(3) ?? '';
      final attrs = '$prefix $suffix';
      final idMatch = RegExp(r'id="([^"]+)"').firstMatch(attrs);
      final id = idMatch?.group(1);

      final isSelected = activeId != null &&
          (id == activeId ||
              (activeId == 'traps' && (id == 'traps' || id == 'traps-middle')) ||
              (activeId == 'front-shoulders' && id == 'front-shoulders') ||
              (activeId == 'rear-shoulders' && id == 'rear-shoulders'));

      // Vibrant red/coral for highlighted target, soft visible slate for resting muscles
      final color = isSelected ? '#EF4444' : '#CBD5E1';

      var newInner = inner
          .replaceAll('fill="currentColor"', 'fill="$color"')
          .replaceAll('fill="mw-red"', 'fill="$color"');

      final cleanAttrs = attrs.replaceAll(RegExp(r'fill="[^"]*"'), '');

      return '<g $cleanAttrs fill="$color">$newInner</g>';
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final activeMuscles = _showBack ? _backMuscles : _frontMuscles;
    final activeId = _targetToSvgId(widget.selectedTarget);
    final rawSvg = _showBack ? _cachedBackSvg : _cachedFrontSvg;
    final processedSvg = rawSvg != null ? _colorizeSvg(rawSvg, activeId) : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Front/Back switch & Clear Filter
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.accessibility_new,
                      size: 18,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _showBack ? 'Posterior (Back)' : 'Anterior (Front)',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (widget.selectedTarget != null) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => widget.onTargetSelected(null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close, size: 12, color: Colors.red),
                              SizedBox(width: 2),
                              Text(
                                'Clear',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _switchBtn(
                      'Front',
                      !_showBack,
                      () => setState(() => _showBack = false),
                    ),
                    _switchBtn(
                      'Back',
                      _showBack,
                      () => setState(() => _showBack = true),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Side-by-side SVG illustration and muscle group buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interactive SVG figure with tap-to-flip
              GestureDetector(
                onTap: () => setState(() => _showBack = !_showBack),
                child: Container(
                  width: 116,
                  height: 196,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.selectedTarget != null
                          ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                          : Colors.grey.shade200,
                      width: widget.selectedTarget != null ? 1.5 : 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (processedSvg != null)
                        SvgPicture.string(
                          processedSvg,
                          fit: BoxFit.contain,
                        )
                      else
                        const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sync, size: 10, color: Colors.black54),
                              const SizedBox(width: 3),
                              Text(
                                _showBack ? 'Back (Tap to flip)' : 'Front (Tap to flip)',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Muscle chips grid
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: activeMuscles.map((m) {
                    final targetId = _targetToSvgId(m['target']);
                    final isSel = activeId == targetId;
                    return ChoiceChip(
                      label: Text(m['name']!),
                      selected: isSel,
                      showCheckmark: false,
                      selectedColor: const Color(0xFFEF4444),
                      backgroundColor: Colors.grey.shade100,
                      visualDensity: VisualDensity.compact,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSel ? Colors.white : Colors.black87,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSel ? const Color(0xFFEF4444) : Colors.transparent,
                        ),
                      ),
                      onSelected: (selected) {
                        widget.onTargetSelected(selected ? m['target'] : null);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _switchBtn(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? Colors.black87 : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}
