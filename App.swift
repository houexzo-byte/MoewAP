import SwiftUI
import UIKit

@main
struct ASTERApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var patchDraftCoordinator = PatchDraftCoordinator()
    @StateObject private var fileOperationCoordinator = FileOperationCoordinator()
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.english.rawValue
    @State private var showOnboarding = OnboardingStore.shouldShow()
    @Environment(\.scenePhase) private var scenePhase
    private var language: AppLanguage { AppLanguage(rawValue: languageCode) ?? .english }
    var body: some Scene { WindowGroup { ZStack { ContentView().environmentObject(appState).environmentObject(patchDraftCoordinator).environmentObject(fileOperationCoordinator).environment(\.appLanguage, language).environment(\.locale, language.locale).opacity(showOnboarding ? 0 : 1).allowsHitTesting(!showOnboarding); if showOnboarding { OnboardingView { OnboardingStore.markCompleted(); withAnimation { showOnboarding = false }; appState.detectSupport() }.environment(\.appLanguage, language).zIndex(1) } }.onAppear { if !showOnboarding { appState.detectSupport() } }.onChange(of: scenePhase) { if $0 == .active && !showOnboarding { appState.detectSupport() } } } }
}
