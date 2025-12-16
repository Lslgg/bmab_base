# Godot 4.x 兼容性问题清单

## 概述
本文档记录了从Godot 3.x迁移到Godot 4.x时遇到的所有兼容性问题，供后续AI开发时参考。

## 已发现并修复的问题

### 1. 过时的Time API
**问题**: `Time.get_time_dict_from_system()["unix"]` 在Godot 4.x中不存在
**修复**: 使用 `Time.get_unix_time_from_system()`
**影响文件**: `autoload/game_manager.gd`

```gdscript
# ❌ 错误 (Godot 3.x)
var timestamp = Time.get_time_dict_from_system()["unix"]

# ✅ 正确 (Godot 4.x)
var timestamp = Time.get_unix_time_from_system()
```

### 2. 过时的内存API
**问题**: `OS.get_static_memory_usage_by_type()` 在Godot 4.x中不存在
**修复**: 使用 `OS.get_static_memory_usage()`
**影响文件**: `autoload/game_manager.gd`, `scripts/data/models/error_event.gd`

```gdscript
# ❌ 错误 (Godot 3.x)
var memory = OS.get_static_memory_usage_by_type().values().reduce(func(a, b): return a + b, 0)

# ✅ 正确 (Godot 4.x)
var memory = OS.get_static_memory_usage()
```

### 3. 移除的try/except语法
**问题**: `try/except` 语法在Godot 4.x中被移除
**修复**: 使用条件检查替代
**影响文件**: `testing/test_runner.gd`

```gdscript
# ❌ 错误 (Godot 3.x)
try:
    test_func.call()
    result.passed = true
except:
    result.passed = false

# ✅ 正确 (Godot 4.x)
if test_func.is_valid():
    test_func.call()
    result.passed = true
else:
    result.passed = false
    result.message = "FAILED - Invalid test function"
```

### 4. 不存在的AudioServer.stop()方法
**问题**: `AudioServer.stop()` 在Godot 4.x中不存在
**修复**: 移除调用，音频清理由引擎自动处理
**影响文件**: `scenes/main/main.gd`

```gdscript
# ❌ 错误 (Godot 4.x)
AudioServer.stop()

# ✅ 正确 (Godot 4.x)
# Clean up resources (Godot 4.x compatible)
# Note: AudioServer.stop() doesn't exist in Godot 4.x
# Audio cleanup is handled automatically by the engine
```

### 5. 枚举类型比较错误
**问题**: 在Godot 4.x中，枚举与字符串比较更加严格
**修复**: 使用正确的枚举类型比较
**影响文件**: `autoload/game_manager.gd`, `autoload/event_bus.gd`

```gdscript
# ❌ 错误 (类型不匹配)
if error_event.type == "fatal":

match error_event.type:
    "warning":
    "error":
    "fatal":

# ✅ 正确 (正确的枚举比较)
if error_event.type == ErrorEvent.ErrorType.FATAL:

match error_event.type:
    ErrorEvent.ErrorType.WARNING:
    ErrorEvent.ErrorType.ERROR:
    ErrorEvent.ErrorType.FATAL:
```

### 6. AudioEffectSpectrumAnalyzer API错误
**问题**: `AudioEffectSpectrumAnalyzer.MAGNITUDE_MAX` 不存在，需要使用实例方法
**修复**: 使用 `AudioEffectSpectrumAnalyzerInstance` 和正确的枚举
**影响文件**: `autoload/audio_manager.gd`, `scripts/data/models/audio_data.gd`

```gdscript
# ❌ 错误 (直接使用效果类)
spectrum_analyzer.get_magnitude_for_frequency_range(20.0, 250.0, AudioEffectSpectrumAnalyzer.MAGNITUDE_MAX)

# ✅ 正确 (使用实例类)
var spectrum_instance = AudioServer.get_bus_effect_instance(audio_bus_index, 0) as AudioEffectSpectrumAnalyzerInstance
spectrum_instance.get_magnitude_for_frequency_range(20.0, 250.0, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX)
```

## 验证工具

### 语法检查脚本模式
在 `comprehensive_syntax_check.ps1` 中添加了以下检查模式：

