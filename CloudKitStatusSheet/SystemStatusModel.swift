//
//  SystemStatusModel.swift
//  Vitae
//
//  Created by robevans on 3/24/22.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let systemStatus = try? newJSONDecoder().decode(SystemStatus.self, from: jsonData)

import Foundation

// MARK: - SystemStatus
struct SystemStatus: Codable {
    let services: [Service]

    enum CodingKeys: String, CodingKey {
        case services = "services"
    }
}

// MARK: - Service
struct Service: Codable, Identifiable {
    let id = UUID()
    let redirectURL: String?
    let events: [Event]
    let serviceName: String

    enum CodingKeys: String, CodingKey {
        case redirectURL = "redirectUrl"
        case events = "events"
        case serviceName = "serviceName"
    }
}

// MARK: - Event
struct Event: Codable, Identifiable {
    let id = UUID()
    let usersAffected: String
    let epochStartDate: Int
    let epochEndDate: Int
    let messageID: String
    let statusType: String
    let datePosted: String
    let startDate: String
    let endDate: String
    let affectedServices: [String]?
    let eventStatus: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case usersAffected = "usersAffected"
        case epochStartDate = "epochStartDate"
        case epochEndDate = "epochEndDate"
        case messageID = "messageId"
        case statusType = "statusType"
        case datePosted = "datePosted"
        case startDate = "startDate"
        case endDate = "endDate"
        case affectedServices = "affectedServices"
        case eventStatus = "eventStatus"
        case message = "message"
    }
}

// MARK: - Encode/decode helpers

class SystemStatusModel: ObservableObject {

    @Published var systemStatusData: [SystemStatus] = []
    @Published var showErrorAlert = false
    @Published var errorMessage = ""

//    let systemStatusURL = "https://www.apple.com/support/systemstatus/data/system_status_en_US.js"
    let systemStatusURL = "https://www.apple.com/support/systemstatus/data/developer/system_status_en_US.js"
    
    func fetchSystemStatus() async -> [SystemStatus] {
        guard let url = URL(string: systemStatusURL) else {
            return []
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            // This is commented out data to try and gather developer system status
            var dataString = String(data: data, encoding: .utf8)
            dataString = dataString?.replacingOccurrences(of: "jsonCallback(", with: "")
            dataString = dataString?.replacingOccurrences(of: ");", with: "")
            let json = dataString?.data(using: .utf8)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("\(#function) \(response)")
                return []
            }

            let statusData = try JSONDecoder().decode(SystemStatus.self, from: Data(json!))
            return [statusData]
        } catch {
            showErrorAlert = true
            errorMessage = ("Error: \(error.localizedDescription) Please contact support if this continues.")
            print("\(#function) \(error)")
            return []
        }
    }
}


