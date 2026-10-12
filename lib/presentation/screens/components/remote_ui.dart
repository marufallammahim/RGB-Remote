import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/config/app_color.dart';
import '../../../core/config/app_text.dart';
import '../../../data/models/pronto_command.dart';
import '../../widgets/remote_button.dart';
import '../remote_screen.dart';

final List<List<int>> _buttonLayout = [
  [0, 1, 2, 3],
  [4, 5, 6, 7],
  [12, 16, 20, 8],
  [13, 17, 21, 9],
  [14, 18, 22, 10],
  [15, 19, 23, 11],
];

class RemoteUI extends StatelessWidget {
  final List<ProntoCommand> prontoData;

  const RemoteUI({
    super.key,
    required this.prontoData,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenWidth;

        // Preserve the existing remote width and centered layout.
        final panelWidth = math.min(
          availableWidth,
          screenWidth * 0.70,
        );

        const borderWidth = 5.0;
        const horizontalPadding = 7.0;
        const verticalPadding = 10.0;

        final buttonCellWidth =
            (panelWidth -
                    borderWidth * 2 -
                    horizontalPadding * 2) /
                4;

        final buttonSize = math
            .min(56.0, buttonCellWidth - 8.0)
            .clamp(36.0, 56.0)
            .toDouble();

        return SizedBox(
          width: panelWidth,
          child: Card(
            elevation: 10,
            shadowColor: const Color(0x66000000),
            color: AppColors.kRemoteColor,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: const BorderSide(
                color: AppColors.kBorderColor,
                width: borderWidth,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _RemoteStatusDisplay(),
                  const SizedBox(height: 18),
                  ..._buttonLayout.map(
                    (row) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.5),
                      child: Row(
                        children: row.map((index) {
                          return Expanded(
                            child: Center(
                              child: RemoteButton(
                                prontoData[index],
                                buttonSize: buttonSize,
                                labelStyle: _getLabelStyle(index),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  TextStyle? _getLabelStyle(int index) {
    if ([2, 3, 4, 5, 6].contains(index)) {
      return AppTextStyle.kWS15W500;
    }

    if (index == 7) {
      return AppTextStyle.kBS15W500;
    }

    if ([8, 9, 10, 11].contains(index)) {
      return AppTextStyle.kWS10W500;
    }

    return null;
  }
}

/// Slim, bordered status screen integrated into the remote's top area.
class _RemoteStatusDisplay extends StatefulWidget {
  const _RemoteStatusDisplay();

  @override
  State<_RemoteStatusDisplay> createState() =>
      _RemoteStatusDisplayState();
}

class _RemoteStatusDisplayState extends State<_RemoteStatusDisplay> {
  String _shown = '';
  int _generation = 0;

  @override
  void initState() {
    super.initState();

    _shown = remoteStatusNotifier.value;
    remoteStatusNotifier.addListener(_onStatusChanged);
  }

  void _onStatusChanged() {
    if (!mounted) return;

    final target = remoteStatusNotifier.value;
    final generation = ++_generation;

    setState(() {
      _shown = '';
    });

    unawaited(_typeNext(target, generation, 0));
  }

  Future<void> _typeNext(
    String target,
    int generation,
    int index,
  ) async {
    if (!mounted || generation != _generation) return;

    if (index >= target.length) return;

    await Future<void>.delayed(
      const Duration(milliseconds: 34),
    );

    if (!mounted || generation != _generation) return;

    setState(() {
      _shown = target.substring(0, index + 1);
    });

    unawaited(
      _typeNext(target, generation, index + 1),
    );
  }

  @override
  void dispose() {
    // Invalidate any pending animation before disposing.
    _generation++;
    remoteStatusNotifier.removeListener(_onStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 42,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFC),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFF294453),
          width: 2.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _shown,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFF203744),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.05,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
