# flutter_bluetooth_serial


Реализация классического Bluetooth для Flutter (пока только RFCOMM).

## Возможности

Библиотека предоставляет следующие функции:

+ Мониторинг состояния адаптера Bluetooth,

+ Включение/выключение Bluetooth,

+ Открытие настроек Bluetooth,

+ Поиск устройств и запрос режима обнаружения,

+ Просмотр сопряженных устройств и создание новых соединений,

+ Подключение к нескольким устройствам одновременно,

+ Отправка и получение данных (множественные соединения).

Библиотека использует Serial Port Profile для передачи данных по RFCOMM, поэтому убедитесь, что на устройстве запущен Service Discovery Protocol, который указывает на канал SP/RFCOMM. Может быть установлено до [7 Bluetooth соединений](https://stackoverflow.com/a/32149519/4880243).

На данный момент поддерживается только Android.

## Тестирование

Библиотека протестирована на следующих версиях:

+ Flutter: 3.35.2
+ Dart: 3.9.0
+ Android: API level 21 (Android 5.0)
+ Android 12+ (API level 31) с обновленными разрешениями

## Начало работы

### Зависимости

Подключения через Git:
```yaml
dependencies:
    flutter_bluetooth_serial:
        git:
            url: https://github.com/Develeps/flutter_bluetooth_serial.git
            ref: main
```

### Установка

```bash
# С помощью pub
pub get
# или с Flutter
flutter pub get
```

### Импорт
```dart
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
```

### Использование

Ознакомьтесь с Dart кодом библиотеки (в основном документированные функции) или с примерами использования.
```dart
// Простое соединение
try {
    BluetoothConnection connection = await BluetoothConnection.toAddress(address);
    print('Подключено к устройству');

    connection.input.listen((Uint8List data) {
        print('Получены данные: ${ascii.decode(data)}');
        connection.output.add(data); // Отправка данных

        if (ascii.decode(data).contains('!')) {
            connection.finish(); // Закрытие соединения
            print('Отключение по запросу локального хоста');
        }
    }).onDone(() {
        print('Отключение по запросу удаленного устройства');
    });
}
catch (exception) {
    print('Невозможно подключиться, произошла ошибка: $exception');
}
```


## Разрешения Android

Начиная с Android 12 (API level 31), библиотека требует дополнительных разрешений в `AndroidManifest.xml` вашего приложения:

```xml
<!-- Разрешения Bluetooth для всех версий Android -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission
    android:name="android.permission.BLUETOOTH_SCAN"
```

### [0.4.1] - 2025-08-29


#### Улучшения
* Обновлена конфигурация Android для поддержки Android 12+ (API level 31+)
* Обновлена версия Gradle до 8.9.1
* Обновлена версия compile SDK до 34
* Обновлена совместимость Java до VERSION_11
* Добавлены разрешения Bluetooth для Android 12+ в AndroidManifest.xml
* Обновлен pubspec.yaml для поддержки Flutter 3.0+ и Dart 3.0+
* Исправлена опечатка в документации BluetoothConnection.dart
* Добавлен подробный README.md с примерами использования
* Добавлено пример приложения, демонстрирующий использование библиотеки
* Обновлена документация с информацией о тестировании
* Удалены ссылки на предыдущих авторов