# Furwall Plus

Furwall Plus 是一个跨平台应用，使用 Flutter 和 WebView 技术，提供流畅的网页浏览体验。

## 项目信息

- **应用名称**：Furwall Plus
- **包名/应用ID**：`top.lmxhl.furwallplus`
- **源站地址**：`https://my.furwall.net`
- **目标平台**：Windows、Linux、Android、iOS、macOS、HarmonyOS
- **核心架构**：直接使用 WebView 渲染，仅做性能和网络优化

## 技术栈

- Flutter (稳定版)
- flutter_inappwebview (WebView 核心)
- device_info_plus (获取设备信息)

## 功能特点

- **动态 User-Agent 生成**：根据设备实际信息生成真实浏览器 UA
- **WebView 全屏显示**：优化显示效果，提供沉浸式体验
- **网络错误处理**：支持 SSL 证书错误处理和混合内容模式
- **移动端优化**：注入 JavaScript 移除 APP 下载引导弹窗
- **性能优化**：硬件加速、刷新率优化、WebView 复用

## 构建说明

### 构建命令

```bash
# Windows
flutter build windows

# Android
flutter build apk --release --split-per-abi

# iOS
flutter build ios --release --no-codesign

# macOS
flutter build macos

# Linux
flutter build linux
```

### CI/CD

使用 GitHub Actions 自动构建所有平台产物，触发条件：
- push 到 main 分支
- push 标签 `v*`

## 权限说明（Android）

- 网络权限：INTERNET, ACCESS_NETWORK_STATE, ACCESS_WIFI_STATE
- 摄像头权限：CAMERA
- 文件管理权限：READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE, MANAGE_EXTERNAL_STORAGE
- 麦克风权限：RECORD_AUDIO
- 其他权限：FOREGROUND_SERVICE

## 开发规范

1. **无注释**：只保留 `// TODO` 或 `// FIXME`
2. **短函数**：每个函数不超过 30 行
3. **早返回**：`if (error) return;`
4. **错误处理**：try-catch，失败时显示错误页面

## 禁止事项

- ❌ 不要使用固定 UA 字符串
- ❌ 不要跳过 SSL 校验而不询问用户
- ❌ 不要本地编译
- ❌ 不要写冗余注释
