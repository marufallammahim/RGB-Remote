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
return Card(
color: AppColors.kRemoteColor,
margin: EdgeInsets.zero,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(30),
side: const BorderSide(
color: AppColors.kBorderColor,
width: 6,
),
),
child: Padding(
padding: const EdgeInsets.symmetric(
horizontal: 8,
vertical: 14,
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: _buttonLayout.map((row) {
return Padding(
padding: const EdgeInsets.symmetric(
vertical: 3,
),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
mainAxisSize: MainAxisSize.min,
children: row.map((i) {
return RemoteButton(
prontoData[i],
labelStyle: _getLabelStyle(i),
);
}).toList(),
),
);
}).toList(),
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

if ([7].contains(index)) {
  return AppTextStyle.kBS15W500;
}

if ([8, 9, 10, 11].contains(index)) {
  return AppTextStyle.kWS10W500;
}

return null;

}
}
