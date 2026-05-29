//
//  AboutView.swift
//  what_ip
//
//  Created by Jesús David Chapman Vélez on 11/04/26.
//


import SwiftUI

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ConditionalScrollView<Content: View>: View {
    let content: Content
    
    @State private var contentHeight: CGFloat = 0
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: false) {
                content
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: HeightPreferenceKey.self, value: proxy.size.height)
                        }
                    )
            }
            .scrollDisabled(contentHeight <= geo.size.height)
            .onPreferenceChange(HeightPreferenceKey.self) { height in
                contentHeight = height
            }
        }
    }
}

struct LicenseSection: View {
    @State private var isExpanded: Bool = false
    let licenseText: String?
    
    var body: some View {
        VStack(spacing: 16) {
            if !isExpanded {

                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.04))
                            .frame(width: 36, height: 36)
                            .glassEffect(.regular, in: Circle())
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.12), lineWidth: 1)
                            )
                        
                        Image(systemName: "scroll.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.tint)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Image(systemName: "key.2.on.ring")
                                .font(.system(size: 10))
                                .foregroundStyle(.tint)
                            
                            Text("LICENSE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.secondary)
                                .tracking(0.8)
                        }
                        
                        Text("GNU General Public License v3")
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    Button {
                        openGitHub()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.04))
                            Image(systemName: "greaterthanorequalto.square.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.tint)
                        }
                        .frame(width: 36, height: 36)
                        .contentShape(Circle())
                        .glassEffect(.regular.interactive(), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .opacity(0.9)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity.combined(with: .move(edge: .top)))
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.green)
                            .padding(.top, 1)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Permissions")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.primary)
                            Text("Commercial use, modification, distribution, and patent use.")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Divider()
                        .background(.white.opacity(0.08))
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.orange)
                            .padding(.top, 1)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Conditions & Limitations")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.primary)
                            Text("Source disclosure, copyright notice, copyleft (same GPLv3 license), and no warranty.")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.white.opacity(0.05), lineWidth: 1)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                HStack {
                    Image(systemName: "gavel.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.tint)
                    
                    Text("GNU GENERAL PUBLIC LICENSE v3")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .tracking(1.0)
                    
                    Spacer()
                }
                .padding(.bottom, 4)
                .transition(.opacity)
                
                ScrollView(.vertical) {
                    if let text = licenseText {
                        let formattedText = formatLicenseTextToMarkdown(text)
                        Text(LocalizedStringKey(formattedText))
                            .font(.system(size: 9.5, design: .monospaced))
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("Failed to load LICENSE file.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
                .frame(height: 380)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black.opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(isExpanded ? "Hide Full License Details" : "Show Full License Details")
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.white.opacity(0.02))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.03), .white.opacity(0.005)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .glassEffect(.regular.tint(.white.opacity(0.02)), in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

struct AboutView<Background: View>: View {
    let backgroundView: Background

    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView(.vertical , showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer(minLength: 30)
                
                    ZStack {
                        Image("AppIconRender")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 125, height: 125)
                            .shadow(color: .blue.opacity(0.2), radius: 6)
                    }
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 36))
                    .padding(.bottom, 4)
                    
                    VStack(spacing: 6) {
                        Text("What IP")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("Version 0.0.1-dev-preview")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.05))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                            )
                        
                        Text("Discover your connection details in real-time.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 4)
                    }
                    
                    Spacer(minLength: 5)
                    
                    LicenseSection(licenseText: loadLicenseText())
                    
                    VStack(spacing: 16) {
                        Text("AUTHORS")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(0.8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 14) {
           
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.04))
                                    .frame(width: 44, height: 44)
                                    .glassEffect(.regular, in: Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.15), lineWidth: 1)
                                    )
                                
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.tint)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Jesús David Chapman Vélez")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.primary)
                                
                                Text("Lead Developer")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                sendMail()
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(width: 36, height: 36)
                            }
                            .buttonStyle(.glass)
                            .glassEffect(.regular.interactive(), in: Circle())
                            .clipShape(Circle())
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.03), .white.opacity(0.005)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .glassEffect(.regular.tint(.white.opacity(0.02)), in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

func sendMail() {
    if let url = URL(string: "mailto:jesuschapmandev@outlook.com") {
        UIApplication.shared.open(url)
    }
}

func openGitHub() {
    if let url = URL(string: "https://github.com/JesusChapman/wallpaper-downloader") {
        UIApplication.shared.open(url)
    }
}

func loadLicenseText() -> String? {
    guard let url = Bundle.main.url(forResource: "LICENSE", withExtension: nil) else {
        return nil
    }
    return try? String(contentsOf: url, encoding: .utf8)
}

func formatLicenseTextToMarkdown(_ rawText: String) -> String {
    let lines = rawText.components(separatedBy: .newlines)
    var formattedLines: [String] = []
    
    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            formattedLines.append("")
            continue
        }
        
        if trimmed == trimmed.uppercased() && trimmed.count > 3 && !trimmed.contains("COPYRIGHT") && !trimmed.contains("HTTP") && !trimmed.contains("FOUNDATION") {
            formattedLines.append("\n### **\(trimmed)**\n")
        }
  
        else if trimmed.range(of: #"^\d+\.\s+\w+"#, options: .regularExpression) != nil {
            formattedLines.append("\n**\(trimmed)**\n")
        }

        else if trimmed == "Preamble" || trimmed.hasPrefix("How to Apply These Terms") {
            formattedLines.append("\n### **\(trimmed)**\n")
        }
        else {
            formattedLines.append(line)
        }
    }
    
    return formattedLines.joined(separator: "\n")
}

#Preview {
    AboutView(
        backgroundView: LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.11, blue: 0.2),
                Color(red: 0.16, green: 0.09, blue: 0.19),
                Color(red: 0.08, green: 0.12, blue: 0.13)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
