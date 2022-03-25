//
//  SystemStatusView.swift
//  Vitae
//
//  Created by robevans on 3/24/22.
//

import SwiftUI

struct SystemStatusView: View {
    
    @StateObject var systemStatus = SystemStatusModel()

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("Background").opacity(0.5), Color("Background")]), startPoint: .bottom, endPoint: .top)
                    .edgesIgnoringSafeArea(.all)
                GeometryReader { geo in
                    ScrollView {
                        VStack {
                            Divider()
                                .padding(.horizontal)
                            ForEach(systemStatus.systemStatusData.first?.services ?? []) { status in
                                // update "Cloud" with desired information
                                if status.serviceName.contains("Cloud") {
                                    CloudKitStatusCardView(geo: geo, status: status)
                                }
                            }
                            Spacer()
                        }
                        .task {
                            systemStatus.systemStatusData = await systemStatus.fetchSystemStatus(0)
                    }
                    }
                }
            }
            .navigationBarTitle("CloudKit Status")
        }
    }
}

struct SystemStatusView_Previews: PreviewProvider {
    static var previews: some View {
        SystemStatusView()
        SystemStatusView()
            .colorScheme(.dark)
    }
}

struct CloudKitStatusCardView: View {

    let geo: GeometryProxy
    let status: Service
    let circleSize: CGFloat = 50

    @State var isAnimating = false


    var body: some View {
        
        VStack {
            let frame = geo.frame(in: CoordinateSpace.local)
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color("StatusCard"))
                    .padding(.horizontal)
                    .shadow(radius: 6)
                Circle()
                    .fill(Color("StatusCard"))
                    .background(
                        Circle()
                            .stroke(Color("StatusCard"), lineWidth: 2)
                            .background(
                                Circle()
                                    .fill(Color.blue)
                            )
                    )
                    .frame(width: circleSize, height: circleSize, alignment: .center)
                    .shadow(radius: 12)
                    .overlay(
                        VStack {
                            if status.events.count > 0 {
                                Image(systemName: "exclamationmark.icloud.fill")
                                    .font(.system(size: 29))
                                    .foregroundColor(Color("nord11"))
                                    .scaleEffect(self.isAnimating ? 1.2: 0.8)
                                    .animation(Animation.easeInOut(duration: 0.5).delay(0.5).repeatForever())
                                    .onAppear {
                                        self.isAnimating = true
                                    }
                            } else {
                                Image(systemName: "checkmark.icloud.fill")
                                    .font(.system(size: 29))
                                    .foregroundColor(Color("nord13"))
                            }
                        }
                    )
                    .offset(y: frame.origin.y - circleSize / 2)

                HStack {
                    VStack(alignment: .center) {
                        Text(status.serviceName)
                            .fontWeight(.semibold)
                        HStack {
                            Spacer()
                            Text("Last Update:")
                                .font(.subheadline)
                                .fontWeight(.thin)
                            Text(formatDate(date: Date()))
                                .font(.subheadline)
                                .fontWeight(.thin)
                                .padding(.top, 3)
                            Spacer()
                        }
                        if status.events.count > 0 {
                            Divider()
                                .padding(.horizontal, 20)
                            ForEach(status.events) { event in
                                VStack {
                                    ImpactedStatusView(string: "Type:", status: event.statusType)
                                    ImpactedStatusView(string: "Users Affected:", status: event.usersAffected)
                                    ImpactedStatusView(string: "Start Date:", status: event.startDate)
                                    ImpactedStatusView(string: "End Date:", status: event.endDate)
                                    ImpactedStatusView(string: "Event Status:", status: event.eventStatus)
                                    ImpactedStatusView(string: "Message:", status: event.message)
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    .padding(.top, 18)
                }
                .padding(.vertical)
                .padding(.horizontal, 26)
            }
        }
        .padding(.vertical, circleSize / 2)
    }
}


struct ImpactedStatusView: View {
    let string: String
    let status: String
    var body: some View {
        HStack {
            Text(string)
            Spacer()
            Text(status)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.vertical, 0.04)
        .padding(.horizontal, 25)
    }
}


func formatDate(date: Date) -> String {
    let date = date
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    let dayOfTheWeekString = dateFormatter.string(from: date)
    return dayOfTheWeekString
}
