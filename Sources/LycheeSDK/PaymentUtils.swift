import Foundation
import CommonCrypto

class PaymentUtils {
    static func submitPayment(
        voucherCode: String,
        amount: Double,
        onSuccess: @escaping @Sendable () -> Void,
        onFailure: @escaping @Sendable (String) -> Void
    ) {
        let baseUrl =  LycheeOnePay.shared.getBaseUrl()
        let apiKey =  LycheeOnePay.shared.getApiKey()
        let secretKey =  LycheeOnePay.shared.getSecretKey()
        
        let payload = constructPayload(voucherCode: voucherCode, amount: amount)
        let signature = createSignature(payload: payload, secretKey: secretKey)
        
        let url = URL(string: "\(baseUrl)/rest/lychee-v2/public/one-pay/pay")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue(signature, forHTTPHeaderField: "X-Signature")
        request
            .setValue(
                LycheeOnePay.shared.getVersionName(),
                forHTTPHeaderField: "X-SDK-Version"
            )
        let currentLanguage = getCurrentAppLanguage()
        request.setValue(currentLanguage, forHTTPHeaderField: "Accept-Language")
        
        let requestBody = [
            "amount": amount,
            "code": voucherCode,
            "deviceUDID": DeviceUtils.getUniqueDeviceIdentifier() 
        ] as [String: Any]
        
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: requestBody
            )
            request.httpBody = jsonData
        } catch {
            onFailure("Failed to encode request.")
            return
        }
        
//        logRequest(request: request, requestBody: requestBody)
        
        URLSession.shared.dataTask(with: request) {
 data,
 response,
 error in
            if let error = error {
                logError(error: error)
                onFailure("Network Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
//                logResponse(response: httpResponse, data: data)
                guard httpResponse.statusCode == 200 else {
                    let errorMessage = handleStatusCode(
                        status: httpResponse.statusCode,
                        data: data
                    )
                    onFailure(errorMessage)
                    return
                }
            }
            
            onSuccess()
        }.resume()
    }
    
    private static func handleStatusCode(status: Int, data: Data?) -> String {
        do {
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
               let message = json["message"] as? String {
                return message
            } else {
                return "Message key not found."
            }
        } catch {
            return "Failed to process payment"
        }
    }
    
    private static func constructPayload(voucherCode: String, amount: Double) -> String {
        let formattedAmount = String(format: "%.2f", amount)
        let udid = DeviceUtils.getUniqueDeviceIdentifier()
        return "amount:\(formattedAmount)$$$code:\(voucherCode)$$$deviceUDID:\(udid)"
    }
    
    private static func createSignature(payload: String, secretKey: String) -> String {
        let dataToHash = secretKey + payload
        guard let data = dataToHash.data(using: .utf8) else {
            return ""
        }
        
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        let hashData = Data(hash)
        return hashData.base64EncodedString()
    }
    
    private static func getCurrentAppLanguage() -> String {
        let currentLanguage = Locale.current.languageCode ?? "ar-EG"
        switch currentLanguage {
        case "en":
            return "en-US"
        case "ar":
            return "ar-EG"
        default:
            return "ar-EG"
        }
    }

    
    // MARK: - Logging Functions
    private static func logRequest(
        request: URLRequest,
        requestBody: [String: Any]
    ) {
        print("---- Request ----")
        if let url = request.url {
            print("URL: \(url.absoluteString)")
        }
        if let method = request.httpMethod {
            print("Method: \(method)")
        }
        
        print("Headers:")
        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers {
                print("\(key): \(value)")
            }
        }
        
        print("Body:")
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: requestBody,
                options: .prettyPrinted
            )
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("Failed to print request body.")
        }
        print("----------------")
    }
    
    private static func logResponse(response: HTTPURLResponse, data: Data?) {
        print("---- Response ----")
        print("Status Code: \(response.statusCode)")
        
        print("Headers:")
        for (key, value) in response.allHeaderFields {
            print("\(key): \(value)")
        }
        
        if let data = data, let responseString = String(
            data: data,
            encoding: .utf8
        ) {
            print("Body:")
            print(responseString)
        } else {
            print("No response body.")
        }
        print("------------------")
    }
    
    private static func logError(error: Error) {
        print("---- Error ----")
        print("Description: \(error.localizedDescription)")
        print("--------------")
    }
}
