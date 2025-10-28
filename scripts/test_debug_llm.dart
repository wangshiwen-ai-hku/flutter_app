#!/usr/bin/env dart
/**
 * 开发模式LLM测试脚本
 * 用于测试开发模式下的LLM匹配功能
 *
 * 使用方法:
 *   1. 设置环境变量: export GEMINI_API_KEY="your_key"
 *   2. 运行: dart scripts/test_debug_llm.dart
 *   或者: GEMINI_API_KEY=your_key dart scripts/test_debug_llm.dart
 */

import 'dart:io';
import 'package:flutter_app/services/service_locator.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/models/match_analysis.dart';

void main() async {
  print('🧪 开发模式LLM匹配测试');
  print('=' * 50);

  // 检查环境变量
  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ 错误: 未找到 GEMINI_API_KEY 环境变量');
    print('请设置环境变量: export GEMINI_API_KEY="你的API密钥"');
    exit(1);
  }

  print('✅ 找到API密钥 (长度: ${apiKey.length})');

  // 检查API密钥格式
  if (!apiKey.startsWith('AIza')) {
    print('⚠️ 警告: API密钥格式可能不正确，通常以"AIza"开头');
  }

  // 检查网络连接
  print('\n🌐 检查网络连接...');
  try {
    final testResponse = await Process.run('ping', ['-c', '1', 'googleapis.com']);
    if (testResponse.exitCode == 0) {
      print('✅ 网络连接正常');
    } else {
      print('⚠️ 网络连接可能有问题');
    }
  } catch (e) {
    print('⚠️ 无法检查网络连接: $e');
  }

  // 启用LLM调试模式
  print('\n🤖 启用开发模式LLM...');
  enableLLMInDebug();

  // 初始化服务定位器
  print('🔧 初始化服务...');
  await setupLocator();

  // 获取API服务
  final apiService = locator<ApiService>();
  print('🎯 API服务已初始化');

  // 测试匹配功能
  print('\n🎯 开始并发LLM匹配测试...');
  print('⚡ 现在使用并发调用，所有候选人的AI分析会同时进行！');

  final stopwatch = Stopwatch()..start();

  try {
    final matches = await apiService.getMatches('current_user_id');

    stopwatch.stop();
    final duration = stopwatch.elapsed;

    print('✅ 匹配成功! 找到 ${matches.length} 个匹配');
    print('⏱️ 总耗时: ${duration.inSeconds}.${duration.inMilliseconds % 1000}s');

    if (matches.isNotEmpty) {
      final avgTimePerMatch = duration.inMilliseconds / matches.length;
      print('📊 平均每个匹配耗时: ${avgTimePerMatch.toStringAsFixed(1)}ms');
    }

    // 显示前3个匹配结果
    for (var i = 0; i < matches.length && i < 3; i++) {
      final match = matches[i];
      print('\n🏆 匹配 ${i + 1}: ${match.userB.username}');
      print('   🤖 AI评分: ${(match.aiScore * 100).toStringAsFixed(1)}%');
      print('   📊 公式评分: ${(match.formulaScore * 100).toStringAsFixed(1)}%');
      print('   🎯 最终评分: ${(match.finalScore * 100).toStringAsFixed(1)}%');
      print('   💬 总结: ${match.matchSummary.substring(0, 80)}...');
      print('   💭 对话话题: ${match.conversationStarters.take(2).join(", ")}');
    }

    print('\n🎉 并发LLM匹配测试完成!');
    print('🚀 并发调用让AI分析速度大幅提升！');
  } catch (e) {
    stopwatch.stop();
    print('❌ 匹配测试失败: $e');
    print('⏱️ 失败时耗时: ${stopwatch.elapsed.inSeconds}s');
    exit(1);
  }
}
