import SwiftUI

public enum PaymentStatus {
    case success
    case cancelled
}

public struct LycheePaymentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var voucherCode: String = ""
    @State private var showPaymentSuccess = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var storeName: String = "Loading..."
    @State private var storeLogo: UIImage? = nil
    @State private var isLoading = false

    private var paymentAmount: Double
    private var onPaymentStatusChange: (PaymentStatus) -> Void

    public init(
        amount: Double,
        onPaymentStatusChange: @escaping (PaymentStatus) -> Void
    ) {
        self.paymentAmount = amount
        self.onPaymentStatusChange = onPaymentStatusChange
    }

    public var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    HStack {
                        Button(action: {
                            onPaymentStatusChange(.cancelled)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: DeviceUtils.getDirection() == .rightToLeft ? "chevron.right" : "chevron.left")
                                     .foregroundColor(.black)
                                     .padding()
                        }

                        Spacer()

                        Text("title_pay_with_lychee".localized)
                            .font(.headline)
                            .padding(.trailing)

                        Spacer()
                    }
                    .background(Color.white)

                    HStack {
                        Image(
                            uiImage: storeLogo ?? UIImage(
                                named: "laychee",
                                in: Bundle.module,
                                compatibleWith: nil
                            )!
                        )
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                        Text(storeName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.leading, 8)

                        Spacer()

                        Text("ILS \(formatAmount(paymentAmount))")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)

                    Spacer().frame(height: 24)

                    HStack {
                        Text("enter_your_onepay_code_to_pay".localized)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal)

                    HStack(spacing: 0) {
                        TextField("9EIMBD", text: $voucherCode)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .frame(height: 50)
                            .autocapitalization(.allCharacters)

                        Image(
                            uiImage: (
                                voucherCode.count >= 6 ? UIImage(named: "one-pay-enabled", in: Bundle.module, compatibleWith: nil) : UIImage(
                                    named: "one-pay-disabled",
                                    in: Bundle.module,
                                    compatibleWith: nil
                                )
                            )!
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .padding(.trailing, 8)
                    }
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.lightGrayBorder, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)

                    NavigationLink(
                        destination: PaymentSuccessView(
                            paymentAmount: paymentAmount
                        ) {
                            onPaymentStatusChange(.success)
                            presentationMode.wrappedValue.dismiss()
                        },
                        isActive: $showPaymentSuccess) {
                            EmptyView()
                        }

                    Button(action: processPayment) {
                        Text("button_pay_now".localized)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(voucherCode.count >= 6 ? Color.primaryGreen : Color.disabledGray)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                    .disabled(voucherCode.count < 6)
                    .padding(.horizontal)

                    Button(action: {
                        if let url = URL(string: "https://lycheeapp.org/") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }) {
                        Text("no_voucher_get_a_code".localized)
                            .foregroundColor(.black)
                            .underline()
                            .font(.system(size: 14, weight: .bold))
                    }.padding(.top, 8)
                
                    Spacer().frame(height: 8)

                    HStack(spacing: 0) {
                        Image(
                            uiImage: UIImage(
                                named: "secured-by",
                                in: Bundle.module,
                                compatibleWith: nil
                            )!
                        )
                        .resizable()
                        .frame(width: 12, height: 15)
                        .aspectRatio(contentMode: .fit)
                        Spacer().frame(width: 8)
                        Text("secured_by".localized)
                            .font(.caption)
                            .fontWeight(.light)
                            .foregroundColor(.darkText)
                        Spacer().frame(width: 2)
                        Text("OnePay")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }.padding(.bottom)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .onAppear(perform: loadStoreInfo)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("payment_error".localized),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("button_done".localized))
                    )
                }

                if isLoading {
                    Color.overlayBlack.ignoresSafeArea()
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryGreen))
                            .scaleEffect(1.5)
                            .padding()
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }
            }
        }
    }

    private func processPayment() {
        isLoading = true
        PaymentUtils.submitPayment(
            voucherCode: voucherCode,
            amount: paymentAmount,
            onSuccess: {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.showPaymentSuccess = true
                }
            },
            onFailure: { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertMessage = error
                    self.showAlert = true
                }
            }
        )
    }

    private func loadStoreInfo() {
        storeName = LycheeOnePay.shared.getStoreName()
        storeLogo = LycheeOnePay.shared.getStoreLogo()
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US") 
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}
