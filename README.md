# Psycho - AI-Powered Social Matching App

一个使用Flutter开发的AI驱动社交匹配应用，支持真实的LLM评估和智能匹配。

## 🚀 快速开始

### 前置要求
- Flutter SDK (3.9.2+)
- Node.js (18+)
- Firebase CLI
- Google AI Studio API Key

### 安装依赖
```bash
flutter pub get
cd backend/functions && npm install
```

### Firebase设置

1. **设置Firebase项目**
   ```bash
   firebase use studio-291983403-af613
   ```

2. **获取Gemini API Key**
   - 访问 [Google AI Studio](https://makersuite.google.com/app/apikey)
   - 创建新的API Key
   - 复制API Key

3. **配置API Key（选择其中一种方式）**

   **方式1：环境变量（推荐）**
   ```bash
   # 设置环境变量
   export GEMINI_API_KEY="你的API_KEY"

   # 或者创建 .env 文件（在 backend/functions/ 目录下）
   echo "GEMINI_API_KEY=你的API_KEY" > backend/functions/.env
   ```

   **方式2：Firebase配置**
   ```bash
   firebase functions:config:set gemini.key="你的API_KEY"
   ```

4. **部署Cloud Functions**
   ```bash
   # 如果使用环境变量
   firebase deploy --only functions

   # 或者指定环境变量（推荐用于CI/CD）
   firebase deploy --only functions --env-vars GEMINI_API_KEY=你的API_KEY
   ```

### 运行应用

```bash
flutter run -d chrome
```

## 🔧 开发模式

应用支持两种服务模式：

- **🎭 Fake Service**: 快速开发模式，使用本地模拟数据
- **🔥 Firebase Service**: 生产模式，使用真实的AI匹配

### 切换服务模式

在应用中点击右上角的开发者模式图标，可以实时切换服务模式，无需重启应用。

### 开发模式启用LLM

在开发模式下，你可以启用真实的LLM匹配分析：

1. **设置环境变量**
   ```bash
   export GEMINI_API_KEY="你的Gemini_API密钥"
   ```

2. **在代码中启用LLM**
   ```dart
   import 'package:flutter_app/services/service_locator.dart';

   // 启用LLM模式
   enableLLMInDebug();

   // 或者禁用LLM模式
   disableLLMInDebug();
   ```

3. **在Flutter运行时传递环境变量**
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=你的API密钥
   ```

LLM模式会调用真实的Gemini AI API，为匹配提供真实的AI分析，包括兼容性评分、诗意总结和对话话题建议。

### 应用启动时启用LLM

在应用启动时自动启用LLM调试模式：

```bash
# 设置API密钥和启用标志
export GEMINI_API_KEY="你的Gemini_API密钥"
flutter run --dart-define=ENABLE_DEBUG_LLM=true
```

或者在代码中直接启用（在main.dart中）：

```dart
// 在main()函数中添加
enableLLMInDebug();
```

### 运行时切换LLM模式

在应用运行时动态切换：

```dart
import 'package:flutter_app/services/service_locator.dart';

// 启用LLM模式
enableLLMInDebug();

// 禁用LLM模式
disableLLMInDebug();
```

### 测试LLM功能

运行开发模式LLM测试脚本：

```bash
# 设置API密钥
export GEMINI_API_KEY="你的Gemini_API密钥"

# 运行测试
dart scripts/test_debug_llm.dart
```

这个脚本会：
- ✅ 检查API密钥配置和格式
- 🌐 验证网络连接
- 🤖 启用LLM调试模式
- 🎯 执行匹配算法测试
- 📊 显示详细的匹配结果分析

### LLM调试信息

启用LLM后，你会在控制台看到详细的调试信息：

```
🔄 Calling LLM API for match: Alex ↔ Jordan
   API Key length: 39
   User A traits: [storyteller, night owl]
   User B traits: [listener, dreamer]
🌐 API URL: https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=...
📤 Request body length: 1250 characters
📥 Response status: 200
📥 Response headers: {...}
📥 Response body length: 456 characters
✅ API call successful, parsing response...
📋 Parsed JSON keys: [candidates]
👤 Candidate keys: [content, finishReason, index]
📝 Raw LLM response: {...}
🧹 Cleaned JSON text: {"summary": "...", "aiScore": 85, "conversationStarters": [...]}
🎯 Parsed response keys: [summary, aiScore, conversationStarters]
✅ LLM response validation passed
```

### 常见错误排查

**404错误**: 检查模型名称是否正确 (`gemini-2.5-flash`)
**401错误**: API密钥无效或过期
**429错误**: 请求频率过高，触发速率限制
**网络错误**: 检查互联网连接

## 🏗️ 架构

### 前端 (Flutter)
- `lib/services/fake_api_service.dart` - 开发模式服务
- `lib/services/firebase_api_service.dart` - 生产模式服务
- `lib/models/` - 数据模型
- `lib/pages/` - UI页面

### 后端 (Firebase)
- `backend/functions/src/index.ts` - Cloud Functions主入口
- `backend/functions/src/llm_service.ts` - Gemini AI集成
- `backend/functions/src/agents.ts` - AI提示和响应格式

## 🔑 API 密钥配置

**重要**: 不要将API密钥提交到版本控制系统！

Gemini API Key 支持两种配置方式：

### 方式1：环境变量（推荐）
```bash
# 设置环境变量
export GEMINI_API_KEY="你的密钥"

# 或者在部署时指定
firebase deploy --only functions --env-vars GEMINI_API_KEY=你的密钥
```

### 方式2：Firebase配置
```bash
firebase functions:config:set gemini.key="你的密钥"
```

### 测试LLM集成

在部署前，建议先测试你的Gemini API密钥是否正常工作：

#### 使用uv测试（最快 - 推荐）
```bash
# 安装uv（如果还没安装）
curl -LsSf https://astral.sh/uv/install.sh | sh

# 同步依赖（自动创建虚拟环境）
cd backend/functions && uv sync

# 设置API密钥
export GEMINI_API_KEY="你的密钥"

# 运行测试
uv run python test-llm.py
```

#### 使用pip测试（替代方案）
```bash
# 安装Python SDK
pip install -r backend/functions/requirements.txt
# 或者手动：pip install google-generativeai

# 设置API密钥
export GEMINI_API_KEY="你的密钥"

# 运行测试
cd backend/functions && python test-llm.py
```

#### 使用Node.js测试
```bash
# 安装依赖
cd backend/functions && npm install

# 设置API密钥
export GEMINI_API_KEY="你的密钥"

# 运行测试
npm run test-llm
```

环境变量方式更适合CI/CD和自动化部署。

## 📊 AI 匹配流程

Psycho 使用混合算法结合传统特征匹配和大型语言模型（LLM）进行智能匹配：

### 匹配算法详解

1. **特征预筛选** 🎯
   - 计算用户特征的 Jaccard 相似度系数
   - 分析自由文本中的关键词匹配（如"雨夜"、"书籍"等）
   - 选择相似度 > 0.05 的前10个候选人

2. **LLM并发深度分析** ⚡🤖
   - 使用 Google Gemini 2.5 Flash 模型
   - **并发调用**: 同时为所有候选人调用AI分析，大幅提升速度
   - 提供兼容性评分（0-100分）
   - 生成诗意匹配总结和对话话题建议
   - 显示有趣的等待消息和随机笑话 🎭

3. **最终评分计算** ⚖️
   ```
   最终得分 = 特征得分 × 0.3 + AI得分 × 0.7
   ```

### 等待体验

启用LLM时，你会看到有趣的等待提示和随机笑话：

```
⏳ 请稍等，我们正在为 10 位候选人进行AI深度分析...
🎭 为什么AI不会迷路？因为它总是有地图（map）！
💡 提示：这可能需要几秒到几十秒，取决于网络和AI响应速度
🤖 Starting concurrent LLM analysis for 10 candidates...
🔄 Analyzing match with Jordan...
🔄 Analyzing match with Sam...
🔄 Analyzing match with Casey...
✅ LLM analysis completed for Jordan: AI=0.85, Final=0.82
✅ LLM analysis completed for Sam: AI=0.78, Final=0.75
✅ LLM analysis completed for Casey: AI=0.92, Final=0.89
✅ All LLM analyses completed (10 matches)
```

### 随机笑话库 🎭

系统内置了多个有趣的等待笑话：
- "为什么程序员喜欢黑暗模式？因为光会引起bug！"
- "为什么AI不会迷路？因为它总是有地图（map）！"
- "AI正在思考：这个问题值得用一个神经网络吗？"
- "欢迎来到匹配马戏团！"

### 技术实现

- **前端**: Flutter + Firebase SDK
- **后端**: Firebase Cloud Functions (TypeScript)
- **AI服务**: Google Generative AI (Gemini)
- **数据存储**: Firestore
- **本地开发**: Fake API Service (模拟数据)

### API 接口

```typescript
// 获取匹配结果
Future<List<MatchAnalysis>> getMatches(String uid)

// MatchAnalysis 数据结构
{
  id: string,              // 匹配ID
  userA: UserData,         // 当前用户
  userB: UserData,         // 匹配用户
  aiScore: number,         // AI评分 (0.0-1.0)
  formulaScore: number,    // 公式评分 (0.0-1.0)
  finalScore: number,      // 最终评分 (0.0-1.0)
  summary: string,         // AI生成匹配总结
  conversationStarters: string[], // 对话话题建议
  traitCompatibility: Map<String, double> // 特征兼容性
}
```

## 🔍 调试

### 查看Cloud Functions日志
```bash
firebase functions:log --only getMatches
```

### 本地测试Functions
```bash
cd backend/functions
npm run serve
```

## 📱 功能特性

- ✅ 智能特征匹配
- ✅ AI驱动的兼容性分析
- ✅ 会话话题建议
- ✅ 实时服务切换
- ✅ 响应式设计
- ✅ Firebase集成

---

# flutter_app

A new Flutter project.

## Getting Started

1. 下载flutter sdk [https://docs.flutter.cn/get-started/]
2. 准备firebase [https://firebase.google.com/docs/flutter/setup?hl=zh-cn&platform=ios]
    - 安装firebase-cli [https://firebase.google.com/docs/cli?hl=zh-cn#install-cli-mac-linu]
    ```bash 
    firebase login
    dart pub global activate flutterfire_cli
    flutterfire configure
    ```

进入根目录
```bash
flutter pub get
flutter run
```
3. 后端服务
```bash 
cd backend/functions && npm install
firebase use studio-291983403-af613
```


