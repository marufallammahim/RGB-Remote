import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:material_neumorphic/material_neumorphic.dart';

import '../../application/services/remote_assist_service.dart';
import '../../application/services/settings_service.dart';
import '../../core/config/app_color.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/hex_color.dart';
import '../../data/models/pronto_command.dart';
import '../../domain/entities/app_settings.dart';
import '../../plugins/ir_sensor_plugin.dart';
import '../screens/remote_screen.dart';

class RemoteButton extends StatefulWidget {
  final ProntoCommand command;
  final TextStyle? labelStyle;
  final double buttonSize;

  const RemoteButton(
    this.command, {
    super.key,
    this.labelStyle,
    this.buttonSize = 70,
  });

  @override
  State<RemoteButton> createState() => _RemoteButtonState();
}

class _RemoteButtonState extends State<RemoteButton> {
  final SettingsService _settingsService = SettingsService();

  Future<void> _handlePressed(AppSettings settings) async {
    remoteStatusNotifier.value = 'SENDING: ${widget.command.name.trim().toUpperCase()}';

    if (settings.isLightEnabled) {
      eventController.add(EventState.lightEffect);
    }

    // Start the IR call immediately. Android now runs the hardware transmit
    // on a worker thread, so the UI stays responsive while the signal is sent.
    final transmitFuture = IrSensorPlugin.transmitString(
      pattern: widget.command.pattern,
    );

    // Optional feedback runs alongside the IR call rather than delaying it.
    if (settings.isSoundEnabled) {
      unawaited(_runOptionalFeedback(
        () => IrSensorPlugin.playSound(soundName: settings.soundFileName),
      ));
    }
    if (settings.isVibrationEnabled) {
      unawaited(_runOptionalFeedback(IrSensorPlugin.vibrate));
    }

    try {
      await transmitFuture;
      remoteStatusNotifier.value = '${_statusForCommand(widget.command.name)} • SENT';
      unawaited(
        RemoteAssistPromptService.maybeShowPrompt(
          onPrompt: () {
            eventController.add(EventState.showPrompt);
          },
        ).catchError((Object error) {
          debugPrint('Remote-assist prompt skipped: $error');
        }),
      );
    } on PlatformException catch (error) {
      remoteStatusNotifier.value = 'SEND FAILED • ${widget.command.name.trim().toUpperCase()}';
      if (error.code == '1') {
        AlertController.show(
          AppStrings.irBlasterUnavailableTitle,
          AppStrings.irBlasterUnavailableMessage,
          TypeAlert.error,
        );
      } else {
        AlertController.show(
          AppStrings.error,
          error.message ?? AppStrings.error,
          TypeAlert.error,
        );
      }
    } catch (error) {
      remoteStatusNotifier.value = 'SEND FAILED • ${widget.command.name.trim().toUpperCase()}';
      AlertController.show(
        AppStrings.error,
        error.toString(),
        TypeAlert.error,
      );
    }
  }


  String _statusForCommand(String rawName) {
    final name = rawName.trim().toUpperCase();
    const names = <String, String>{
      'R': 'RED', 'R1': 'ORANGE', 'R2': 'AMBER', 'R3': 'GOLDEN', 'R4': 'YELLOW',
      'G': 'GREEN', 'G1': 'LIGHT GREEN', 'G2': 'TURQUOISE', 'G3': 'CYAN', 'G4': 'SKY BLUE',
      'B': 'BLUE', 'B1': 'LIGHT BLUE', 'B2': 'INDIGO', 'B3': 'VIOLET', 'B4': 'PINK',
      'W': 'WHITE', 'ON': 'POWER ON', 'OFF': 'POWER OFF',
      'B+': 'BRIGHTNESS UP', 'B-': 'BRIGHTNESS DOWN',
      'FLASH': 'FLASH', 'STROBE': 'STROBE', 'FADE': 'FADE', 'SMOOTH': 'SMOOTH',
    };
    final label = names[name] ?? name;
    if (name == 'OFF') return 'LIGHT IS OFF';
    if (name == 'ON') return 'LIGHT IS ON';
    if (name == 'FLASH' || name == 'STROBE' || name == 'FADE' || name == 'SMOOTH') {
      return '$label IS PLAYING';
    }
    return '$label IS PLAYING';
  }

  Future<void> _runOptionalFeedback(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      // Sound/vibration are optional. A failure here must not affect IR control.
      debugPrint('Optional remote feedback failed: $error');
    }
  }

  Color _vibrantButtonColor(String hex) {
    final base = HexColor(hex);
    final hsl = HSLColor.fromColor(base);

    // Keep white controls crisp and the OFF control dark; boost the hue of
    // colored controls so the RGB swatches look clear instead of pastel.
    if (hsl.lightness >= 0.93) return const Color(0xFFFFFFFF);
    if (hsl.lightness <= 0.24) return const Color(0xFF282828);

    if (hsl.saturation < 0.18) {
      return HSLColor.fromAHSL(
        1,
        hsl.hue,
        0.30,
        0.47,
      ).toColor();
    }

    final saturation = hsl.saturation < 0.88 ? 0.94 : hsl.saturation;
    final lightness = hsl.lightness.clamp(0.45, 0.58).toDouble();
    return HSLColor.fromAHSL(1, hsl.hue, saturation, lightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ValueListenableBuilder<AppSettings>(
        valueListenable: _settingsService.settingsNotifier,
        builder: (context, settings, child) {
          final buttonColor = _vibrantButtonColor(widget.command.color);
          return NeumorphicButton(
            onPressed: () => _handlePressed(settings),
            padding: EdgeInsets.zero,
            provideHapticFeedback: false,
            style: NeumorphicStyle(
              color: buttonColor,
              boxShape: NeumorphicBoxShape.circle(),
              lightSource: LightSource.topLeft,
              depth: 5,
              intensity: 0.95,
              surfaceIntensity: 0.38,
              shape: NeumorphicShape.convex,
              shadowLightColor: AppColors.kShadowLightColor,
              shadowDarkColor: AppColors.kShadowDarkColor.withAlpha(210),
              border: NeumorphicBorder(
                color: buttonColor.computeLuminance() > 0.75
                    ? const Color(0xFFD5E0E4)
                    : Colors.white.withAlpha(100),
                width: 1,
              ),
            ),
            child: SizedBox(
              width: widget.buttonSize,
              height: widget.buttonSize,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildChild(widget.command),
                  // Angled translucent shine like the reference image. This is
                  // decorative only and never intercepts the button tap.
                  Positioned(
                    top: widget.buttonSize * 0.12,
                    left: widget.buttonSize * 0.17,
                    child: IgnorePointer(
                      child: Transform.rotate(
                        angle: -0.72,
                        child: Container(
                          width: widget.buttonSize * 0.28,
                          height: widget.buttonSize * 0.085,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withAlpha(220),
                                Colors.white.withAlpha(25),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChild(ProntoCommand command) {
    return Center(
      child: widget.labelStyle != null
          ? Text(
              command.name,
              style: (widget.labelStyle ?? const TextStyle()).copyWith(
                color: _vibrantButtonColor(command.color).computeLuminance() < 0.32
                    ? Colors.white
                    : (widget.labelStyle?.color ?? AppColors.kBlackColor),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
          : Icon(
              command.icon,
              color: AppColors.kBlackColor,
              size: 24,
            ),
    );
  }
}
