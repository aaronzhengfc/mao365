import Foundation
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "D001" asset catalog image resource.
    static let D_001 = DeveloperToolsSupport.ImageResource(name: "D001", bundle: resourceBundle)

    /// The "D002" asset catalog image resource.
    static let D_002 = DeveloperToolsSupport.ImageResource(name: "D002", bundle: resourceBundle)

    /// The "D003" asset catalog image resource.
    static let D_003 = DeveloperToolsSupport.ImageResource(name: "D003", bundle: resourceBundle)

    /// The "D004" asset catalog image resource.
    static let D_004 = DeveloperToolsSupport.ImageResource(name: "D004", bundle: resourceBundle)

    /// The "D005" asset catalog image resource.
    static let D_005 = DeveloperToolsSupport.ImageResource(name: "D005", bundle: resourceBundle)

}

