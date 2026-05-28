
## Сборка и запуск 

### Требования

-   [Flutter SDK](https://docs.flutter.dev/get-started/install) (версия 3.0 или выше)
-   Dart SDK (входит в состав Flutter)
-   IDE: [VS Code](https://code.visualstudio.com/) или [Android Studio](https://developer.android.com/studio)
-   Эмулятор (Android/iOS) или физическое устройство


---

### 1. Установка зависимостей

Установите все необходимые пакеты:


    flutter pub get

### 2. Генерация кода базы данных 

Проект использует Hive для хранения данных. Для работы моделей необходимо сгенерировать адаптеры (`*.g.dart` файлы).

Запустите команду build_runner:


    dart run build_runner build --delete-conflicting-outputs

_Если вы используете старую версию Flutter/Dart, команда может быть: `flutter pub run build_runner build --delete-conflicting-outputs`_

После успешного выполнения в папке `lib/models/` должны появиться файлы формата `.g.dart`.

### 3.1 Запуск приложения

Подключите устройство или запустите эмулятор, затем выполните:

    flutter run


### 3.2 Сборка релизной версии

Перейдите в папку с Java и создайте ключ:

    keytool -genkey -v -keystore %userprofile%\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

**Важно:** У вас должна быть установлена Java и библиотека `keytool` (идёт в комплекте с Java).

Придумайте сложный пароль и не потеряйте сгенерированный файл

Измените файл `android/key.properties` следующим образом:

    storePassword=<Ваш пароль store password>
    keyPassword=<Ваш пароль от ключа>
    keyAlias=upload
    storeFile=<Полный путь до директории где лежит сгенерированный ключ>

Соберите приложение:

    flutter build apk --release

Файл APK будет находиться по пути: `build/app/outputs/flutter-apk/app-release.apk`
