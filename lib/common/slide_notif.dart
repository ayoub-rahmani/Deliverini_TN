import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class ToastService {
  static OverlayEntry? _currentToast;

  static void show(
      BuildContext context, {
        required String message,
        required ToastType type,
        Duration duration = const Duration(seconds: 3),
        String? title,
      }) {
    // Remove any existing toast
    _removeCurrentToast();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        title: title,
        onDismiss: () => _removeToast(overlayEntry),
      ),
    );

    _currentToast = overlayEntry;
    overlay.insert(overlayEntry);

    // Auto dismiss after duration
    Future.delayed(duration, () {
      _removeToast(overlayEntry);
    });

    // Add haptic feedback
    switch (type) {
      case ToastType.success:
        HapticFeedback.lightImpact();
        break;
      case ToastType.error:
        HapticFeedback.heavyImpact();
        break;
      case ToastType.warning:
      case ToastType.info:
        HapticFeedback.selectionClick();
        break;
    }
  }

  static void _removeToast(OverlayEntry entry) {
    if (_currentToast == entry) {
      _currentToast = null;
    }
    entry.remove();
  }

  static void _removeCurrentToast() {
    _currentToast?.remove();
    _currentToast = null;
  }

  // Convenience methods
  static void success(BuildContext context, String message, {String? title}) {
    show(context, message: message, type: ToastType.success, title: title);
  }

  static void error(BuildContext context, String message, {String? title}) {
    show(context, message: message, type: ToastType.error, title: title);
  }

  static void warning(BuildContext context, String message, {String? title}) {
    show(context, message: message, type: ToastType.warning, title: title);
  }

  static void info(BuildContext context, String message, {String? title}) {
    show(context, message: message, type: ToastType.info, title: title);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final String? title;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
    this.title,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Slide from right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _fadeController.reverse();
    await _slideController.reverse();
    widget.onDismiss();
  }

  ToastConfig _getConfig() {
    switch (widget.type) {
      case ToastType.success:
        return ToastConfig(
          backgroundColor: const Color(0xFF10B981),
          iconColor: Colors.white,
          icon: Icons.check_circle,
          textColor: Colors.white,
        );
      case ToastType.error:
        return ToastConfig(
          backgroundColor: const Color(0xFFEF4444),
          iconColor: Colors.white,
          icon: Icons.error,
          textColor: Colors.white,
        );
      case ToastType.warning:
        return ToastConfig(
          backgroundColor: const Color(0xFFF59E0B),
          iconColor: Colors.white,
          icon: Icons.warning,
          textColor: Colors.white,
        );
      case ToastType.info:
        return ToastConfig(
          backgroundColor: const Color(0xFF3B82F6),
          iconColor: Colors.white,
          icon: Icons.info,
          textColor: Colors.white,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return Positioned(
      top: statusBarHeight + 20, // Position in header zone
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth * 0.85,
                  minWidth: screenWidth * 0.4,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: config.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: config.backgroundColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      config.icon,
                      color: config.iconColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.title != null) ...[
                            Text(
                              widget.title!,
                              style: TextStyle(
                                color: config.textColor,
                                fontFamily: 'NotoSansArabic',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: config.textColor,
                              fontFamily: 'NotoSansArabic',
                              fontSize: widget.title != null ? 12 : 14,
                              fontWeight: widget.title != null
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.close,
                          color: config.iconColor,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ToastConfig {
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final Color textColor;

  ToastConfig({
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    required this.textColor,
  });
}