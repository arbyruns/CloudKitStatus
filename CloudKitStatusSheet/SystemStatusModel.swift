//
//  SystemStatusModel.swift
//  Vitae
//
//  Created by robevans on 3/24/22.
//

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

    var systemStatusURL = "https://www.apple.com/support/systemstatus/data/developer/system_status_en_US.js"


    /// Used to fetch the systemStatus of either developer tools and resources or public endpoints.
    /// - Parameter urlType: Use 0 for developer features such as cloudkit, xCode Clouod, etc. Use 1 for system status for public facing sites suchas  Apple Books, App Store, Apple Music, etc
    /// - Returns: Returns system status information
    func fetchSystemStatus(_ urlType: Int) async -> [SystemStatus] {

        switch urlType {

        case 0:
            systemStatusURL = "https://www.apple.com/support/systemstatus/data/developer/system_status_en_US.js" // This is the URL for developer features such as cloudkit, xCode Clouod, etc
        default:
            systemStatusURL = "https://www.apple.com/support/systemstatus/data/system_status_en_US.js" // this is the URL for system status for public facing sites suchas   Apple Books, App Store, Apple Music, etc

        }

        guard let url = URL(string: systemStatusURL) else {
            return []
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("\(#function) \(response)")
                return []
            }

            /* The developer URL returns jsonCallback( and ends with )
             so the return payload needs to have that removed before use
             */
            if urlType == 0 {
                var dataString = String(data: data, encoding: .utf8)
                dataString = dataString?.replacingOccurrences(of: "jsonCallback(", with: "")
                dataString = dataString?.replacingOccurrences(of: ");", with: "")
                let json = dataString?.data(using: .utf8)
                let statusData = try JSONDecoder().decode(SystemStatus.self, from: Data(json!))
                return [statusData]
            }

            let statusData = try JSONDecoder().decode(SystemStatus.self, from: data)
            return [statusData]
        } catch {
            showErrorAlert = true
            errorMessage = ("Error: \(error.localizedDescription)")
            print("\(#function) \(error)")
            return []
        }
    }
}


