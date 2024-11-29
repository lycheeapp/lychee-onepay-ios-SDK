
# Lychee OnePay iOS SDK

Lychee OnePay is a lightweight payment library designed to simplify the integration of payment functionality into your iOS apps. This SDK is available as a Swift Package and can be easily integrated into your project.

---

## Installation

To add Lychee OnePay to your iOS project, follow these steps:

1. Open your Xcode project.
2. Navigate to **File > Add Packages...**.
3. Enter the following URL in the search bar:
   ```
   https://bitbucket.org/lychee-tm/lychee-onepay-ios-sdk/src/main/
   ```
4. Select the appropriate version or branch and click **Add Package**.
5. Add the package to your desired target(s).

---

## Setting Up Environment Variables

Before initializing the library, securely store your `apiKey` and `apiSecret` as environment variables or configuration files. These keys are critical for authentication and should not be hardcoded into the app.

---

## Initialization

Initialize the Lychee OnePay SDK in your app's startup sequence. Below is an example of how to set up the SDK in a SwiftUI app:

```swift
@main
struct SampleApp: App {
    init() {
        LycheeOnePay.shared.initialize(
            apiKey: "<Your API Key>",
            secretKey: "<Your Secret Key>",
            storeName: "<Your Store Name>",
            baseUrl: "<Base URL obtained from Lychee>",
            storeLogo: UIImage(named: "store-logo") // Optional
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

Make sure to replace `<Your API Key>`, `<Your Secret Key>`, `<Your Store Name>`, and `<Base URL obtained from Lychee>` with the actual values.

---

## Usage Example

Lychee OnePay provides a ready-to-use payment view, `LycheePaymentView`. Here's an example of how you can use it in your SwiftUI app to handle payments:

```swift
import SwiftUI
import LycheeSDK

struct AmountEntryView: View {
    @State private var amount: String = ""
    @State private var showPaymentView = false
    @State private var paymentAmount: Double = 0.0
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter amount", text: $amount)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: amount) { newValue in
                    let filtered = newValue.filter { "0123456789.".contains($0) }
                    let decimalCount = filtered.filter { $0 == "." }.count
                    if decimalCount <= 1 {
                        amount = filtered
                    } else {
                        amount = String(filtered.dropLast())
                    }
                    if let validAmount = Double(amount) {
                        paymentAmount = validAmount
                    }
                }

            Button(action: {
                if paymentAmount > 0 {
                    showPaymentView = true
                }
            }) {
                Text("Pay Now")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(amount.isEmpty || paymentAmount == 0.0)

            Spacer()
        }
        .fullScreenCover(isPresented: $showPaymentView) {
            LycheePaymentView(amount: paymentAmount) { status in
                DispatchQueue.main.async {
                    switch status {
                    case .success:
                        alertMessage = "Payment successful!"
                    case .cancelled:
                        alertMessage = "Payment was cancelled."
                    }
                    showAlert = true
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Payment Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .padding()
        .navigationTitle("Enter Amount")
    }
}
```

This example demonstrates how to:
- Accept a payment amount from the user.
- Use `LycheePaymentView` to initiate a payment.
- Handle the result of the payment (`success` or `cancelled`).

---

## Contribution

If you'd like to contribute to Lychee OnePay, feel free to fork the repository and submit a pull request. For major changes, please open an issue to discuss your ideas.

---

## License

Lychee OnePay is available under the [License Name]. See the `LICENSE` file for more information.
