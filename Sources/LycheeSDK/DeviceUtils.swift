import UIKit

class DeviceUtils {
    static func getUniqueDeviceIdentifier() -> String {
        if let uuid = UserDefaults.standard.string(forKey: "uniqueDeviceIdentifier") {
            return uuid
        } else {
            let newUUID = UUID().uuidString
            UserDefaults.standard.set(newUUID, forKey: "uniqueDeviceIdentifier")
            return newUUID
        }
    }
    
    static func getDirection() -> Locale.LanguageDirection {
        guard let language = Locale.current.languageCode else { return .unknown }
        return Locale.characterDirection(forLanguage: language)
    }
}
