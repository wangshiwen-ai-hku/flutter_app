# 数据模型架构

## 概述

为了避免在修改数据模型时需要同时维护多个地方的代码，我们采用了分层架构：

- `BaseUserData`: 基础用户数据模型，只包含纯Dart兼容的字段
- `UserData`: Flutter应用专用模型，继承`BaseUserData`并添加Flutter特有的字段

## 如何添加新字段

### 场景1: 添加纯Dart兼容的字段（推荐）

如果要添加的字段不依赖Flutter特有的类型（如`Uint8List`, `Widget`等），请：

1. **只修改 `BaseUserData`**:
   ```dart
   class BaseUserData {
     // 添加新字段
     final String newField;

     BaseUserData({
       // ...
       this.newField = 'default_value',
     });

     // 更新 fromJson 和 toJson 方法
   }
   ```

2. **脚本会自动继承新字段**，无需修改脚本代码

### 场景2: 添加Flutter特有的字段

如果要添加的字段依赖Flutter特有类型，请：

1. **在 `UserData` 中添加字段**:
   ```dart
   class UserData extends BaseUserData {
     final SomeFlutterType flutterField;

     UserData({
       // ...
       this.flutterField,
     });
   }
   ```

2. **更新 `toJson` 方法**:
   ```dart
   @override
   Map<String, dynamic> toJson() => {
     ...super.toJson(),
     "flutterField": flutterField,
   };
   ```

## 文件结构

```
lib/models/
├── base_user_data.dart    # 基础数据模型（纯Dart）
├── user_data.dart         # Flutter应用模型（继承基础模型）
└── README.md             # 本文档
```

## 优势

- ✅ **单一修改点**: 大多数字段修改只需改一个文件
- ✅ **类型安全**: 保持Flutter和脚本的类型一致性
- ✅ **向后兼容**: 脚本生成的旧数据仍能被新模型读取
- ✅ **可维护性**: 清晰的职责分离

## 使用示例

```dart
// Flutter应用中使用完整模型
UserData user = UserData(
  uid: '123',
  username: 'John',
  traits: ['creative', 'outgoing'],
  portrait: imageBytes, // Uint8List - Flutter特有
  userPosts: [post1, post2], // List<Post> - Flutter特有
);

// 脚本中使用基础模型
models.BaseUserData baseUser = models.BaseUserData(
  uid: '123',
  username: 'John',
  traits: ['creative', 'outgoing'],
  // 没有portrait和userPosts字段，因为脚本无法处理这些类型
);
```

## 生成的JSON文件格式

脚本生成的 `assets/data/fake_users.json` 文件使用带缩进的格式，便于阅读和调试：

```json
[
  {
    "uid": "user_0",
    "username": "User 0",
    "traits": [
      "listener",
      "mood board"
    ],
    "freeText": "Every person is a story waiting to be written.",
    "followedBloggerIds": [],
    "favoritedPostIds": [],
    "favoritedConversationIds": []
  }
]
```
