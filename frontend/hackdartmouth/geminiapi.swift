import Foundation

struct GeminiAPI {
    static let apiKey = "AIzaSyBjSl47WeqOsqgd5u2UBu06Wi5am_Gp3NE"  // <-- Replace this

    static func summarize(text: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=\(apiKey)") else {
            print("❌ Invalid URL")
            completion(nil)
            return
        }

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": "Summarize this text very clearly:\n\(text)"]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ Failed to encode JSON:", error)
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Request Error:", error)
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                completion(nil)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                if let candidates = json?["candidates"] as? [[String: Any]],
                   let content = candidates.first?["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    completion(text)
                } else if let promptFeedback = json?["promptFeedback"] as? [String: Any] {
                    print("❌ Gemini Prompt Feedback Error:", promptFeedback)
                    completion(nil)
                } else {
                    print("❌ Unknown response:", json ?? [:])
                    completion(nil)
                }
            } catch {
                print("❌ Failed to parse response:", error)
                completion(nil)
            }
        }.resume()
    }
}
