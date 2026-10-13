const Object _unchangedSoundName = Object();

class AppSettings {
  final bool isVibrationEnabled;
  final bool isLightEnabled;
  final bool isSoundEnabled;
  final String? soundFileName;
  final int remoteIndex;
  final String themeName;

  const AppSettings({
    this.isVibrationEnabled = false,
    this.isLightEnabled = false,
    this.isSoundEnabled = false,
    this.soundFileName,
    this.remoteIndex = 0,
    this.themeName = 'dark',
  });

  AppSettings copyWith({
    bool? isVibrationEnabled,
    bool? isLightEnabled,
    bool? isSoundEnabled,
    Object? soundFileName = _unchangedSoundName,
    int? remoteIndex,
    String? themeName,
  }) {
    return AppSettings(
      isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
      isLightEnabled: isLightEnabled ?? this.isLightEnabled,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      soundFileName: identical(soundFileName, _unchangedSoundName)
          ? this.soundFileName
          : soundFileName as String?,
      remoteIndex: remoteIndex ?? this.remoteIndex,
      themeName: themeName ?? this.themeName,
    );
  }
}