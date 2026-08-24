# ============================================================
# 交接文档 — AdultGame3D 项目 v2.0
# 生成时间: 2026-08-24
# 最后验证: godot3-server --path . --quit → 零脚本错误
# ============================================================

## 一、项目位置

手机存储路径: `/sdcard/Download/AdultGame3D/`

## 二、项目结构

```
/sdcard/Download/AdultGame3D/
├── project.godot              # Godot 3.5 项目配置文件
├── export_presets.cfg          # Android 导出配置 (arm64-v8a)
├── scenes/
│   └── Main.tscn               # 入口场景 (挂 Main.gd)
├── scripts/
│   ├── Character.gd            # 角色骨骼系统 v2.0 (17骨骼 + 外部模型加载)
│   ├── Main.gd                 # 主场景控制器 v2.0 (场景+IK+姿势+动作+UI)
│   ├── MotionEngine.gd         # 参数化动作引擎 v2.0 (多频波形+延迟传播)
│   ├── PoseSystem.gd           # 姿势系统 (8种体位定义) [新增]
│   ├── IK.gd                   # Two-Bone IK 解算器
│   ├── GenitalGenerator.gd     # 程序化男性生殖器
│   ├── BreastGenerator.gd      # 程序化女性胸部 (可调大小)
│   ├── FaceSystem.gd           # 程序化面部+表情系统 (5种表情)
│   └── UI.gd                   # 控制面板 v2.0 (姿势选择+滑块+表情+模型加载)
├── .github/workflows/
│   └── build-apk.yml           # CI 流水线: GitHub Actions 打包 APK
├── lib/                        # 遗留 (无关)
├── js/                         # 遗留 (无关)
├── ui/                         # 遗留 (无关)
└── assets/                     # 放置外部模型文件 (FBX/GLB/OBJ)
```

## 三、技术栈

| 项目 | 值 |
|---|---|
| 引擎 | Godot 3.5.2 (arm64, 本地 apt 安装) |
| 本地校验 | godot3-server (headless) |
| 云端打包 | GitHub Actions → x86_64 Godot 3.5.2 官方版 + JDK17 + Android SDK |
| 输出 | APK (arm64-v8a, 包名 com.adultgame3d.prototype) |
| 渲染 | GLES3 |
| 分辨率 | 1280x720 |

## 四、本地环境 (只在手机 Ubuntu proot 里)

- Godot 3.5.2 已安装: `/usr/bin/godot3` 和 `/usr/bin/godot3-server`
- 用于本地代码校验: `cd /sdcard/Download/AdultGame3D && godot3-server --path . --quit`
- 没有 GPU 直通 → 启动时会有 headless 虚拟渲染器的无害警告

## 五、项目当前状态 (已完成)

### ✅ 已完成
1. 技术路线确认: Godot 3.5 + GitHub Actions CI 云端打包
2. 项目目录搭建
3. CI 流水线 (`build-apk.yml`)
4. **Character.gd v2.0** — 17骨骼 + 程序化网格 + 外部FBX/GLB模型加载 (自动骨骼名映射)
5. GenitalGenerator.gd — 程序化男性生殖器 (柱体+龟头+睾丸)
6. BreastGenerator.gd — 程序化女性胸部 (可调大小)
7. FaceSystem.gd — 程序化面部+表情 (中性/开心/难过/兴奋/痛苦)
8. IK.gd — Two-Bone IK 解算器 (余弦定理+四元数)
9. **MotionEngine.gd v2.0** — 三频波形合成 + 延迟传播(全身波动感) + 体位感知
10. **PoseSystem.gd** — 8种体位定义 (传教士/后入/女上位/反向女上位/侧躺/站立/床边/汤勺)
11. **Main.gd v2.0** — 双角色构建 + IK贴合 + 姿势切换 + 动作驱动 + 外部模型加载
12. **UI.gd v2.0** — 控制面板 (姿势选择器/模式切换/速度/幅度/前倾/贴合/表情/胸部/模型加载)
13. 本地语法验证通过 (零 SCRIPT ERROR)

### 🔊 已知无害警告 (headless 模式独有)
- `get_global_transform` before `is_inside_tree()` — 角色构建时序
- `mesh_get_surface_count` / `mesh_get_blend_shape_count` — 虚拟渲染器无网格
- `look_at()` up vector aligned — 灯光的 Y 轴和目标方向一致 (DirectionalLight 无影响)
- 以上全部不影响 APK 编译

### ⏳ 待处理
1. 推送代码到 GitHub 仓库 → 触发 Actions 云端打包
2. 首次打包可能失败需要调试:
   - GitHub Actions 的 export_templates 解压路径可能需要调整
   - 默认没有 keystore → 导出 debug APK 或生成自签名证书
3. 出 APK 后安装到手机验证:
   - 确认角色渲染正确
   - 确认 8 种姿势切换效果
   - 确认 IK 贴合效果
   - 确认 UI 交互响应
4. 下载外部模型放入 assets/ 目录测试:
   - 推荐免费源: CGTrader (free rigged female), TurboSquid (free woman), Free3D, 爱给网
   - 格式支持: FBX/GLB/GLTF/OBJ
   - 通过 UI 的"加载女模"按钮选择文件
5. 后续迭代方向:
   - 接入动捕动作数据
   - 物理模拟 (布料/碰撞)
   - 场景内容 (房间/家具)
   - 更多姿势和过渡动画

