// Copyright 2026 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file or at https://developers.google.com/open-source/licenses/bsd.

import 'package:devtools_app/devtools_app.dart';
import 'package:devtools_app_shared/ui.dart';
import 'package:devtools_app_shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The opening of the 2.60.0 release notes. See
  // https://docs.flutter.dev/tools/devtools/release-notes/release-notes-2.60.0.md
  const markdownData = '''
# DevTools 2.60.0 release notes

> Release notes for Dart and Flutter DevTools version 2.60.0.
''';

  setUp(() {
    setGlobal(IdeTheme, IdeTheme());
  });

  /// Pumps a visible [SidePanel] rendering [markdownData] and returns the
  /// decoration the markdown renderer used for the blockquote.
  Future<BoxDecoration> pumpAndFindBlockquoteDecoration(
    WidgetTester tester, {
    required bool useDarkTheme,
  }) async {
    final controller = SidePanelController()
      ..markdown.value = markdownData
      ..toggleVisibility(true);

    await tester.pumpWidget(
      MaterialApp(
        theme: themeFor(
          isDarkTheme: useDarkTheme,
          ideTheme: IdeTheme(),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: useDarkTheme ? darkColorScheme : lightColorScheme,
          ),
        ),
        home: SidePanelViewer(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // The blockquote is the only decorated box the markdown renderer builds
    // for this document.
    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(Markdown),
        matching: find.byType(DecoratedBox),
      ),
    );
    return decoratedBox.decoration as BoxDecoration;
  }

  ColorScheme colorSchemeOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Markdown))).colorScheme;

  group('$SidePanel', () {
    testWidgets('gives the blockquote a themed background in dark theme', (
      tester,
    ) async {
      final decoration = await pumpAndFindBlockquoteDecoration(
        tester,
        useDarkTheme: true,
      );

      expect(decoration.color, colorSchemeOf(tester).secondaryContainer);
    });

    testWidgets('gives the blockquote a themed background in light theme', (
      tester,
    ) async {
      final decoration = await pumpAndFindBlockquoteDecoration(
        tester,
        useDarkTheme: false,
      );

      expect(decoration.color, colorSchemeOf(tester).secondaryContainer);
    });
  });
}
