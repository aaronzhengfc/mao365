# 猫猫365 · iOS

打开 `Mao365.xcodeproj`，选择 `Mao365` scheme 和一个 iPhone 模拟器，点击 Run。
最低版本 iOS 17，无第三方依赖。真机运行时，在 Signing & Capabilities 里选择自己的开发团队。

主屏上方完整显示图片，下方仅显示 Day、省市和完整 `scene` 描述。左右滑动切换日期；点击 Day 可搜索并跳转到任意一天。默认从 Day 1 开始。

- `Mao365/Resources/album-2027.json`：完整365条审校数据，与根目录 `data/album-2027-v2.json` 保持一致。
- `Mao365/Assets.xcassets/D001.imageset` 至 `D005.imageset`：前5天原图；D005 使用去掉手指边缘后的 v2。
- D006–D365 的数据已经可浏览，但当前没有导入图片，展示独立的待出图占位，不复用其他日期的图片。
- 后续在资源目录增加同名 `D006.imageset` 等资产即可自动显示。
- `../scripts/sync_ios_resources.py`：同步完整数据及所需图片；默认导入前5张。

图片采用等比完整显示，适配不同比例的 iPhone 时允许少量纸色留边，不裁切猫咪和原图。所有日期共用固定图片区和紧凑信息区，文案长短不会引起图片缩放；底部保留 Home Indicator 安全区。主屏描述保留两行，轻点可查看全文。信息区随系统文字大小统一缩放，而非随每天的描述改变高度。

```sh
python3 ../scripts/sync_ios_resources.py
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project Mao365.xcodeproj -scheme Mao365 \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
```

本工程的翻页使用 [Apple SwiftUI PageTabViewStyle](https://developer.apple.com/documentation/swiftui/pagetabviewstyle)，主屏不显示额外分页圆点或导航栏。
