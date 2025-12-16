# Godot 4.x 快速兼容性参考

## 🚨 常见错误及修复

### 1. Time API
```gdscript
# ❌ Godot 3.x
Time.get_time_dict_from_system()["unix"]
# ✅ Godot 4.x  
Time.get_unix_time_from_system()
```

### 2. 内存API
```gdscript
# ❌ Godot 3.x
OS.get_static_memory_usage_by_type()
# ✅ Godot 4.x
OS.get_static_memory_usage()
```

### 3. 异常处理
```gdscript
# ❌ Godot 3.x
try:
    func.call()
except:
    handle_error()
    
# ✅ Godot 4.x
if func.is_valid():
    func.call()
else:
    handle_error()
```

### 4. 音频服务器
```gdscript
# ❌ Godot 4.x (不存在)
AudioServer.stop()

# ✅ Godot 4.x (自动处理)
# 音频清理由引擎自动处理，无需手动调用
```

### 5. 枚举比较
```gdscript
# ❌ 类型错误
if error_event.type == "fatal":

# ✅ 正确类型
if error_event.type == ErrorEvent.ErrorType.FATAL:
```

### 6. 音频频谱分析
```gdscript
# ❌ 错误的类
spectrum_analyzer.get_magnitude_for_frequency_range(20.0, 250.0, AudioEffectSpectrumAnalyzer.MAGNITUDE_MAX)

# ✅ 正确的实例类
var instance = AudioServer.get_bus_effect_instance(bus_index, 0) as AudioEffectSpectrumAnalyzerInstance
instance.get_magnitude_for_frequency_range(20.0, 250.0, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX)
```

## 🔍 错误信息速查

| 看到这个错误 | 问题是 | 解决方案 |
|------------|-------|---------|
| `get_static_memory_usage_by_type() not found` | 过时API | 用 `get_static_memory_usage()` |
| `Expected end of statement...found ":"` | try/except | 用 if/else 替代 |
| `stop() not found in AudioServer` | 不存在的方法 | 删除调用 |
| `Invalid operands ErrorEvent.ErrorType and String` | 类型不匹配 | 用枚举比较 |
| `MAGNITUDE_MAX not found in AudioEffectSpectrumAnalyzer` | 错误的类 | 用实例类 |

## ⚡ 开发检查清单

开始Godot 4.x开发前，确保：
- [ ] 不使用 `try/except` 语法
- [ ] 时间API使用 `Time.get_unix_time_from_system()`
- [ ] 内存API使用 `OS.get_static_memory_usage()`
- [ ] 枚举比较使用正确类型，不用字符串
- [ ] 音频API使用实例类而非效果类
- [ ] 不调用 `AudioServer.stop()`

## 📝 验证脚本模式

添加到你的检查脚本中：
```regex
Time\.get_time_dict_from_system\(\)\["unix"\]
OS\.get_static_memory_usage_by_type\(\)
except:
AudioServer\.stop\(\)
error_event\.type\s*==\s*"(warning|error|fatal)"
AudioEffectSpectrumAnalyzer\.MAGNITUDE_MAX
```

---
**快速参考** | **Godot 4.54兼容** | **2025-12-16**
