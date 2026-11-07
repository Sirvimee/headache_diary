import 'dart:io';

import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  HomeWidgetService._();

  static const appGroupId = 'group.com.example.headacheDiary';
  static const widgetName = 'HeadacheDiaryWidgetProvider';
  static const iosWidgetName = 'HeadacheDiaryWidget';
  static const addSymptomUri = 'headacheDiary://addSymptom?homeWidget';

  static Future<void> initialize() async {
    if (Platform.isIOS) {
      await HomeWidget.setAppGroupId(appGroupId);
    }
  }

  static Future<void> update() async {
    await HomeWidget.updateWidget(name: widgetName, iOSName: iosWidgetName);
  }
}
