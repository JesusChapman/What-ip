//
//  ContentView.swift
//  what_ip
//
//  Created by Jesús David Chapman Vélez on 11/04/26.
//


import SwiftUI

nonisolated struct IPResponse: Codable, Sendable {
    let ip: String
}

enum AppTab: Int, CaseIterable {
    case home
    case ispcheck
    case about

    var title: String {
        switch self {
        case .home: String(localized: "IP check")
        case .ispcheck: String(localized: "ISP Check")
        case .about: String(localized: "About")
        }
    }

    var icon: String {
        switch self {
        case .home: "network"
        case .ispcheck: "checkmark.seal"
        case .about: "info.circle"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @AppStorage("selectedIcon") private var selectedIcon: String = "location.fill"
    @State private var ipAddress: String = ""
    @State private var showCopyButton: Bool = false
    @State private var showToast: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.home.title, systemImage: AppTab.home.icon, value: AppTab.home) {
                homeView
            }

            Tab(AppTab.ispcheck.title, systemImage: AppTab.ispcheck.icon, value: AppTab.ispcheck) {
                ISPcheck(backgroundView: backgroundView)
            }

            Tab(AppTab.about.title, systemImage: AppTab.about.icon, value: AppTab.about) {
                AboutView(backgroundView: backgroundView)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .defaultAdaptableTabBarPlacement(.tabBar)
    }

    private var homeView: some View {
        ZStack {
            backgroundView

            VStack {
                Spacer()

                VStack(spacing: 18) {
                    Image(systemName: selectedIcon)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.tint)
                        .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))

                    Text(ipAddress.isEmpty ? String(localized: "ip.placeholder") : ipAddress)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    Button("Get my ip", systemImage: "network") {
                        fetchIP()
                    }
                    .clipShape(Capsule())
                    .buttonStyle(.glass)
                    .glassEffect(.regular.interactive())

                    if showCopyButton {
                        Button {
                            copyToClipboard()
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        .clipShape(Capsule())
                        .buttonStyle(.glassProminent)
                        .glassEffect(.regular.interactive())
                    }
                }
                .padding(30)
                .glassEffect(.regular, in: .rect(cornerRadius: 30))
                .padding()

                Spacer()
            }

            // Toast dentro del mismo ZStack (FIX del error)
            if showToast {
                VStack {
                    Spacer()

                    Text("Content copied to clipboard")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(radius: 10)
                        .scaleEffect(showToast ? 1 : 0.85)
                        .opacity(showToast ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showToast)
                        .padding(.bottom, 30)
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.85).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .overlay(alignment: .topTrailing) {
            Menu {

                Picker("Icon", selection: $selectedIcon) {
                    
                    Label("Location icon", systemImage: "location")
                        .tag("location")

                    Label("iPhone location icon", systemImage: "iphone")
                        .tag("iphone.badge.location")

                    Label("WiFi router icon", systemImage: "wifi.router")
                        .tag("wifi.router")
                }

            } label: {

                Image(systemName: "ellipsis")

                    .font(.system(size: 20, weight: .bold))

                    .frame(width: 40, height: 40)

            }
            .buttonStyle(.glass)
            .glassEffect(.regular.interactive(), in: Circle())
            .clipShape(Circle())
            .padding(.trailing, 20)
            .padding(.top, 20)
        }
    }

    private var backgroundView: some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.11, blue: 0.2),
                        Color(red: 0.16, green: 0.09, blue: 0.19),
                        Color(red: 0.08, green: 0.12, blue: 0.13)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.70, green: 0.75, blue: 0.90),
                        Color(red: 0.80, green: 0.70, blue: 0.85),
                        Color(red: 0.75, green: 0.85, blue: 0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .ignoresSafeArea()
    }

    func fetchIP() {
        guard let url = URL(string: "https://ifconfig.co/json") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            let decoded = try? JSONDecoder().decode(IPResponse.self, from: data)

            let ip = decoded?.ip

            DispatchQueue.main.async {
                if let ip {
                    ipAddress = ip
                    showCopyButton = true
                } else {
                    ipAddress = String(localized: "Error getting IP")
                }
            }
        }.resume()
    }

    func copyToClipboard() {
        #if os(macOS)
        NSPasteboard.general.setString(ipAddress, forType: .string)
        #endif

        #if os(iOS)
        UIPasteboard.general.string = ipAddress
        #endif

        withAnimation {
            showToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
}

#Preview {
    ContentView()
}
