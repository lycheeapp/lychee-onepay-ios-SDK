import Foundation
import UIKit

public class LycheeOnePay: @unchecked Sendable {
    public static let shared = LycheeOnePay()

    private var apiKey: String?
    private var secretKey: String?
    private var storeName: String?
    private var storeLogo: UIImage?
    private var baseUrl: String?
    private let versionName = "1.0.0"
    private var isInitialized = false

    private init() {}

    public func initialize(
        apiKey: String,
        secretKey: String,
        storeName: String,
        baseUrl: String,
        storeLogo: UIImage? = nil
    ) {
        self.apiKey = apiKey
        self.secretKey = secretKey
        self.storeName = storeName
        self.storeLogo = storeLogo
        self.baseUrl = baseUrl
        self.isInitialized = true
    }

    private func checkInitialization() {
        if !isInitialized {
            fatalError(
                "LycheeOnePay is not initialized. Call initialize() first."
            )
        }
    }

    public func getVersionName() -> String {
        checkInitialization()
        return versionName
    }

    public func getApiKey() -> String {
        checkInitialization()
        return apiKey ?? ""
    }

    public func getSecretKey() -> String {
        checkInitialization()
        return secretKey ?? ""
    }

    public func getStoreName() -> String {
        checkInitialization()
        return storeName ?? ""
    }

    public func getStoreLogo() -> UIImage? {
        checkInitialization()
        return storeLogo
    }

    public func getBaseUrl() -> String {
        checkInitialization()
        if !isInitialized {
            fatalError(
                "LycheeOnePay is not initialized. Call initialize() first."
            )
        }
        return baseUrl ?? ""
    }
}
