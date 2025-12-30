# FORME iOS App

深度研究浏览器应用，专注于长时间、长周期的研究项目。

## 项目结构

```
iOS/
├── FORME.xcodeproj/          # Xcode项目文件
├── FORME/                    # 源代码目录
│   ├── FORME/               # 主目标源代码
│   │   ├── Sources/         # 应用入口和核心类
│   │   ├── Models/          # 数据模型和Core Data
│   │   ├── Views/           # 视图控制器
│   │   ├── Services/        # 业务逻辑服务
│   │   ├── Utils/           # 工具类
│   │   └── Resources/       # 资源文件
│   └── FORMETests/          # 单元测试
├── Package.swift            # Swift Package Manager配置
└── project.yml             # xcodegen配置
```

## 技术栈

- **语言**: Swift 5.9+
- **UI框架**: UIKit
- **架构模式**: MVVM
- **约束库**: SnapKit
- **网络库**: Alamofire
- **图片加载**: Kingfisher
- **本地存储**: Core Data
- **AI集成**: DeepSeek API + 本地NLP分析
- **包管理**: Swift Package Manager (SPM)
- **项目生成**: xcodegen

## 核心功能

### 1. 研究管理
- 创建和管理研究课题
- 5步工作流支持 (Boost → Pick Target → Schedule → Work-Feedback-Loop → Output-Feedback-Loop)
- 研究进度追踪
- 标签分类系统

### 2. 资料管理
- 网页内容保存与解析
- 本地文档导入
- 智能标签系统
- 标注和笔记功能
- 资料关联研究

### 3. 智能分析
- **DeepSeek API集成**: 深度理解、智能问答、关联发现
- **本地NLP分析**: 文本摘要、关键词提取、情感分析
- **混合模式**: API失败自动降级到本地模型
- **用量控制**: Token限额和提醒

### 4. 个性化支持
- 阿德勒课题分类 (生活、工作、友情、爱情)
- 现实人生课题管理
- 投资课题追踪
- Agent智能辅助和动力支持

## 数据模型

### 核心实体
- **Research**: 研究课题，包含5步工作流
- **Material**: 研究资料，支持多种类型（网页、PDF、笔记等）
- **Insight**: 分析洞察，支持DeepSeek和本地分析
- **Tag**: 标签系统，支持分类和颜色
- **Annotation**: 资料标注
- **UserSettings**: 用户配置和DeepSeek API设置
- **UsageStatistics**: 使用统计

### 数据存储策略
- **本地优先**: 所有用户数据优先存储在设备本地
- **Core Data**: 使用Core Data进行本地数据管理
- **无服务端依赖**: 应用核心功能无需网络即可使用
- **可选同步**: 未来可添加iCloud或自定义服务端同步

## 开发环境设置

### 1. 安装依赖工具
```bash
# 安装Homebrew (如果尚未安装)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装xcodegen
brew install xcodegen

# 安装Swift Package Manager依赖
cd iOS
swift package resolve
```

### 2. 生成Xcode项目
```bash
cd iOS
xcodegen generate
```

### 3. 打开项目
```bash
open FORME.xcodeproj
```

### 4. 配置签名
1. 在Xcode中选择 `FORME` target
2. 在 `Signing & Capabilities` 中配置团队和Bundle ID
3. 选择运行设备或模拟器

## 项目配置

### DeepSeek API配置
1. 获取DeepSeek API Key
2. 在应用中进入"我的" → "DeepSeek API设置"
3. 输入API Key并测试连接
4. 配置用量限制和分析策略

### 开发配置
- **最低部署版本**: iOS 15.0
- **开发语言**: Swift
- **界面风格**: 纯代码 (No Storyboard)
- **架构**: MVVM + Coordinator模式

## 代码规范

### 命名约定
- 类名: `PascalCase`
- 变量和函数: `camelCase`
- 常量: `kPascalCase` 或 `camelCase`
- 文件组织: 按功能模块分组

### 架构模式
- **View**: `UIViewController` + `UIView`，使用SnapKit布局
- **ViewModel**: 业务逻辑和数据转换
- **Model**: Core Data实体和数据操作
- **Service**: 网络请求和业务服务
- **Coordinator**: 导航和流程控制（待实现）

## 测试

### 单元测试
```bash
# 运行测试
xcodebuild test -project FORME.xcodeproj -scheme FORME -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 测试覆盖
- 数据模型操作
- 服务层逻辑
- ViewModel业务逻辑
- 网络请求模拟

## 构建和部署

### 开发构建
```bash
xcodebuild build -project FORME.xcodeproj -scheme FORME -configuration Debug
```

### 发布构建
```bash
xcodebuild build -project FORME.xcodeproj -scheme FORME -configuration Release
```

### 归档
```bash
xcodebuild archive -project FORME.xcodeproj -scheme FORME -archivePath FORME.xcarchive
```

## 未来计划

### Phase 1 (已完成)
- [x] 项目架构搭建
- [x] 基础UI界面
- [x] Core Data数据模型
- [x] 本地分析功能

### Phase 2 (进行中)
- [ ] DeepSeek API完整集成
- [ ] 资料网页解析器
- [ ] 研究工作流实现
- [ ] 数据导出导入

### Phase 3 (计划中)
- [ ] iCloud同步
- [ ] 分享扩展 (Safari保存)
- [ ] 高级分析模型
- [ ] 离线模式优化

### Phase 4 (未来)
- [ ] iPad多任务支持
- [ ] macOS Catalyst版本
- [ ] 团队协作功能
- [ ] 插件系统

## 贡献指南

1. Fork项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开Pull Request

## 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系方式

项目问题请提交到GitHub Issues
功能建议请提交到GitHub Discussions