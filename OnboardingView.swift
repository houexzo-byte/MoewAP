import SwiftUI

struct OnboardingView: View {
    @Environment(\.appLanguage) private var currentLanguage
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.english.rawValue
    @State private var step = 0
    let onComplete: () -> Void
    private let steps = 4
    var body: some View { ZStack { ASTERTheme.background.ignoresSafeArea(); VStack(spacing: 24) { HStack { Text("ASTER").font(.headline.bold()).foregroundStyle(ASTERTheme.accent); Spacer(); Text("\(step + 1)/\(steps)").foregroundStyle(.secondary) }.padding(.horizontal); Spacer(); ASTERGlassCard { VStack(spacing: 18) { if step == 0 { Text("Choose language").font(.title.bold()); ForEach(AppLanguage.allCases) { language in Button { languageCode = language.rawValue } label: { HStack { Text(language.displayName); Spacer(); if language.rawValue == languageCode { Image(systemName: "checkmark.circle.fill").foregroundStyle(ASTERTheme.accent) } }.padding() }.buttonStyle(.plain) } } else if step == 1 { Text("Welcome to ASTER").font(.title.bold()); Text("developed by HourJiro").foregroundStyle(.secondary) } else if step == 2 { Text("Supported iOS versions").font(.title.bold()); Text("The supported iOS versions remain the same as the original application.").multilineTextAlignment(.center).foregroundStyle(.secondary) } else { Text("Certificate requirements").font(.title.bold()); Text("An enterprise certificate such as eSign is required. SideStore, AltStore, and similar services are not supported.").multilineTextAlignment(.center).foregroundStyle(.secondary) } }.frame(maxWidth: .infinity) }.padding(); Spacer(); Button(step == steps - 1 ? "Get Started" : "Continue") { if step == steps - 1 { onComplete() } else { withAnimation(.spring) { step += 1 } } }.buttonStyle(.borderedProminent).tint(ASTERTheme.accent).padding(.bottom) }.padding(.top) } }
}

enum OnboardingStore { static let key = "aster.onboarding.completed"; static func shouldShow() -> Bool { !UserDefaults.standard.bool(forKey: key) }; static func markCompleted() { UserDefaults.standard.set(true, forKey: key) } }
