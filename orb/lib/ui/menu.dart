import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:separated_column/separated_column.dart';
import 'package:separated_row/separated_row.dart';

import 'package:orb/config.dart';
import 'package:orb/connection.dart';
import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/card/util/button.dart';
import 'package:orb/ui/card/util/url.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/util.dart';

class OrbMenuState {
  final OrbEvent? _event;
  final List<List<dynamic>>? _menuStack;
  final void Function(OrbEvent?, List<List<dynamic>>?) _setMenuData;

  const OrbMenuState({
    required OrbEvent? event,
    required List<List<dynamic>>? menuStack,
    required void Function(OrbEvent?, List<List<dynamic>>?) setMenuData,
  })  : _event = event,
        _menuStack = menuStack,
        _setMenuData = setMenuData;

  void openMenu(OrbEventStream eventStream, List<dynamic> menu) {
    final event =
        eventStream.events.firstWhereOrNull(eventStream.isActiveEvent);
    if (event != null) {
      _setMenuData(event, [menu]);
    }
  }

  void pushMenu(List<dynamic> menu) {
    if (_event != null && _menuStack != null) {
      _setMenuData(_event!, [..._menuStack!, menu]);
    }
  }

  void popMenu() {
    if (_event != null && _menuStack != null) {
      _setMenuData(_event!, [..._menuStack!]..removeLast());
    }
  }

  void closeMenu() {
    _setMenuData(null, null);
  }

  List<List<dynamic>> getMenuStack(OrbEventStream eventStream) {
    if (_event != null &&
        _menuStack != null &&
        eventStream.isActiveEvent(_event!)) {
      return _menuStack!;
    } else {
      return [];
    }
  }

  static OrbMenuState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_OrbMenuInherited>()!
        .menu;
  }
}

class OrbMenuProvider extends StatefulWidget {
  final Widget child;

  const OrbMenuProvider({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _OrbMenuProviderState createState() => _OrbMenuProviderState();
}

class _OrbMenuProviderState extends State<OrbMenuProvider> {
  OrbEvent? event;
  List<List<dynamic>>? menuStack;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _OrbMenuInherited(
      menu: OrbMenuState(
        event: event,
        menuStack: menuStack,
        setMenuData: (newEvent, newMenuStack) {
          setState(() {
            event = newEvent;
            menuStack = newMenuStack;
          });
        },
      ),
      child: widget.child,
    );
  }
}

class _OrbMenuInherited extends InheritedWidget {
  final OrbMenuState menu;

  const _OrbMenuInherited({
    required this.menu,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('menu', menu, showName: false));
  }

  @override
  bool updateShouldNotify(_OrbMenuInherited old) => menu != old.menu;
}

class OrbMenu extends StatelessWidget {
  final List<List<dynamic>> menuStack;
  final OrbConnection connection;
  final bool headerIsTransparent;

