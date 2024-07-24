import 'package:flutter/material.dart';
import 'package:sheraccerp/util/res_color.dart';

class _SettingsSwitchs extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final Color activeColor;
  final Color inactiveColor;

  const _SettingsSwitchs({
    Key? key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.activeColor = const Color(0xff0008B3), // Default active color
    this.inactiveColor = Colors.grey, // Default inactive color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
       trackOutlineWidth:
                                         MaterialStatePropertyAll(14),
                                    thumbIcon:
                                        MaterialStateProperty.all( Icon(
                                      Icons.circle,
                                      color: Color.fromARGB(255, 244, 242, 242),
                                      size: 27,
                                    )),
                                    trackOutlineColor:
                                         MaterialStatePropertyAll(Colors.white),
                                    thumbColor:
                                        MaterialStateProperty.all(Colors.white),
                                    activeTrackColor: kPrimaryColor,
                                    // inactiveTrackColor:  Color(0xffD9D9D9),
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: Color(0xff0008B3),
      inactiveTrackColor: Color(0xffD9D9D9),
    );
  }
}