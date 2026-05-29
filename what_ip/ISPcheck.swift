//
//  ISPcheck.swift
//  what_ip
//
//  Created by Jesús David Chapman Vélez on 4/05/26.
//

import SwiftUI

struct ISPData: Codable, Sendable {
    let ip: String?
    let ipDecimal: Int?
    let country: String?
    let countryIso: String?
    let regionName: String?
    let regionCode: String?
    let zipCode: String?
    let city: String?
    let latitude: Double?
    let longitude: Double?
    let timeZone: String?
    let asn: String?
    let asnOrg: String?
    let userAgent: UserAgentData?

    enum CodingKeys: String, CodingKey {
        case ip
        case ipDecimal = "ip_decimal"
        case country
        case countryIso = "country_iso"
        case regionName = "region_name"
        case regionCode = "region_code"
        case zipCode = "zip_code"
        case city
        case latitude
        case longitude
        case timeZone = "time_zone"
        case asn
        case asnOrg = "asn_org"
        case userAgent = "user_agent"
    }
}

struct UserAgentData: Codable, Sendable {
    let product: String?
    let version: String?
    let rawValue: String?

    enum CodingKeys: String, CodingKey {
        case product
        case version
        case rawValue = "raw_value"
    }

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        if let container = container {
            product = try? container.decode(String.self, forKey: .product)
            version = try? container.decode(String.self, forKey: .version)
            rawValue = try? container.decode(String.self, forKey: .rawValue)
        } else {
            let singleContainer = try? decoder.singleValueContainer()
            rawValue = try? singleContainer?.decode(String.self)
            product = nil
            version = nil
        }
    }
    
    init(product: String?, version: String?, rawValue: String?) {
        self.product = product
        self.version = version
        self.rawValue = rawValue
    }
}

struct ISPcheck<Background: View>: View {
    let backgroundView: Background
    
    @State private var fetchState: FetchState
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    enum FetchState {
        case loading
        case success(ISPData)
        case error(String)
    }
    