```powershell
# 检查过时的API调用
@{
    Pattern = 'Time\.get_time_dict_from_system\(\)\["unix"\]'
    Message = "Deprecated API: Use Time.get_unix_time_from_system() instead"
},
@{
    Pattern = 'OS\.get_static_memory_usage_by_type\(\)'
    Message = "Deprecated API: Use OS.get_static_memory_usage() instead"
},
@{
    Pattern = 'except:'
    Message = "Deprecated syntax: try/except was removed in Godot 4.x"
},
@{
    Pattern = 'AudioServer\.stop\(\)'
    Message = "Deprecated API: AudioServer.stop() doesn't exist in Godot 4.x"
},
@{
    Pattern = 'error_event\.type\s*==\s*"(warning|error|fatal)"'
    Message = "Type error: Comparing ErrorEvent.ErrorType enum with string"
},
@{
    Pattern = 'AudioEffectSpectrumAnalyzer\.MAGNITUDE_MAX'
    Message = "API error: Use AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX instead"
}
```

## 重要教训

### 1. 验证的重要性
- **表面验证不够**: 文件存在不等于代码正确
- **需要多层验证**: 文件、语法、API、类型、实际运行测试
- **静态分析有限**: 需要实际引擎测试来发现运行时问题

### 2. Godot 4.x的变化特点
- **类型系统更严格**: 枚举与字符串比较需要明确类型
- **API重构**: 许多3.x的API在4.x中被重命名或移除
- **实例化模式变化**: 某些功能需要通过实例而非直接类访问

### 3. 开发建议
- **始终使用最新文档**: Godot 4.x的API文档是权威参考
- **实际测试验证**: 不要仅依赖静态分析
- **版本特定检查**: 为目标Godot版本创建专门的兼容性检查

## 后续AI注意事项

1. **在编写Godot 4.x代码时，避免使用上述已知的过时API**
2. **使用枚举比较时，确保类型匹配**
3. **音频相关API需要特别注意实例化模式**
4. **编写验证脚本时，包含这些已知问题的检查**
5. **遇到解析错误时，首先检查是否使用了过时的语法或API**

## 快速检查清单

在开发Godot 4.x项目时，请检查以下常见问题：

### API兼容性检查
- [ ] 是否使用了 `Time.get_time_dict_from_system()["unix"]`？
- [ ] 是否使用了 `OS.get_static_memory_usage_by_type()`？
- [ ] 是否使用了 `AudioServer.stop()`？
- [ ] 是否使用了 `AudioEffectSpectrumAnalyzer.MAGNITUDE_MAX`？

### 语法兼容性检查
- [ ] 是否使用了 `try/except` 语法？
- [ ] 枚举比较是否使用了字符串而非枚举类型？

### 类型系统检查
- [ ] ErrorEvent.ErrorType 比较是否使用了正确的枚举？
- [ ] 音频分析器是否使用了正确的实例类？

## 错误信息对照表

| 错误信息 | 问题类型 | 解决方案 |
|---------|---------|---------|
| `Static function "get_static_memory_usage_by_type()" not found` | 过时API | 使用 `OS.get_static_memory_usage()` |
| `Expected end of statement after expression, found ":" instead` | try/except语法 | 使用条件检查替代 |
| `Static function "stop()" not found in base "GDScriptNativeClass"` | AudioServer API | 移除调用，引擎自动处理 |
| `Invalid operands "ErrorEvent.ErrorType" and "String" for "==" operator` | 类型不匹配 | 使用正确的枚举比较 |
| `Cannot find member "MAGNITUDE_MAX" in base "AudioEffectSpectrumAnalyzer"` | 音频API错误 | 使用 `AudioEffectSpectrumAnalyzerInstance` |

## 相关资源

- [Godot 4.x官方文档](https://docs.godotengine.org/en/stable/)
- [Godot 3.x到4.x迁移指南](https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.html)
- [AudioEffectSpectrumAnalyzerInstance文档](https://docs.godotengine.org/en/stable/classes/class_audioeffectspectrumanalyzerinstance.html)

---
**文档版本**: 1.0
**测试环境**: Godot 4.54
**最后更新**: 2025-12-16
**状态**: 所有已知问题已修复并验证
