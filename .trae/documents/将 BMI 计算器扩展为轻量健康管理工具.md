## 目标
- 将现有单一 BMI 工具扩展为“轻量健康管理工具”，提升应用审核通过率与用户价值。
- 一期新增三项：健康建议模块（文本）、BMR + TDEE 计算器、体重趋势图（基于历史数据，优先使用 fl_chart）。
- 坚持无侵入与低成本原则，最大化复用现有页面、存储与主题。

## 现状概览
- 入口与路由：`lib/main.dart`（深色主题、`onGenerateRoute` 支持深链、静态 `_routes`）。
- BMI 功能：`lib/Screens/input_page.dart` → `lib/Screens/Results_Page.dart`；计算与建议在 `lib/calculator_brain.dart`；历史存储 `SharedPreferences`（键 `bmi_history`）。
- 历史与趋势：`lib/Screens/BMIHistoryPage.dart` 展示历史；`lib/Screens/BMITrendPage.dart` 自绘 BMI 折线图。
- 依赖：`pubspec.yaml` 已声明 `fl_chart: ^0.66.2`（当前未使用），状态管理 `flutter_bloc`；本地覆盖 HarmonyOS 相关依赖；已有工具集入口 `lib/Screens/tools_hub_page.dart`。

## 新增功能设计
### 1. 健康建议模块（文本）
- 新页面：`HealthAdvicePage`（`lib/Screens/HealthAdvicePage.dart`）。
- 数据来源：直接读取最近一条 `BMIRecord`（含：性别、年龄、身高、体重、活动水平、BMI）。
- 内容结构：
  - 分类建议：按中国成人 BMI 分级（<18.5、18.5–23.9、24–27.9、≥28）给出饮食与运动建议，扩展现有 `Calculate.getAdvise()` 为更系统的文本段落。
  - 行动清单：可执行的每日/每周简单清单（不涉及医疗建议）。
  - 安全与免责声明：强调非医疗用途、鼓励线下咨询。
  - 延伸阅读：跳转至 `HealthInfoSourcesPage`。
- 入口：
  - `Results_Page` 增加“查看个性化建议”按钮。
  - `tools_hub_page.dart` 增加“健康建议”卡片。

### 2. BMR + TDEE 计算器（≤1天完成）
- 新页面：`BmrTdeeCalculatorPage`（`lib/Screens/BmrTdeeCalculatorPage.dart`）。
- 输入项：性别、年龄、身高（cm）、体重（kg）、活动水平（5 档：1.2/1.375/1.55/1.725/1.9）。
- 公式：采用 Mifflin–St Jeor（更现代且通用）
  - Male：`BMR = 10*W + 6.25*H - 5*A + 5`
  - Female：`BMR = 10*W + 6.25*H - 5*A - 161`
  - `TDEE = BMR * ActivityMultiplier`
- 展示：维护热量、轻度减脂/增肌建议区间（如 ±10%）、每周体重变化估算（基于 7700 kcal/kg）。
- 交互：
  - 从 `InputPage` 自动预填（性别/身高/体重/活动水平）；允许编辑。
  - 可选择“保存为记录”到独立键 `bmr_tdee_history`（`SharedPreferences`），便于后续查看。
- 入口：
  - `tools_hub_page.dart` 的“能量与营养”内新增卡片直达。
  - `home_tab_container.dart` 的“Trend/Settings”页可加快捷入口（不改动底部四大 Tab）。

### 3. 体重趋势图（历史数据直接可用，使用 fl_chart）
- 新页面：`WeightTrendPage`（`lib/Screens/WeightTrendPage.dart`）。
- 数据来源：`BMIHistoryManager.getBMIHistory()` 中的 `weight` 与 `time`。
- 图表：`fl_chart` 的 `LineChart`
  - 支持时间范围（7/30/90/365/全部/自定义）、采样与平滑（移动平均）。
  - 目标线：读取（新增）`goal_weight` 设置；提供设定入口或复用 `GoalsPage` 扩展。
  - 指标卡片：样本数、均值、最小值、最大值、近 30 天变化。
- 入口：
  - `BMITrendPage` 内增加切换 Tab（BMI | 体重）。
  - 或在 `home_tab_container.dart` 的 Trend Tab 下作为二级页面。
- 兼容性：保留现有自绘 BMI 图为回退；若 `fl_chart` 在特定终端表现异常，可添加设置开关切换。

## 路由与导航变更
- 在 `lib/main.dart` 的 `_routes` 中新增：
  - `HealthAdvicePage.routeName`
  - `BmrTdeeCalculatorPage.routeName`
  - `WeightTrendPage.routeName`
- 在现有页面植入入口按钮：`Results_Page`、`tools_hub_page.dart`、`BMITrendPage` 或 `home_tab_container.dart`。

## 数据与设置
- 复用历史：`bmi_history` 不改动结构；体重趋势直接读取其 `weight` 与 `time` 字段。
- 新增设置：`goal_weight`（同 `goal_bmi` 的读写风格）。
- 新历史键：`bmr_tdee_history`（简单列表 `List<String>` 保存 JSON 记录）。

## UI/UX 与一致性
- 主题与组件风格保持与现有一致（深色主题、卡片、圆角、按钮样式）。
- 文本内容遵循简洁、明确、非医疗承诺；所有建议配安全提示。
- 表单校验：数值范围与单位一致（cm/kg），活动水平下拉或单选。

## 与《开发者指南》3.5 对齐
- 丰富功能：从单一 BMI 拓展为建议、代谢、趋势三位一体。
- 用户价值：提供持续性数据洞察（趋势）与行动指导（建议、能量），提升留存。
- 持续优化：模块化设计，后续可增：周报卡片、目标提醒、更多营养工具。
- 合规与透明：隐私与来源页已存在，新增建议页继续强调非医疗性质。

## 验收标准
- 新增三个路由页面可达，数据来源正确，UI一致。
- BMR/TDEE 计算与校验通过（含预填与手动输入）。
- 体重折线在不同时间范围都正常渲染，统计数据准确。
- 健康建议文本根据最新 BMI 分类正确切换，含行动清单与安全提示。

## 风险与回退
- 图表库兼容性：如 `fl_chart` 在特定机型异常，提供设置切换到现有自绘图。
- 存储数据膨胀：历史为轻量 JSON 字符串列表，必要时增加压缩或分页加载（后续迭代）。

## 开发与排期
- Day 1：完成 BMR + TDEE 计算器页面与路由、预填与校验、历史保存。
- Day 2：完成健康建议页面与入口接入；
- Day 3：接入体重趋势图（fl_chart）、时间范围与统计卡片；与 Trend 页整合或作为二级页面。
- 可按优先级调整：若需尽快提审，先上线 BMR/TDEE 与健康建议，趋势图随后更新。