    init(backgroundView: Background, initialState: FetchState = .loading) {
        self.backgroundView = backgroundView
        self._fetchState = State(initialValue: initialState)
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            switch fetchState {
            case .loading:
                loadingView
            case .success(let data):
                successView(data)
            case .error(let error):
                errorView(error)
            }
            
            // Toast Notification Overlay
            if showToast {
                VStack {
                    Spacer()
                    
                    Text(toastMessage)
                        .font(.subheadline.weight(.semibold))
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
        .onAppear {
            if case .loading = fetchState {
                fetchISPInfo()
            }
        }
        .overlay(alignment: .topTrailing) {
            if case .success = fetchState {
                Button {
                    fetchISPInfo()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.glass)
                .glassEffect(.regular.interactive(), in: Circle())
                .clipShape(Circle())
                .padding(.trailing, 20)
                .padding(.top, 20)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Checking connection...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(30)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 18) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 34))
                .foregroundStyle(.red)
            
            Text("Connection check failed")
                .font(.headline.bold())
            
            Text(error)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again", systemImage: "arrow.clockwise") {
                fetchISPInfo()
            }
            .clipShape(Capsule())
            .buttonStyle(.glass)
            .glassEffect(.regular.interactive())
        }
        .padding(30)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30))
        .padding()
    }
    
    private func successView(_ data: ISPData) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                
                // Header Status
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(.tint)
                    
                    Text("Connection Verified")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                    
                    if let ip = data.ip {
                        Text(ip)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 8)
                
                // Dashboard Grid of Tiles
                VStack(spacing: 16) {
                    // 1. IP Address card (full width)
                    if let ip = data.ip {
                        InfoTile(title: String(localized: "IP Address"), value: ip, iconName: "network") {
                            copyToClipboard(ip, fieldName: String(localized: "IP Address"))
                        }
                    }
                    
                    let columns = [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ]
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        // 2. ISP Provider
                        InfoTile(
                            title: String(localized: "ISP Provider"),
                            value: data.asnOrg ?? String(localized: "Unknown"),
                            iconName: "building.2.fill"
                        ) {
                            copyToClipboard(data.asnOrg ?? String(localized: "Unknown"), fieldName: String(localized: "ISP Provider"))
                        }
                        
                        // 3. ASN
                        InfoTile(
                            title: String(localized: "ASN"),
                            value: data.asn ?? String(localized: "Unknown"),
                            iconName: "number"
                        ) {
                            copyToClipboard(data.asn ?? String(localized: "Unknown"), fieldName: String(localized: "ASN"))
                        }
                        
                        // 4. Geographic Location
                        let locationVal = [data.city, data.regionCode, data.countryIso]
                            .compactMap { $0 }
                            .joined(separator: ", ")
                        InfoTile(
                            title: String(localized: "Location"),
                            value: locationVal.isEmpty ? String(localized: "Unknown") : locationVal,
                            iconName: "mappin.and.ellipse"
                        ) {
                            copyToClipboard(locationVal.isEmpty ? String(localized: "Unknown") : locationVal, fieldName: String(localized: "Location"))
                        }
                        
                        // 5. Postal Code
                        InfoTile(
                            title: String(localized: "Postal Code"),
                            value: data.zipCode ?? String(localized: "Unknown"),
                            iconName: "mail.fill"
                        ) {
                            copyToClipboard(data.zipCode ?? String(localized: "Unknown"), fieldName: String(localized: "Postal Code"))
                        }
                        
                        // 6. Coordinates
                        let coordsVal = data.latitude != nil && data.longitude != nil ?
                            "\(data.latitude!), \(data.longitude!)" : String(localized: "Unknown")
                        InfoTile(
                            title: String(localized: "Coordinates"),
                            value: coordsVal,
                            iconName: "location.fill"
                        ) {
                            copyToClipboard(coordsVal, fieldName: String(localized: "Coordinates"))
                        }
                        
                        // 7. Time Zone
                        InfoTile(
                            title: String(localized: "Time Zone"),
                            value: data.timeZone ?? String(localized: "Unknown"),
                            iconName: "clock.fill"
                        ) {
                            copyToClipboard(data.timeZone ?? String(localized: "Unknown"), fieldName: String(localized: "Time Zone"))
                        }
                    }
                    
                    // 8. User Agent
                    if let ua = data.userAgent?.rawValue {
                        InfoTile(title: String(localized: "User Agent"), value: ua, iconName: "safari.fill") {
                            copyToClipboard(ua, fieldName: String(localized: "User Agent"))
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func fetchISPInfo() {
        withAnimation {
            fetchState = .loading
        }
        
        guard let url = URL(string: "https://ifconfig.co/json") else {
            fetchState = .error(String(localized: "Invalid API URL"))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    withAnimation {
                        fetchState = .error(error.localizedDescription)
                    }
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    withAnimation {
                        fetchState = .error(String(localized: "No data received from server"))
                    }
                }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(ISPData.self, from: data)
                DispatchQueue.main.async {
                    withAnimation {
                        fetchState = .success(decoded)
                    }
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    withAnimation {
                        fetchState = .error(String(localized: "Failed to parse connection data"))
                    }
                }
            }
        }.resume()
    }
    
    private func copyToClipboard(_ text: String, fieldName: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif

        #if os(iOS)
        UIPasteboard.general.string = text
        #endif
        
        toastMessage = String(localized: "\(fieldName) copied to clipboard")
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

struct InfoTile: View {
    let title: String
    let value: String
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.tint)
                    
                    Spacer()
                    
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .opacity(0.6)
                }
                
                Text(title.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                
                Text(value)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.01))
            )
            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Loading State") {
    ISPcheck(backgroundView: Color(.systemBackground), initialState: .loading)
}

#Preview("Error State") {
    ISPcheck(backgroundView: Color(.systemBackground), initialState: .error("The request timed out while contacting ifconfig.co"))
}

#Preview("Success State") {
    ISPcheck(
        backgroundView: LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.11, blue: 0.2),
                Color(red: 0.16, green: 0.09, blue: 0.19),
                Color(red: 0.08, green: 0.12, blue: 0.13)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        initialState: .success(
            ISPData(
                ip: "104.28.153.55",
                ipDecimal: 1746704695,
                country: "United States",
                countryIso: "US",
                regionName: "Florida",
                regionCode: "FL",
                zipCode: "33197",
                city: "Miami",
                latitude: 25.7689,
                longitude: -80.1946,
                timeZone: "America/New_York",
                asn: "AS13335",
                asnOrg: "CLOUDFLARENET",
                userAgent: UserAgentData(
                    product: "Safari",
                    version: "17.4",
                    rawValue: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15"
                )
            )
        )
    )
}