  const OrbMenu({
    required this.menuStack,
    required this.connection,
    required this.headerIsTransparent,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildMenu(context, menuStack.last);
  }

  Widget buildMenu(BuildContext context, List<dynamic> menu) {
    final groups = menu
        .cast<Map<dynamic, dynamic>>()
        .splitAt((item) => item['divider'] == true)
        .toList();
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(
              top: (headerIsTransparent
                      ? MediaQuery.of(context).padding.top
                      : 0) +
                  OrbTheme.of(context).lengths.large,
              right: OrbTheme.of(context).lengths.mediumSmall,
              bottom: OrbTheme.of(context).lengths.large,
              left: OrbTheme.of(context).lengths.mediumSmall,
            ),
            itemCount: groups.length,
            itemBuilder: (context, index) => SeparatedColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buildGroup(context, groups[index]),
              separatorBuilder: (_context, _index) =>
                  SizedBox(height: OrbTheme.of(context).lengths.tiny),
            ),
            separatorBuilder: (_context, _index) => Container(
              margin: EdgeInsets.symmetric(
                horizontal: OrbTheme.of(context).lengths.mediumSmall,
                vertical: OrbTheme.of(context).lengths.small,
              ),
              child: Divider(
                color: OrbTheme.of(context).palette.brand,
                thickness: 1,
                height: 1,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: OrbTheme.of(context).palette.brandNeutral,
                width: 1,
              ),
            ),
            color: Colors.white,
          ),
          padding: EdgeInsets.all(
            OrbTheme.of(context).lengths.large,
          ),
          child: OrbButton(
            text: menuStack.length == 1
                ? OrbConfig.of(context).menu.closeText
                : OrbConfig.of(context).menu.backText,
            iconSpec: menuStack.length == 1 ? OrbIcons.close : OrbIcons.left,
            onTap: () => OrbMenuState.of(context).popMenu(),
            disabled: false,
            selected: false,
            isAction: true,
            isLink: false,
            isMenu: false,
            mode: OrbWidgetMode.standalone,
          ),
        ),
      ],
    );
  }

  List<Widget> buildGroup(
    BuildContext context,
    List<Map<dynamic, dynamic>> menu,
  ) {
    return menu.map((item) {
      final buttonId = item['button_id'];
      final text = item['text'];
      final icon = item['icon'];
      final itemContext = item['context'];
      final String? url = item['url'];
      final menu = item['menu'];
      final disabled = item['disabled'] == true;
      return _OrbMenuItem(
        text: text,
        iconSpec: OrbIconSpec.fromMap(icon),
        onTap: () async {
          if (url != null) {
            await OrbUrl(url).tryLaunch(context);
            return;
          } else if (menu != null) {
            OrbMenuState.of(context).pushMenu(menu);
            return;
          } else if (buttonId != null) {
            connection.publishEvent(
              OrbEvent.createButtonClickEvent(
                buttonId,
                text: text,
                context: itemContext,
              ),
            );
            OrbMenuState.of(context).closeMenu();
          } else {
            connection.publishEvent(
              OrbEvent.createSayEvent(
                text,
                context: itemContext,
              ),
            );
            OrbMenuState.of(context).closeMenu();
          }
        },
        disabled: url != null ? false : disabled,
        isLink: url != null,
        isMenu: menu != null,
      );
    }).toList();
  }
}

class _OrbMenuItem extends StatelessWidget {
  final String? text;
  final OrbIconSpec? iconSpec;
  final void Function() onTap;
  final bool disabled;
  final bool isLink;
  final bool isMenu;

  const _OrbMenuItem({
    required this.text,
    required this.iconSpec,
    required this.onTap,
    required this.disabled,
    required this.isLink,
    required this.isMenu,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return buildItem(context);
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            onTap();
          },
          splashColor: Colors.transparent,
          highlightColor: OrbTheme.of(context).palette.brandShadow,
          child: buildItem(context),
        ),
      );
    }
  }

  Widget buildItem(BuildContext context) {
    final Color textColor;
    if (disabled) {
      textColor = OrbTheme.of(context).palette.disabled;
    } else {
      textColor = OrbTheme.of(context).palette.brand;
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      padding: EdgeInsets.all(
        OrbTheme.of(context).lengths.mediumSmall,
      ),
      child: SeparatedRow(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconSpec != null)
            OrbIcon(
              iconSpec!,
              size: OrbTheme.of(context).size.icon.medium,
              color: textColor,
            ),
          if (text != null)
            Text(
              text!,
              style: (OrbTheme.of(context).text.font.normal)
                  .merge(OrbTheme.of(context).text.style.bold)
                  .merge(OrbTheme.of(context).text.size.large)
                  .copyWith(color: textColor),
            ),
          const Expanded(child: SizedBox()),
          if (isLink)
            OrbIcon(
              OrbIcons.link,
              size: OrbTheme.of(context).size.icon.small,
              color: textColor,
            ),
          if (isMenu)
            OrbIcon(
              OrbIcons.right,
              size: OrbTheme.of(context).size.icon.small,
              color: textColor,
            ),
        ],
        separatorBuilder: (_context, _index) =>
            SizedBox(width: OrbTheme.of(context).lengths.mediumSmall),
      ),
    );
  }
}
