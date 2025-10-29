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
### 生成虚拟用户数据

```dart
dart scripts/
```
### 配置API Key（选择其中一种方式

1. 方式1：环境变量（推荐
```bash
# 设置环境变量
export GEMINI_API_KEY="你的API_KEY"
```
2. 或者创建 .env 文件（在 backend/functions/ 目录下）
```bash
echo "GEMINI_API_KEY=你的API_KEY" > backend/functions/.env
```

## 🔧 开发模式

应用支持两种服务模式：

- **🎭 Fake Service**: 快速开发模式，使用本地模拟数据
- **🔥 Firebase Service**: 生产模式，使用真实的AI匹配

### 切换服务模式

在应用中点击右上角的开发者模式图标，可以实时切换服务模式，无需重启应用。

### 应用启动时启用LLM 加入APIKEY

在应用启动时自动启用LLM调试模式：

```bash
# 设置API密钥和启用标志
export GEMINI_API_KEY="你的Gemini_API密钥"
flutter run --dart-define=ENABLE_DEBUG_LLM=true --dart-define=GEMINI_API_KEY=YOUR_API_KEY
```

### 测试LLM功能

运行开发模式LLM测试脚本：

```bash
# 设置API密钥
export GEMINI_API_KEY="你的Gemini_API密钥"
cd backend/functions/
pip install -r requirements.txt
python test-llm.py
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