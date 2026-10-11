import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/config/app_color.dart';
import '../../../core/config/app_text.dart';
import '../../../data/models/pronto_command.dart';
import '../../widgets/remote_button.dart';

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

        // Keep the panel in the same centered position, while making it a
        // little wider than the original and adapting safely to small screens.
        final panelWidth = math.min(availableWidth, screenWidth * 0.92);
        const borderWidth = 5.0;
        const horizontalPadding = 8.0;
        const verticalPadding = 11.0;
        final buttonCellWidth =
            (panelWidth - borderWidth * 2 - horizontalPadding * 2) / 4;
        final buttonSize = math.min(74.0, buttonCellWidth - 8.0).clamp(48.0, 74.0);

        return SizedBox(
          width: panelWidth,
          child: Card(
            elevation: 10,
            shadowColor: const Color(0x66000000),
            color: AppColors.kRemoteColor,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(
                color: AppColors.kBorderColor,
                width: borderWidth,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buttonLayout.map((row) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: row.map((index) {
                        return Expanded(
                          child: Center(
                            child: RemoteButton(
                              prontoData[index],
                              buttonSize: buttonSize.toDouble(),
                              labelStyle: _getLabelStyle(index),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
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
