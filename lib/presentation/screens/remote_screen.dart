import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:rgb_remote/core/config/app_color.dart';
import 'package:rgb_remote/presentation/screens/components/tooltip_widget.dart';

import '../../application/services/back_press_handler.dart';
import '../../application/services/settings_service.dart';
import '../../data/models/remote_config.dart';
import '../../data/models/pronto_command.dart';
import '../../domain/entities/app_settings.dart';
import '../../resources/pronto_data.dart';
import '../../plugins/ir_sensor_plugin.dart';
import '../widgets/ir_light_effect.dart';
import 'components/remote_ui.dart';
import 'settings_screen.dart';

final StreamController<EventState> eventController =
    StreamController<EventState>.broadcast();

/// Current command shown in the remote's built-in status display.
final ValueNotifier<String> remoteStatusNotifier =
    ValueNotifier<String>('STATUS:READY • SELECT A COLOR');

enum EventState {
lightEffect,
showPrompt,
}

class RemoteScreen extends StatefulWidget {
const RemoteScreen({super.key});

@override
State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen>
with SingleTickerProviderStateMixin {
final SettingsService _settingsService = SettingsService();
final JustTheController _tooltipController = JustTheController();

late AnimationController _animationController;
late Animation<double> _opacityAnimation;
late StreamSubscription<EventState> _subscription;

late int _selectedRemote;

final List<RemoteConfig> _remotes = [
RemoteConfig(
name: 'Preset ONE ✨ ',
ui: RemoteUI(
prontoData: getProntoData(ProntoDataType.type1),
),
),
RemoteConfig(
name: 'Preset TWO 🤌🏻 ',
ui: RemoteUI(
prontoData: getProntoData(ProntoDataType.type2),
),
),
];

@override
void initState() {
super.initState();

_selectedRemote = _settingsService.settingsNotifier.value.remoteIndex
    .clamp(0, _remotes.length - 1)
    .toInt();

_initializeAnimationController();
IrSensorPlugin.installHardwareVolumeKeyHandler();
IrSensorPlugin.onHardwareVolumeKey = _handleHardwareVolumeKey;

}


Future<void> _handleHardwareVolumeKey(bool increase) async {
  if (!mounted) return;
  final commandName = increase ? 'B+' : 'B-';
  final commands = _remotes[_selectedRemote].ui.prontoData;
  ProntoCommand? command;
  for (final item in commands) {
    if (item.name.trim() == commandName) {
      command = item;
      break;
    }
  }
  if (command == null) return;
  remoteStatusNotifier.value = increase
      ? 'SENDING: BRIGHTNESS UP'
      : 'SENDING: BRIGHTNESS DOWN';
  try {
    await IrSensorPlugin.transmitString(pattern: command.pattern);
    remoteStatusNotifier.value = increase
        ? 'VOL+ • BRIGHTNESS UP • SENT'
        : 'VOL- • BRIGHTNESS DOWN • SENT';
  } catch (error) {
    remoteStatusNotifier.value = 'SEND FAILED • BRIGHTNESS';
    debugPrint('Hardware volume brightness command failed: $error');
  }
}

void _initializeAnimationController() {
_animationController = AnimationController(
duration: const Duration(milliseconds: 100),
vsync: this,
);

_animationController.addStatusListener((status) {
  if (status == AnimationStatus.completed) {
    _animationController.reverse();
  }
});

_opacityAnimation = Tween<double>(
  begin: 0.0,
  end: 1.0,
).animate(
  CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  ),
);

_subscription = eventController.stream.listen((event) {
  if (!mounted) return;

  switch (event) {
    case EventState.lightEffect:
      _animationController.forward();
      break;

    case EventState.showPrompt:
      _tooltipController.showTooltip(immediately: true);
      break;
  }
});

}

Future<void> _updateSelectedRemote(int index) async {
final int newIndex = index.clamp(0, _remotes.length - 1).toInt();

if (newIndex == _selectedRemote) return;

setState(() {
  _selectedRemote = newIndex;
});

await _settingsService.updateRemote(newIndex);

}

@override
void dispose() {
_subscription.cancel();
IrSensorPlugin.onHardwareVolumeKey = null;
_animationController.dispose();
_tooltipController.hideTooltip(immediately: true);

super.dispose();

}

@override
Widget build(BuildContext context) {
return PopScope(
canPop: false,
onPopInvokedWithResult: (didPop, result) async {
if (didPop) return;
await BackPressHandler.handleBackPress();
},
child: Scaffold(
appBar: AppBar(
actions: [
IconButton(
onPressed: () {
Navigator.pushNamed(
context,
SettingsScreen.routeName,
);
},
icon: const Icon(Icons.settings),
),
],
),
body: ValueListenableBuilder<AppSettings>(
valueListenable: _settingsService.settingsNotifier,
builder: (context, settings, child) {
return Column(
children: [
_buildRemoteSelector(),
Expanded(
child: LayoutBuilder(
builder: (context, constraints) {
return SingleChildScrollView(
padding: const EdgeInsets.symmetric(
horizontal: 8,
vertical: 8,
),
child: ConstrainedBox(
constraints: BoxConstraints(
minHeight:
(constraints.maxHeight - 16).clamp(
0.0,
double.infinity,
),
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
AnimatedBuilder(
animation: _animationController,
builder: (context, child) {
return Opacity(
opacity: _opacityAnimation.value,
child: child,
);
},
child: const IRLightEffect(),
),
const SizedBox(height: 8),

                          // Remote stays centered and uses its own size.
                          Center(
                            child: _remotes[_selectedRemote].ui,
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  ),
);

}

Widget _buildRemoteSelector() {
return Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
IconButton(
icon: const Icon(Icons.arrow_left),
onPressed: _selectedRemote > 0
? () => _updateSelectedRemote(_selectedRemote - 1)
: null,
),
JustTheTooltip(
controller: _tooltipController,
preferredDirection: AxisDirection.up,
backgroundColor: AppColors.kWhiteColor,
isModal: true,
showDuration: const Duration(seconds: 10),
margin: const EdgeInsets.all(10),
borderRadius: BorderRadius.circular(8),
content: TooltipWidget(
onDismiss: () {
_tooltipController.hideTooltip(immediately: true);
},
),
child: Text(
'${_remotes[_selectedRemote].name}/${_remotes.length}',
style: const TextStyle(
fontWeight: FontWeight.w500,
),
),
),
IconButton(
icon: const Icon(Icons.arrow_right),
onPressed: _selectedRemote < _remotes.length - 1
? () => _updateSelectedRemote(_selectedRemote + 1)
: null,
),
],
);
}
}
