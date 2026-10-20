
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Hyperlink extends StatelessWidget {
  final String text;
  final String url;
  final TextStyle style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  /// Customize link appearance.
  final Color? color;
  final Color? hoverColor;
  final Color? splashColor;
  final bool underline;
  final bool showIcon;
  final IconData icon;
  final double iconSize;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const Hyperlink(
    this.text,
    this.url, {
    super.key,
    this.textAlign,
    this.overflow,
    this.style = const TextStyle(),
    this.maxLines,
    this.color,
    this.hoverColor,
    this.splashColor,
    this.underline = false,
    this.showIcon = false,
    this.icon = Icons.open_in_new_rounded,
    this.iconSize = 15,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 4,
      vertical: 3,
    ),
  });

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      _showError(context, 'Invalid or unsupported link.');
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        _showError(context, 'Could not open this link.');
      }
    } catch (_) {
      if (context.mounted) {
        _showError(context, 'Something went wrong while opening the link.');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor =
        color ?? theme.colorScheme.primary;

    final linkStyle = style.copyWith(
      color: effectiveColor,
      decoration: underline
          ? TextDecoration.underline
          : style.decoration,
      decorationColor: effectiveColor,
      decorationThickness: 1.3,
      fontWeight: style.fontWeight ?? FontWeight.w600,
    );

    return Semantics(
      link: true,
      label: text,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openUrl(context),
          borderRadius: BorderRadius.circular(borderRadius),
          hoverColor: hoverColor ??
              effectiveColor.withValues(alpha: 0.07),
          splashColor: splashColor ??
              effectiveColor.withValues(alpha: 0.12),
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: _alignment(textAlign),
              children: [
                Flexible(
                  child: Text(
                    text,
                    style: linkStyle,
                    textAlign: textAlign,
                    overflow: overflow,
                    maxLines: maxLines,
                  ),
                ),
                if (showIcon) ...[
                  const SizedBox(width: 5),
                  Icon(
                    icon,
                    size: iconSize,
                    color: effectiveColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  MainAxisAlignment _alignment(TextAlign? alignment) {
    switch (alignment) {
      case TextAlign.center:
        return MainAxisAlignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return MainAxisAlignment.end;
      default:
        return MainAxisAlignment.start;
    }
  }
}
