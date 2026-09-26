# 重生之我也要取经 · 1.9

西游题材的单人 2D 像素肉鸽游戏，支持电脑键盘和手机触屏。

**[直接在线游玩](https://qujing-journey-2026.pages.dev/)** · [下载发布包](../../releases/latest)

## 开始游玩

在线打开即可游玩，无需注册。离线游玩请解压 `youxi1-1.9.0-web.zip`，双击 `index.html`；文件必须保持在同一目录。源码压缩包同样可以直接运行。

WASD / 方向键移动，空格主动技能，Shift 闪避，Q 使用袋首法宝，Tab 地图，P / Esc 暂停，M 静音。角色自动瞄准最近敌人。手机使用屏幕摇杆和技能按钮。

存档仅保存在当前浏览器。手机与电脑、不同网站地址之间不会自动同步；1.9 沿用 1.8 存档键，能继续同一网站下的旧战局。

## 本版内容

原著八十一难整合为 37 个可玩主题章节，包含 26 场具名首领战。每章有连通的房间路线，清场后才能前进。

- 土地神龛从 14 种服务中随机提供 4 项。
- 珍奇货肆从 21 种商品和服务中随机提供 6 项，每项限购一次，可连续购买。
- 奇遇岔口包含 12 类事件，其中 2 类在对应地点出现。
- 同类内容优先轮换，地图和读档保留当次选项与购买记录。
- 法宝选项检查实际背包；无效交易不会扣钱。暂停和房间页面可整理、使用或合成法宝。

详细修复见 [更新说明](更新说明-1.9.md)。

## 项目文件

本项目直接运行原生 HTML、CSS 和 JavaScript，无构建步骤，无运行时 npm 依赖。

| 文件 | 用途 |
| --- | --- |
| `index.html`、`style.css`、`icon.svg` | 入口、样式和图标 |
| `game.js` | 游戏状态、战斗、绘制、触屏和存档 |
| `room-content.js`、`rooms.js` | 房间选项、条件和地图生成 |
| `lore.js`、`journey81.js`、`chapters.js` | 西游故事素材和章节 |
| `balance.js`、`systems.js`、`progression.js`、`item-pool.js` | 数值、角色、成长和法宝 |
| `audio.js` | 浏览器合成音效与音乐 |
| `smoke-test.js`、`room-test.js`、`browser-test.js` | 逻辑回归与真实浏览器测试 |
| `release-files.json`、`check-release.js`、`pack-release.ps1` | 发布文件清单、检查和打包 |
| `REVIEW.md` | 本次检查范围与发布说明 |

## 开发与检查

安装 Node.js 20 或更新版本。游戏逻辑检查无需安装依赖：

```sh
node room-test.js
node check-release.js
```

浏览器检查使用开发依赖 Playwright，覆盖桌面和 390px 手机布局、购买、背包、地图、读档和离开：

```sh
npm install
npx playwright install chromium
npm run test:browser
```

也可设置 `PLAYWRIGHT_CHANNEL=msedge` 使用已安装的 Edge。截图生成到 `qa-1.9/`，不纳入发布包。

Windows PowerShell 中运行 `./pack-release.ps1`，脚本先检查并测试，再按明确清单生成 `dist/` 下的网页包、源码包和 SHA-256 校验文件。源码包包含 26 个工程文件；网页包包含 14 个运行文件及许可证。

部署到静态网站时解压网页包，发布目录根部应直接包含 `index.html`，无需服务器、数据库、密钥或环境变量。

## 隐私与许可

游戏没有账号系统、统计脚本或上传存档接口，运行数据留在浏览器；托管平台可能记录一般访问日志。工程不包含部署凭证、私人联系方式、机器路径、浏览器资料或开发缓存。公开仓库会显示 GitHub 公开账号标识。

沿用仓库已有的 [GPL-3.0 许可证](LICENSE)。原著次序参考《西游记》第九十九回；游戏对白与叙事为原创转述。
