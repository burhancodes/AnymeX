import 'dart:ui';

import 'package:aurora/components/setting/scheme_varaint_dialog.dart';
import 'package:flutter/material.dart';
import 'package:aurora/components/common/custom_tile.dart';
import 'package:aurora/components/common/switch_tile_stateless.dart';
import 'package:aurora/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> with WidgetsBindingObserver {
  final box = Hive.box('login-data');
  late final palettedMode = box.get('PaletteMode', defaultValue: 'Material');
  late bool isLightMode = box.get('Theme', defaultValue: 'dark') == 'light';
  late bool isDarkMode = box.get('Theme', defaultValue: 'dark') == 'dark';
  bool? value1;
  bool? value2;
  bool? value3;
  int? selectedIndex;
  int? selectedColorIndex;
  bool? isCustomTheme;

  List<MaterialColor> colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
  ];

  List<String> colorsName = [
    'Red',
    'Pink',
    'Purple',
    'DeepPurple',
    'Indigo',
    'Blue',
    'LightBlue',
    'Cyan',
    'Teal',
    'Green',
    'LightGreen',
    'Lime',
    'Yellow',
    'Amber',
    'Orange',
    'DeepOrange',
    'Brown',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initStates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isLight =
        PlatformDispatcher.instance.platformBrightness == Brightness.light;
    if (selectedIndex == 2) {
      if (isLight) {
        themeProvider.setLightModeWithoutDB();
      } else {
        themeProvider.setDarkModeWithoutDB();
      }
    }
  }

  void _selectChip(int index) {
    setState(() {
      selectedIndex = index;
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      if (index == 0) {
        themeProvider.setLightMode();
      } else if (index == 1) {
        themeProvider.setDarkMode();
      } else if (index == 2) {
        Hive.box('login-data').put('Theme', 'system');
        didChangePlatformBrightness();
      }
      box.put(
          'Theme',
          index == 0
              ? 'light'
              : index == 1
                  ? 'dark'
                  : 'system');
    });
  }

  void _selectColor(int index) {
    setState(() {
      selectedColorIndex = index;
      MaterialColor newColor = colors[selectedColorIndex ?? 0];
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      themeProvider.changeSeedColor(newColor);
      box.put('SelectedColorIndex', selectedColorIndex);
    });
  }

  void _toggleSwitch(int index) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    setState(() {
      if (index == 1) {
        value1 = true;
        value3 = false;
        if (value1!) {
          isCustomTheme = false;
          themeProvider.loadDynamicTheme();
        }
        box.put('PaletteMode', 'Material');
      } else if (index == 2) {
        value2 = !value2!;
        box.put('isOled', value2);
        if (value2!) {
          themeProvider.setOledTheme(true);
        } else {
          themeProvider.setOledTheme(false);
        }
      } else if (index == 3) {
        value1 = false;
        value3 = true;
        box.put('PaletteMode', 'Custom');
        if (value3!) {
          isCustomTheme = true;
        }
      }
    });
  }

  void _showSchemeVariantDialog() {
    showDialog(
      context: context,
      builder: (context) => SchemeVariantDialog(
        selectedVariant: box.get('DynamicPalette', defaultValue: 'tonalSpot'),
        onVariantSelected: (variant) {
          final themeProvider =
              Provider.of<ThemeProvider>(context, listen: false);
          box.put('DynamicPalette', variant);
          if (isLightMode) {
            themeProvider.setLightMode();
          } else {
            themeProvider.setDarkMode();
          }
        },
      ),
    );
  }

  void initStates() {
    // Themes Switches
    value1 = box.get('PaletteMode') == 'Material';
    value2 = box.get('isOled', defaultValue: false);
    value3 = box.get('PaletteMode') == 'Custom';
    if (value1!) {
      isCustomTheme = false;
    } else {
      isCustomTheme = true;
    }

    // Light and Dark Mode Chips
    if (isLightMode) {
      selectedIndex = 0;
    } else if (isDarkMode) {
      selectedIndex = 1;
    } else {
      selectedIndex = 2;
    }

    int? colorIndex = box.get('SelectedColorIndex');
    if (colorIndex != null && colorIndex < colors.length) {
      selectedColorIndex = colorIndex;
    } else {
      selectedColorIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  IconlyBroken.arrow_left_2,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Themes',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: _showSchemeVariantDialog,
                    icon: const Icon(
                      Icons.palette,
                      size: 40,
                    ))
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Theme',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .inverseSurface
                            .withOpacity(0.8))),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Icon(Icons.sunny, size: 20),
                      selected: selectedIndex == 0,
                      onSelected: (bool selected) {
                        _selectChip(0);
                      },
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Icon(Iconsax.moon, size: 20),
                      selected: selectedIndex == 1,
                      onSelected: (bool selected) {
                        _selectChip(1);
                      },
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Icon(Iconsax.autobrightness, size: 20),
                      selected: selectedIndex == 2,
                      onSelected: (bool selected) {
                        _selectChip(2);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          SwitchTileStateless(
            icon: Iconsax.paintbucket5,
            title: 'Material You',
            value: value1!,
            onChanged: (value) {
              _toggleSwitch(1);
            },
            description: 'Change the app theme',
            onTap: () {
              Provider.of<ThemeProvider>(context).loadDynamicTheme();
              Provider.of<ThemeProvider>(context).updateTheme();
            },
          ),
          CustomTile(
              icon: Iconsax.paintbucket,
              title: 'Palette',
              onTap: _showSchemeVariantDialog,
              description: 'Change color styles!'),
          SwitchTileStateless(
            icon: Iconsax.moon5,
            title: 'Oled Theme Variant',
            value: value2!,
            onChanged: (value) {
              _toggleSwitch(2);
            },
            description: 'Make it super dark',
            onTap: () {},
          ),
          SwitchTileStateless(
            icon: Iconsax.info_circle5,
            title: 'Custom Theme',
            value: value3!,
            onChanged: (value) {
              _toggleSwitch(3);
            },
            description: 'Use your own color!',
            onTap: () {},
          ),
          isCustomTheme! ? ColorChips() : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Padding ColorChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Wrap(
        children: colorsName.map<Widget>((color) {
          final index = colorsName.indexOf(color);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: ChoiceChip(
              avatar: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: colors[index]),
              ),
              label: Text(color),
              selected: selectedColorIndex == colorsName.indexOf(color),
              onSelected: (value) {
                _selectColor(index);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  DropdownMenuItem<int> _buildDropdownMenuItem(int value, String label) {
    return DropdownMenuItem<int>(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(label),
        ),
      ),
    );
  }
}
