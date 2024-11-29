import SwiftUI

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: .module, comment: "")
    }
    var isRTL: Bool {
        let rtlLanguages = ["ar", "he", "fa", "ur"]
        return rtlLanguages.contains(self)
    }
}
