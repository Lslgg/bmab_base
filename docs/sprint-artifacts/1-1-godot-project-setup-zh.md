# 故事 1.1: godot项目搭建

状态: 准备开发

## 故事描述

作为一名**游戏开发者**，
我希望**搭建基础的Godot 4.x项目结构和核心架构组件**，
以便**我能够开始实现节奏象棋游戏，具备合适的组织结构、音频功能和开发基础设施**。

## 验收标准

1. **项目初始化**: 创建新的Godot 4.x项目，配置Forward+渲染器和合适的音频配置
2. **架构实现**: 实现架构文档中定义的分层项目结构
3. **核心接口**: 创建时序、音频和游戏系统的抽象接口
4. **事件系统**: 实现EventBus单例用于组件通信
5. **音频基础**: 设置AudioServer配置和基础频谱分析器
6. **测试基础设施**: 创建基础测试框架和示例测试
7. **文档**: 添加README和开发设置说明

## 任务 / 子任务

- [ ] **项目创建和配置** (验收标准: 1)
  - [ ] 创建新的Godot 4.x项目，配置Forward+渲染器
  - [ ] 配置AudioServer设置 (buffer_size=512, sample_rate=44100Hz)
  - [ ] 设置节奏游戏需求的项目设置
  - [ ] 配置基础控制的输入映射

- [ ] **核心架构实现** (验收标准: 2)
  - [ ] 创建分层文件夹结构 (timing_core/, game_core/, rendering/, user_experience/)
  - [ ] 实现自动加载单例 (EventBus, GameManager, AudioManager, SettingsManager)
  - [ ] 设置场景文件夹结构，包含main、game和menu层次
  - [ ] 创建资源文件夹组织结构

- [ ] **接口和通信系统** (验收标准: 3, 4)
  - [ ] 创建时序接口 (i_timing_source.gd, i_beat_predictor.gd)
  - [ ] 实现EventBus和标准事件模式
  - [ ] 创建数据模型类 (BeatEvent, BoardState, AudioData, ErrorEvent)
  - [ ] 设置基于信号的错误处理系统

- [ ] **音频系统基础** (验收标准: 5)
  - [ ] 配置AudioEffectSpectrumAnalyzer和合适的FFT设置
  - [ ] 创建基础音频后端接口结构
  - [ ] 实现延迟检测和补偿框架
  - [ ] 设置音频资源管理系统

- [ ] **测试和质量基础设施** (验收标准: 6)
  - [ ] 创建测试文件夹结构和测试运行器
  - [ ] 实现基础单元测试示例
  - [ ] 设置性能监控框架
  - [ ] 创建音频测试工具和模拟系统

- [ ] **文档和设置** (验收标准: 7)
  - [ ] 编写包含设置说明的综合README
  - [ ] 记录架构决策和文件夹结构
  - [ ] 创建开发工作流程指南
  - [ ] 添加代码风格和命名约定文档

## 开发说明

### 关键架构需求

**🔥 强制技术栈:**
- **游戏引擎**: Godot 4.x (最新稳定版) - 无例外
- **渲染器**: Forward+ (3D效果和音频可视化必需)
- **音频配置**: 512采样缓冲区, 44.1kHz采样率
- **编程语言**: GDScript为主, C#可选用于性能关键部分

**🏗️ 项目结构 (必须精确实现):**
```
rhythm_chess/
├── project.godot
├── autoload/                  # 全局单例
│   ├── event_bus.gd          # EventBus通信系统
│   ├── game_manager.gd       # 核心游戏状态管理
│   ├── audio_manager.gd      # 音频系统协调
│   └── settings_manager.gd   # 配置管理
├── scripts/
│   ├── timing_core/          # 时间同步层
│   │   ├── interfaces/
│   │   │   ├── i_timing_source.gd
│   │   │   └── i_beat_predictor.gd
│   │   └── latency_normalizer.gd
│   ├── game_core/           # 游戏逻辑层
│   │   ├── chess_engine/
│   │   └── rhythm_system/
│   ├── rendering/           # 3D渲染层
│   └── user_experience/     # UI和可访问性
├── scenes/
│   ├── main/
│   ├── game/
│   └── menus/
├── assets/
│   ├── audio/
│   ├── models/
│   └── textures/
└── testing/                 # 测试基础设施
```

**⚡ 音频系统关键需求:**
- AudioServer buffer_size 必须为512采样 (延迟与稳定性的平衡)
- 采样率必须为44100Hz (节奏游戏标准)
- AudioEffectSpectrumAnalyzer FFT_SIZE_1024 (延迟与稳定性的折衷)
- 从项目开始就实现延迟补偿系统

### 最新技术信息 (2024)

**Godot 4.x 音频功能:**
- **AudioEffectSpectrumAnalyzer**: 支持256-4096采样的FFT大小
- **实时分析**: 支持最多2.0秒的buffer_length以保证稳定性
- **延迟函数**: `AudioServer.get_time_to_next_mix()` 和 `AudioServer.get_output_latency()`
- **精确时序**: `AudioServer.get_time_since_last_mix()` 用于块补偿
- **硬件时钟同步**: `AudioStreamPlayer.get_playback_position()` 用于长时间同步

