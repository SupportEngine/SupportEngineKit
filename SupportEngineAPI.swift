import Foundation

public class SupportEngineAPI {
    public static var apiToken: String = ""
    public static var baseURL: String = "https://yourdomain.com/api/"
    
    // MARK: - Create Ticket
    public static func createTicket(
        subject: String,
        message: String,
        userEmail: String,
        name: String? = nil,
        company: String? = nil,
        priority: String? = nil,
        categoryId: Int? = nil,
        customFields: [String: String]? = nil,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + "tickets_create.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        var params: [String: String] = [
            "subject": subject,
            "message": message,
            "user_email": userEmail
        ]
        if let name = name { params["name"] = name }
        if let company = company { params["company"] = company }
        if let priority = priority { params["priority"] = priority }
        if let categoryId = categoryId { params["category_id"] = String(categoryId) }
        if let customFields = customFields,
           let jsonData = try? JSONSerialization.data(withJSONObject: customFields, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            params["custom_fields"] = jsonString
        }
        
        request.httpBody = params
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(NSError(domain: "", code: -1))); return }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let json = json,
                   let success = json["success"] as? Bool, success,
                   let ticketId = json["ticket_id"] as? Int {
                    completion(.success(ticketId))
                } else {
                    let errorMsg = (json?["error"] as? String) ?? "Unknown error"
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - List Tickets
    public static func listTickets(
        userEmail: String,
        completion: @escaping (Result<[[String: Any]], Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + "tickets_list.php?user_email=\(userEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(NSError(domain: "", code: -1))); return }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let json = json,
                   let success = json["success"] as? Bool, success,
                   let tickets = json["tickets"] as? [[String: Any]] {
                    completion(.success(tickets))
                } else {
                    let errorMsg = (json?["error"] as? String) ?? "Unknown error"
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - View Ticket
    public static func viewTicket(
        ticketId: Int,
        userEmail: String,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + "ticket_view.php?ticket_id=\(ticketId)&user_email=\(userEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(NSError(domain: "", code: -1))); return }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let json = json,
                   let success = json["success"] as? Bool, success {
                    completion(.success(json))
                } else {
                    let errorMsg = (json?["error"] as? String) ?? "Unknown error"
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Reply to Ticket
    public static func replyToTicket(
        ticketId: Int,
        userEmail: String,
        message: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + "ticket_reply.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        let params: [String: String] = [
            "ticket_id": String(ticketId),
            "user_email": userEmail,
            "message": message
        ]
        request.httpBody = params
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(NSError(domain: "", code: -1))); return }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let json = json,
                   let success = json["success"] as? Bool, success,
                   let replyId = json["reply_id"] as? Int {
                    completion(.success(replyId))
                } else {
                    let errorMsg = (json?["error"] as? String) ?? "Unknown error"
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

// Usage Example (in your app):
// SupportEngineAPI.apiToken = "YOUR_API_TOKEN"
// SupportEngineAPI.baseURL = "https://yourdomain.com/api/"
// SupportEngineAPI.createTicket(subject: ..., message: ..., userEmail: ...) { result in ... }
// check the read me file.
