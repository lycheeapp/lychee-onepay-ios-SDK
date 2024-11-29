import SwiftUI

struct PaymentSuccessView: View {
    let paymentAmount: Double
    let onDone: () -> Void

    var body: some View {
        VStack {
            Spacer()
            
            Image(
                uiImage: UIImage(
                    named: "success",
                    in: Bundle.module,
                    compatibleWith: nil
                )!
            )
            .resizable()
            .frame(width: 80, height: 80)
            .foregroundColor(.green)
            .padding(.bottom, 24)
            
            Text("payment_success".localized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom, 16)
            
            Text(
                String(
                    format: "your_payment_of_has_been_successfully_done".localized,
                    "ILS \(String(format: "%.2f", paymentAmount))"
                )
            )
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
            
            Button(action: onDone) {
                Text("button_done".localized)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGreen)
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .padding()
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}
