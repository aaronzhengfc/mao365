import XCTest

final class Mao365UITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testFirstFiveBundledImagesAndFullDescriptions() throws {
        let scenes = [
            "中央大街暖黄橱窗与蓝色暮雪，远处街灯渐亮",
            "扎龙湿地冬日苇秆与远处鹤影，前景木栈道",
            "镜泊湖冰面与岸边覆雪树枝，暖红小屋点景",
            "松花江边清晨蓝白雾凇，天际一点橙光",
            "城市湿地冬苇结霜，窗外冷蓝风雪、窗内暖橙灯；远处工业轮廓简化"
        ]
        for day in 1...5 {
            let app = XCUIApplication()
            app.launchArguments = ["--day", String(day)]
            app.launch()
            let imageID = String(format: "album.image.D%03d", day)
            XCTAssertTrue(app.images[imageID].waitForExistence(timeout: 10))
            XCTAssertEqual(app.descendants(matching: .any)["album.description"].label, scenes[day - 1])
            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.name = "Day \(day)"
            screenshot.lifetime = .keepAlways
            add(screenshot)
            app.terminate()
        }
    }

    @MainActor
    func testSwipeKeepsDayImageRegionAndDescriptionTogether() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--day", "1"]
        app.launch()
        XCTAssertTrue(app.images["album.image.D001"].waitForExistence(timeout: 10))
        app.images["album.image.D001"].swipeLeft()
        XCTAssertTrue(app.images["album.image.D002"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["album.dayPicker"].label.hasPrefix("Day 2，"))
        XCTAssertEqual(app.staticTexts["album.region"].label, "黑龙江 · 齐齐哈尔市")
        XCTAssertEqual(app.descendants(matching: .any)["album.description"].label,
                       "扎龙湿地冬日苇秆与远处鹤影，前景木栈道")
    }

    @MainActor
    func testAll365DaysAreSelectableWithoutReusingSampleImages() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["album.dayPicker"].tap()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("D365")
        let lastDay = app.buttons["day.select.D365"]
        XCTAssertTrue(lastDay.waitForExistence(timeout: 5))
        lastDay.tap()
        XCTAssertTrue(app.descendants(matching: .any)["album.placeholder.D365"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["album.dayPicker"].label.hasPrefix("Day 365，"))
        XCTAssertFalse(app.images["album.image.D001"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["album.description"].label.isEmpty)
    }

    @MainActor
    func testSwipeFromDay4ToDay5DoesNotResizeTheArtwork() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--day", "4"]
        app.launch()
        let fourthImage = app.images["album.image.D004"]
        XCTAssertTrue(fourthImage.waitForExistence(timeout: 10))
        let before = fourthImage.frame
        let captionBefore = app.buttons["album.dayPicker"].frame.minY
        fourthImage.swipeLeft()
        let fifthImage = app.images["album.image.D005"]
        XCTAssertTrue(fifthImage.waitForExistence(timeout: 10))
        let after = fifthImage.frame
        XCTAssertEqual(before.minX, after.minX, accuracy: 0.5)
        XCTAssertEqual(before.minY, after.minY, accuracy: 0.5)
        XCTAssertEqual(before.width, after.width, accuracy: 0.5)
        XCTAssertEqual(before.height, after.height, accuracy: 0.5)
        XCTAssertEqual(captionBefore, app.buttons["album.dayPicker"].frame.minY, accuracy: 0.5)

        let description = app.descendants(matching: .any)["album.description"]
        description.tap()
        let fullDescription = app.staticTexts["album.fullDescription"]
        XCTAssertTrue(fullDescription.waitForExistence(timeout: 5))
        XCTAssertEqual(fullDescription.label,
                       "城市湿地冬苇结霜，窗外冷蓝风雪、窗内暖橙灯；远处工业轮廓简化")
    }
}
