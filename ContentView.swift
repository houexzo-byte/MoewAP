import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var patchDraftCoordinator: PatchDraftCoordinator
    @State private var tabNavigation = AppTabNavigationState()

    var body: some View {
        TabView(selection: Binding(get: { tabNavigation.selectedTab }, set: { tabNavigation.select($0) })) {
            AppDataBrowserView(tabSession: Binding(get: { tabNavigation.filesTabs }, set: { tabNavigation.setFilesTabs($0) }))
                .tabItem { Label(language.text("tab.files"), systemImage: "folder.fill") }
                .tag(AppSection.files.rawValue)
            ASTERPatchScreen()
                .tabItem { Label(language.text("tab.patches"), systemImage: "shippingbox.fill") }
                .tag(AppSection.patches.rawValue)
        }
        .tint(ASTERTheme.accent)
        .background(ASTERTheme.background.ignoresSafeArea())
        .onChange(of: patchDraftCoordinator.request?.id) { _ in tabNavigation.select(AppSection.patches.rawValue) }
        .onChange(of: patchDraftCoordinator.importRequest?.id) { _ in tabNavigation.select(AppSection.patches.rawValue) }
    }
}

enum ASTERTheme {
    static let accent = Color(red: 0.35, green: 0.82, blue: 1.0)
    static let background = Color(red: 0.035, green: 0.045, blue: 0.10)
}

struct ASTERGlassCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content.padding(18).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(LinearGradient(colors: [ASTERTheme.accent.opacity(0.75), .white.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
            .shadow(color: ASTERTheme.accent.opacity(0.18), radius: 18)
    }
}

struct ASTERPatchScreen: View {
    @State private var showDeviceInfo = false
    var body: some View {
        NavigationStack {
            ZStack {
                ASTERTheme.background.ignoresSafeArea()
                ScrollView { VStack(alignment: .leading, spacing: 18) {
                    Text("Patches").font(.largeTitle.bold()).foregroundStyle(.white)
                    ASTERGlassCard { VStack(alignment: .leading, spacing: 8) { Text("ASTER workspace").font(.title3.bold()); Text("Create and manage device patches").foregroundStyle(.secondary) } }
                }.padding() }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button { showDeviceInfo = true } label: { Image(systemName: "gearshape.fill") }.accessibilityLabel("Device information") } }
            .sheet(isPresented: $showDeviceInfo) { ASTERDeviceInfoModal() }
        }
    }
}

struct ASTERDeviceInfoModal: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack { ZStack { ASTERTheme.background.ignoresSafeArea(); VStack(spacing: 14) {
            ASTERGlassCard { VStack(spacing: 16) {
                ASTERInfoRow(title: "Hardware model", value: AppInfo.displayMachineName)
                ASTERInfoRow(title: "iOS Version", value: AppInfo.osVersion)
                ASTERInfoRow(title: "Compatibility", badge: "Supported")
                ASTERInfoRow(title: "Kernel status", badge: "Active")
            } }.padding()
        } }.navigationTitle("Device Info").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } } }
    }
}
private struct ASTERInfoRow: View {
    let title: String; var value: String? = nil; var badge: String? = nil
    var body: some View { HStack { Text(title).foregroundStyle(.white); Spacer(); if let value { Text(value).font(.body.monospaced()).foregroundStyle(.secondary) }; if let badge { Text(badge).font(.caption.bold()).foregroundStyle(.green).padding(.horizontal, 10).padding(.vertical, 5).background(.green.opacity(0.14), in: Capsule()) } } }
}