**关键实现注意事项:**
- 短会话(<5分钟)使用系统时钟同步
- 长会话使用硬件时钟同步
- 在时序计算中始终补偿输出延迟
- 为多线程音频精度实现抖动过滤

### 架构合规需求

**🚨 强制模式:**
- **命名约定**: PascalCase类名, snake_case文件/变量, SCREAMING_SNAKE_CASE常量
- **通信**: 所有组件间通信通过EventBus信号
- **数据模型**: 所有结构化数据使用自定义RefCounted类
- **错误处理**: 通过EventBus统一错误事件
- **文件组织**: 功能优先架构，层次分离清晰

**事件系统实现:**
```gdscript
# 标准事件发射模式
EventBus.emit_signal("beat_detected", beat_event)

# 标准事件连接模式
func _ready():
    EventBus.beat_detected.connect(_on_beat_detected)
```

**数据模型模式:**
```gdscript
class_name BeatEvent
extends RefCounted

var timestamp: float
var confidence: float
var bpm: int
var beat_index: int
```

### 文件结构需求

**核心自动加载设置 (关键):**
1. **EventBus** - 全局通信中心
2. **GameManager** - 核心游戏状态和生命周期
3. **AudioManager** - 音频系统协调和延迟管理
4. **SettingsManager** - 配置和用户偏好

**接口实现优先级:**
1. `i_timing_source.gd` - 抽象时序接口
2. `i_beat_predictor.gd` - 节拍预测接口
3. 数据模型: BeatEvent, AudioData, ErrorEvent
4. 基础延迟标准化器实现

### 测试需求

**强制测试基础设施:**
- 与GDScript集成的测试运行器
- 可重现测试的音频模拟系统
- 性能监控钩子
- 延迟测量工具

**测试覆盖需求:**
- EventBus信号传播
- 音频系统初始化
- 延迟补偿准确性
- 项目结构验证

### 项目上下文参考

**源文档:**
- [架构: docs/architecture.md - 完整分层架构规范]
- [PRD: docs/prd.md - 音频延迟需求 <20ms, 60 FPS性能]
- [GDD: docs/GDD.md - Godot 4.x技术约束和音频规范]

**PRD关键需求:**
- 稳定60 FPS性能需求
- 音频延迟 <20ms (采用50ms标准化策略)
- 支持80-120 BPM音乐范围
- 跨平台兼容性 (Windows/Mac/Linux)

**架构决策:**
- 延迟标准化策略 (50ms目标) 而非延迟最小化
- 预测时间线架构而非反应式处理
- 用户协作校准过程
- 渐进实现: Godot原生 → 自定义优化 → GDExtension

## 开发代理记录

### 上下文参考

**主要架构源**: `.bmad/bmm/workflows/4-implementation/create-story/workflow.yaml`
**故事上下文引擎**: 终极BMad方法综合分析已完成

### 使用的代理模型

Claude Sonnet 4 (Augment Agent) - 2025-12-16

### 调试日志参考

- 冲刺状态已更新: epic-1状态从"backlog"改为"in-progress"
- 故事1-1-godot-project-setup被识别为第一个待办故事
- 架构分析完成，采用革命性延迟标准化方法
- 最新Godot 4.x音频功能已研究并集成

### 完成说明列表

**✅ 终极上下文引擎分析已完成:**
- 综合PRD分析 (281行) - 音频需求和性能目标
- 完整架构分析 (1121行) - 革命性时序架构方法
- 完整GDD分析 (747行) - Godot 4.x技术规范
- 最新网络研究 - Godot 4.x AudioEffectSpectrumAnalyzer和时序函数
- 交叉引用所有技术需求与当前Godot功能

**🎯 开发者护栏已建立:**
- 强制技术栈明确定义
- 精确项目结构规范及理由
- 关键音频配置参数已记录
- 最新API信息已集成 (AudioServer时序函数)
- 架构合规模式已强制执行

**🔬 详尽分析已执行:**
- 无先前故事上下文 (这是epic中的第一个故事)
- 无git历史可用 (新项目)
- 革命性架构方法: 延迟标准化 vs 最小化
- 预测时间线架构 vs 反应式处理
- 用户协作校准系统设计

### 文件列表

**此故事中要创建的文件:**
- `project.godot` - 主Godot项目配置
- `autoload/event_bus.gd` - 全局通信系统
- `autoload/game_manager.gd` - 核心游戏管理
- `autoload/audio_manager.gd` - 音频系统协调
- `autoload/settings_manager.gd` - 配置管理
- `scripts/timing_core/interfaces/i_timing_source.gd` - 时序接口
- `scripts/timing_core/interfaces/i_beat_predictor.gd` - 节拍预测接口
- `scripts/timing_core/latency_normalizer.gd` - 延迟标准化系统
- `scripts/data/models/beat_event.gd` - 节拍事件数据模型
- `scripts/data/models/audio_data.gd` - 音频数据模型
- `scripts/data/models/error_event.gd` - 错误事件数据模型
- `testing/test_runner.gd` - 基础测试框架
- `testing/audio_mocking/mock_audio_stream.gd` - 音频测试工具
- `README.md` - 项目文档和设置指南
- 基础场景结构和资源文件夹
