# Синхронизация с внешней БД и аутентификация

## Обзор

Этот проект теперь поддерживает полную синхронизацию записей дневника с внешним сервером через REST API, включая систему аутентификации пользователей.

## Компоненты системы

### 1. Модель пользователя (`lib/models/user.dart`)
```dart
class User {
  String id;
  String email;
  String name;
  String? avatarUrl;
}
```

### 2. AuthProvider (`lib/providers/auth_provider.dart`)
Управляет состоянием аутентификации:
- `register(email, password, name)` - регистрация нового пользователя
- `login(email, password)` - вход в аккаунт
- `logout()` - выход из аккаунта
- `updateProfile(name, email)` - обновление данных профиля
- `deleteAccount()` - удаление аккаунта
- `isAuthenticated` - статус авторизации
- `currentUser` - текущий пользователь

### 3. ApiService (`lib/services/api_service.dart`)
HTTP-клиент для работы с сервером:
- Аутентификация: `/auth/register`, `/auth/login`
- Профиль: `PUT /users/:id`, `DELETE /users/:id`
- Записи: `GET/POST/PUT/DELETE /entries`
- Активности: `GET/POST /activities`

Все запросы (кроме аутентификации) используют Bearer-токен для авторизации.

### 4. SyncProvider (`lib/providers/sync_provider.dart`)
Синхронизация данных:
- `syncAll()` - полная синхронизация записей и активностей
- `syncEntries()` - синхронизация только записей
- `syncActivities()` - синхронизация только активностей
- `isSyncing` - индикатор процесса синхронизации
- `lastSyncTime` - время последней успешной синхронизации
- `lastSyncError` - ошибка последней синхронизации

## Экраны

### Экран аутентификации (`/auth`)
- Переключение между входом и регистрацией
- Валидация email и пароля
- Отображение ошибок сервера

### Личный кабинет (`/profile`)
- Просмотр и редактирование профиля
- Кнопка синхронизации с отображением статуса
- История последних синхронизаций
- Выход из аккаунта
- Удаление аккаунта

### Раздел "Прочее" → "Личный кабинет"
Кнопка для перехода на экран аутентификации/профиля.

## Настройка

### 1. Укажите URL вашего API
В `lib/main.dart` замените:
```dart
final baseUrl = 'https://your-api-url.com';
```
на реальный адрес вашего сервера.

### 2. Генерация адаптеров Hive
Запустите:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Требования к серверу

Сервер должен поддерживать следующие эндпоинты:

#### Аутентификация
```
POST /auth/register
Body: { email, password, name }
Response: { token, user: { id, email, name, avatarUrl } }

POST /auth/login
Body: { email, password }
Response: { token, user: { id, email, name, avatarUrl } }
```

#### Профиль
```
PUT /users/:id
Headers: Authorization: Bearer <token>
Body: { name?, email? }
Response: { id, email, name, avatarUrl }

DELETE /users/:id
Headers: Authorization: Bearer <token>
```

#### Записи
```
GET /entries
Headers: Authorization: Bearer <token>
Response: [{ id, date, moodIndex, activities[], note }]

POST /entries
Headers: Authorization: Bearer <token>
Body: { id, date, moodIndex, activities[], note }

PUT /entries/:id
Headers: Authorization: Bearer <token>
Body: { id, date, moodIndex, activities[], note }

DELETE /entries/:id
Headers: Authorization: Bearer <token>
```

#### Активности
```
GET /activities
Headers: Authorization: Bearer <token>
Response: ["Работа", "Спорт", ...]

POST /activities
Headers: Authorization: Bearer <token>
Body: ["Работа", "Спорт", ...]
```

## Использование

### В коде приложения

```dart
// Получить провайдеры
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final syncProvider = Provider.of<SyncProvider>(context, listen: false);

// Войти
await authProvider.login('email@example.com', 'password');

// Синхронизировать данные
await syncProvider.syncAll();

// Проверить статус
if (syncProvider.isSyncing) {
  // Показываем индикатор загрузки
}

// Выйти
await authProvider.logout();
```

### В UI

Экран аутентификации доступен по маршруту `/auth`:
```dart
Navigator.pushNamed(context, '/auth');
```

Личный кабинет доступен по маршруту `/profile`:
```dart
Navigator.pushNamed(context, '/profile');
```

## Хранение данных

- Пользователи: Hive box `'users'`
- Записи: Hive box `'diary_entries'`
- Активности: Hive box `'activities'`

Данные сохраняются локально и синхронизируются с сервером при необходимости.

## Безопасность

- Токен аутентификации хранится в памяти (в AuthProvider)
- Все API-запросы (кроме логина/регистрации) требуют Bearer-токен
- Пароли не хранятся локально

## Примечания

- При первом входе все локальные записи будут отправлены на сервер
- При синхронизации происходит слияние данных с приоритетом более новых записей
- При выходе из аккаунта локальные данные сохраняются для следующего входа
