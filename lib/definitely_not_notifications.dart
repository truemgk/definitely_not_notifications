import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

enum ShortcutPolicy {
  /// Don't check, create, or modify a shortcut.
  ignore,

  /// Require a shortcut with matching AUMI, don't create or modify an existing one.
  requireNoCreate,

  /// Require a shortcut with matching AUMI, create if missing, modify if not matching.
  /// This is the default.
  requireCreate,
}

class NotificationAction {
  /// The label for the given action.
  String? text;

  NotificationAction({
    this.text,
  });

  factory NotificationAction.fromJson(Map<String, dynamic> json) =>
      NotificationAction(text: json['text']);

  Map<String, dynamic> toJson() => {'type': 'button', 'text': text ?? ''};
}

enum NotificationCloseReason {
  userCanceled,
  timedOut,
  unknown,
}

class Notification {
  late String identifier;

  /// Representing the title of the notification.
  String title;

  /// Representing the subtitle of the notification.
  String? subtitle;

  /// Representing the body of the notification.
  String? body;

  /// Represents the icon;
  String? icon;
  bool isCircle;

  /// Represents the hero;
  String? hero;
  bool isInline = false;

  /// Representing the actions of the notification.
  List<NotificationAction>? actions;

  ValueChanged<NotificationCloseReason>? onClose;
  VoidCallback? onClick;
  ValueChanged<int>? onClickAction;

  Notification({
    String? identifier,
    required this.title,
    this.subtitle,
    this.body,
    this.actions,
    this.icon,
    this.isCircle = false,
    this.hero,
    this.isInline = false
  }) {
    this.identifier = identifier ?? Uuid().v4();
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    List<NotificationAction>? actions;

    if (json['actions'] != null) {
      Iterable l = json['actions'] as List;
      actions = l.map((item) => NotificationAction.fromJson(item)).toList();
    }

    return Notification(
      identifier: json['identifier'],
      title: json['title'],
      subtitle: json['subtitle'],
      body: json['body'],
      icon: json['icon'],
      isCircle: json['isCircle'],
      hero: json['hero'],
      isInline: json['isInline'],
      actions: actions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'title': title,
      'subtitle': subtitle ?? '',
      'body': body ?? '',
      'icon': icon ?? '',
      'isCircle': isCircle.toString(),
      'hero': hero ?? '',
      'isInline': isInline.toString(),
      'actions': (actions ?? []).map((e) => e.toJson()).toList(),
    }..removeWhere((key, value) => value == null);
  }
}

void notify(Notification notification) {
  notifier.notify(notification);
}

class LocalNotifier {
  LocalNotifier._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  /// The shared instance of [LocalNotifier].
  static final LocalNotifier instance = LocalNotifier._();

  final MethodChannel _channel = const MethodChannel('local_notifier');

  bool _isInitialized = false;
  String? _appName;
  Map<String, Notification> _notifications = {};

  Future<void> _methodCallHandler(MethodCall call) async {
    String notificationId = call.arguments['notificationId'];
    Notification? notification = _notifications[notificationId];
    if (notification != null) {
      if (call.method == 'onNotificationClosed') {
        NotificationCloseReason closeReason = NotificationCloseReason.values
            .firstWhere((e) => describeEnum(e) == call.arguments['closeReason'],
                orElse: () => NotificationCloseReason.unknown);
        notification.onClose?.call(closeReason);
      } else if (call.method == 'onNotificationClicked') {
        notification.onClick?.call();
      } else if (call.method == 'onNotificationAction') {
        notification.onClickAction?.call(call.arguments['actionIndex']);
      }
    }
  }

  Future<void> setup({
    required String appName,
  }) async {
    final Map<String, dynamic> arguments = {
      'appName': appName,
      'shortcutPolicy': describeEnum(ShortcutPolicy.requireCreate),
    };
    if (Platform.isWindows) {
      _isInitialized = await _channel.invokeMethod('setup', arguments);
    } else {
      _isInitialized = true;
    }
    _appName = appName;
  }

  /// Immediately shows the notification to the user.
  Future<void> notify(Notification notification) async {
    if ((Platform.isLinux || Platform.isWindows) && !_isInitialized) {
      throw Exception(
        'Not initialized, please call `localNotifier.setup` first to initialize',
      );
    }
    _notifications[notification.identifier] = notification;

    final Map<String, dynamic> arguments = notification.toJson();
    arguments['appName'] = _appName;
    await _channel.invokeMethod('notify', arguments);
  }

  /// Closes the notification immediately.
  Future<void> close(Notification notification) async {
    final Map<String, dynamic> arguments = notification.toJson();
    await _channel.invokeMethod('close', arguments);
  }

  /// Destroys the notification immediately.
  Future<void> destroy(Notification notification) async {
    await close(notification);
    _notifications.remove(notification.identifier);
  }
}

final notifier = LocalNotifier.instance;