## 六、Godot 3.5 兼容性要点 (踩坑记录)

1. **class_name 注册延迟**: headless 模式下 `class_name` 不自动注册。解决方案: 在 Main.gd 和 Character.gd 顶部加 `preload` 常量
2. **`char` 是保留字**: 不能用作参数名或变量名
3. **`floor` 是内置函数**: 不能用作变量名 (Main.gd 用 `floor_mi` 代替)
4. **`Quat * Basis` 不兼容**: 改用 `Basis(q) * from_basis`
5. **CapsuleMesh**: 使用 `mid_height` 而非 `height` (Godot 4 属性)
6. **MeshInstance**: 使用 `translation` 而非 `position` (Godot 4 属性)
7. **Panel**: 使用 `add_stylebox_override("panel", style)` 而非 `add_style_override("panel", style)`
8. **类型注解**: Godot 3.5 不支持 `var x: Type` 和 `func f() -> void` 语法
9. **look_at 时序**: 必须在 `add_child` 之后调用，否则 `!is_inside_tree()`
10. **字典重复键**: 注意 `"spine2": "chest"` 出现两次会报 Parse Error

## 七、关键代码架构

### Character.gd
- `_build_skeleton()`: 17 个 Spatial 骨骼节点
- `_build_meshes()`: 胶囊体/球体网格挂在各骨骼下
- `_build_attachments()`: 挂 FaceSystem + 胸部/生殖器
- `load_external_model(path, is_female)`: 加载外部 FBX/GLB 模型，自动骨骼名映射
- `set_female() / set_breast_size() / set_emotion()`: 属性控制

### PoseSystem.gd (新增)
- `enum Pose` — 8 种体位: MISSIONARY(0) / DOGGY(1) / COWGIRL(2) / REVERSE_COWGIRL(3) / SIDE(4) / STANDING(5) / EDGE(6) / SPOON(7)
- `static func get_pose_name(pose)`: 返回中文名
- `static func get_pose_data(pose)`: 返回体位参数 (pos_a/rot_a/pos_b/rot_b/ik_spread/ik_forward/lean_a/hip_angle_a 等)

### Main.gd
- `_build_environment()`: 地板 + 灯光 + 相机 (跟随角色A)
- `_build_characters()`: 男角色 A + 女角色 B + 双 MotionEngine
- `_build_ik_system()`: IK 目标标记 (4个Spatial)
- `_run_ik(delta)`: 角色B腿部IK贴合到角色A臀部
- `_apply_pose(pose)`: 切换体位 (双角色位置/旋转 + 重置动作引擎)
- UI 控制接口: `set_speed/set_intensity/set_lean/set_ik_weight/set_posture/set_emotion/set_breast_size/load_female_model/load_male_model`

### MotionEngine.gd v2.0
- 4 种模式: STAND(0) / RHYTHM(1) / FAST(2) / FOLLOW(3)
- 三频波形合成: `wave1*0.6 + wave2*0.3 + wave3*0.1` → 真实不单调
- 延迟传播: 臀部 → 脊柱(0.05s延迟) → 胸部(0.10s延迟) → 头部补偿
- 体位感知: 接收 `pose_data` 中的 `lean_a` / `hip_angle_a` 参数

### UI.gd v2.0
- 姿势选择器: 循环切换 8 种体位
- 模式切换: 站立/常规/快速/贴合
- 滑块: 速度/幅度/前倾/贴合度/胸部大小
- 表情按钮: 中性/开心/难过/兴奋/痛苦
- 文件对话框: 加载外部 FBX/GLB/GLTF/OBJ 模型

### IK.gd
- `static func solve_chain(a, b, c, target, pole, weight)`: 余弦定理求关节角 + 四元数旋转对齐
- `static func _aim_rotation(from_basis, target_dir)`: 让 Y 轴指向目标方向，返回 Basis

## 八、免费女性 3D 模型推荐

以下站点可下载免费(FBX/GLB)女性角色模型放入 assets/ 目录：

1. **CGTrader** — https://www.cgtrader.com/free-3d-models/character/woman
   - 搜索 "free rigged female" 有多个免费可选
2. **TurboSquid** — https://www.turbosquid.com/3d-model/free/woman/fbx
   - 免费女性模型 ~1300+ 个
3. **Free3D** — https://free3d.com/3d-models/fbx-female-characters
4. **爱给网** — https://www.aigei.com/3d/work/nv_ren (需登录)
5. **Sketchfab CC0** — https://sketchfab.com/3d-models?features=downloadable&licenses=cc0
6. **Mixamo** — https://www.mixamo.com (免费角色+动画)
7. **Kenney** — https://kenney.nl/assets (CC0 风格化角色)

## 九、GitHub 推送指南

```bash
# 在手机上 (Ubuntu proot 终端)
cd /sdcard/Download/AdultGame3D
git init
git add -A
git commit -m "v2.0: 8 poses, external model loading, enhanced motion engine"
git remote add origin https://github.com/你的用户名/AdultGame3D.git
git push -u origin main
```

推送后 → GitHub → Actions → 自动开始打包 → 约 3-5 分钟后在 Actions 页面下载 APK artifact

## 十、联系方式

- 项目路径: `/sdcard/Download/AdultGame3D/`
- 本地校验命令: `cd /sdcard/Download/AdultGame3D && timeout 30 godot3-server --path . --quit`
- CI 文件: `.github/workflows/build-apk.yml`