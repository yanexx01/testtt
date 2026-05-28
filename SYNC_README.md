# Синхронизация с внешней базой данных

Этот проект теперь поддерживает синхронизацию записей и активностей с внешней базой данных через REST API.

## Архитектура

### 1. **ApiService** (`lib/services/api_service.dart`)
Сервис для работы с HTTP-запросами к внешнему API. Отвечает за:
- Получение записей с сервера
- Отправку новых записей на сервер
- Обновление существующих записей
- Удаление записей
- Синхронизацию списков активностей

### 2. **SyncProvider** (`lib/providers/sync_provider.dart`)
Провайдер для управления состоянием синхронизации:
- `syncEntries()` - синхронизация записей (двусторонняя)
- `syncActivities()` - синхронизация активностей
- `syncAll()` - полная синхронизация всего
- `uploadEntry()`, `updateEntry()`, `deleteEntry()` - отправка изменений на сервер

## Настройка

### 1. Добавьте зависимость в `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.2.0
```

### 2. Укажите URL вашего API в `main.dart`:
```dart
ChangeNotifierProvider(
  create: (_) => SyncProvider(baseUrl: 'https://your-api-url.com'),
),
```

### 3. Используйте синхронизацию в вашем коде:

```dart
// В любом виджете получите доступ к SyncProvider
final syncProvider = Provider.of<SyncProvider>(context, listen: false);

// Выполните синхронизацию
await syncProvider.syncAll();

// Или синхронизируйте только записи
await syncProvider.syncEntries();

// Проверьте статус синхронизации
if (syncProvider.isSyncing) {
  // Показываем индикатор загрузки
}

if (syncProvider.lastSyncError != null) {
  // Показываем ошибку
}

if (syncProvider.lastSyncTime != null) {
  // Показываем время последней синхронизации
}
```

## Требуемый формат API

Ваш внешний API должен поддерживать следующие эндпоинты:

### Записи (Entries)
- `GET /entries` - получить все записи
- `POST /entries` - создать новую запись
- `PUT /entries/{id}` - обновить запись
- `DELETE /entries/{id}` - удалить запись

### Активности (Activities)
- `GET /activities` - получить список активностей
- `POST /activities` - сохранить список активностей

### Формат записи (JSON):
```json
{
  "id": "unique-id",
  "date": "2024-01-15T10:30:00.000Z",
  "moodIndex": 0,
  "activities": ["Работа", "Спорт"],
  "note": "Текст заметки"
}
```

### Формат активностей (JSON):
```json
["Работа", "Спорт", "Дом", "Друзья", "Хобби"]
```

## Стратегия синхронизации

При синхронизации записей используется следующая логика:
1. Записи скачиваются с сервера
2. Если запись есть только на сервере - она добавляется локально
3. Если запись есть и локально, и на сервере - оставляется более новая (по дате)
4. Все локальные записи отправляются на сервер

## Пример использования в UI

```dart
ElevatedButton.icon(
  icon: syncProvider.isSyncing 
    ? CircularProgressIndicator(strokeWidth: 2)
    : Icon(Icons.sync),
  label: Text(syncProvider.isSyncing 
    ? 'Синхронизация...' 
    : 'Синхронизировать'),
  onPressed: syncProvider.isSyncing 
    ? null 
    : () async {
        try {
          await syncProvider.syncAll();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Синхронизация успешна')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка синхронизации: $e')),
          );
        }
      },
)
```

## Примечания

- Замените `'https://your-api-url.com'` на реальный URL вашего API
- Убедитесь, что ваш API поддерживает CORS для мобильных запросов
- Рекомендуется добавить обработку ошибок сети и повторные попытки
- Для продакшена добавьте аутентификацию и токены доступа
