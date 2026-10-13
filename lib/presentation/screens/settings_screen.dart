import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rgb_remote/core/extensions/string_extensions.dart';

import '../../application/services/settings_service.dart';
import '../../core/config/app_color.dart';
import '../../core/config/app_text.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/app_settings.dart';
import '../../plugins/ir_sensor_plugin.dart';
import 'components/about_app.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String routeName = "/settings";

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService();
  Map<String, int> _rawSoundList = {};

  @override
  void initState() {
    super.initState();
    _loadSoundList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ValueListenableBuilder<AppSettings>(
        valueListenable: _settingsService.settingsNotifier,
        builder: (context, settings, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Appearance'),
                  subtitle: const Text('Choose the app background style'),
                  trailing: DropdownButton<String>(
                    value: settings.themeName,
                    borderRadius: BorderRadius.circular(12),
                    onChanged: (value) {
                      if (value != null) _updateTheme(value);
                    },
                    items: const [
                      DropdownMenuItem(value: 'dark', child: Text('Dark')),
                      DropdownMenuItem(value: 'amoled', child: Text('Pure Black')),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text(AppStrings.vibrateOnTap),
                  subtitle: Text(
                    AppStrings.vibrateOnTapDesc,
                    style: AppTextStyle.kGS13W400,
                  ),
                  trailing: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: settings.isVibrationEnabled,
                      onChanged: _toggleVibration,
                      activeThumbColor: AppColors.kWhiteColor,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(AppStrings.lightOnTap),
                  subtitle: Text(
                    AppStrings.lightOnTapDesc,
                    style: AppTextStyle.kGS13W400,
                  ),
                  trailing: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: settings.isLightEnabled,
                      onChanged: _toggleLight,
                      activeThumbColor: AppColors.kWhiteColor,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(AppStrings.soundOnTap),
                  subtitle: Text(
                    AppStrings.soundOnTapDesc,
                    style: AppTextStyle.kGS13W400,
                  ),
                  trailing: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: settings.isSoundEnabled,
                      onChanged: _toggleSound,
                      activeThumbColor: AppColors.kWhiteColor,
                    ),
                  ),
                ),
                ListTile(
                  enabled: settings.isSoundEnabled,
                  title: const Text(AppStrings.tapSound),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _rawSoundList.containsKey(settings.soundFileName)
                          ? settings.soundFileName
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      style: TextStyle(
                        color: AppColors.kWhiteColor.withAlpha(200),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.kGreyColor.withAlpha(0xAA),
                        size: 18,
                      ),
                      onChanged: settings.isSoundEnabled ? _setSoundFile : null,
                      items: _rawSoundList.keys.map<DropdownMenuItem<String>>((String fileName) {
                        return DropdownMenuItem<String>(
                          value: fileName,
                          child: Text(fileName.formatName()),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                child!,
              ],
            ),
          );
        },
        child: const AboutApp(),
      ),
    );
  }

  Future<void> _loadSoundList() async {
    try {
      final rawSoundList = await IrSensorPlugin.rawSoundList();
      if (!mounted) return;
      setState(() => _rawSoundList = rawSoundList);

      final settings = _settingsService.settingsNotifier.value;
      if ((settings.soundFileName == null ||
              !rawSoundList.containsKey(settings.soundFileName)) &&
          rawSoundList.isNotEmpty) {
        await _settingsService.updateSoundName(rawSoundList.keys.first);
      }
    } on PlatformException catch (e) {
      debugPrint(e.message);
    } catch (e) {
      debugPrint('Unable to load optional sound list: $e');
    }
  }

  Future<void> _updateTheme(String themeName) async {
    try {
      await _settingsService.updateTheme(themeName);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save appearance setting.')),
      );
    }
  }

  Future<void> _toggleVibration(bool isEnabled) async {
    try {
      await _settingsService.updateVibration(isEnabled);
    } catch (error) {
      _showSaveError();
    }
  }

  Future<void> _toggleLight(bool isEnabled) async {
    try {
      await _settingsService.updateLight(isEnabled);
    } catch (error) {
      _showSaveError();
    }
  }

  Future<void> _toggleSound(bool isEnabled) async {
    try {
      await _settingsService.updateSound(isEnabled);
    } catch (error) {
      _showSaveError();
    }
  }

  void _showSaveError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not save setting. Please try again.')),
    );
  }

  Future<void> _setSoundFile(String? fileName) async {
    if (fileName != null) {
      try {
        await _settingsService.updateSoundName(fileName);
      } catch (error) {
        _showSaveError();
      }
    }
  }
}
