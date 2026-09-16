import Foundation

enum AppSection: Int, CaseIterable, Identifiable {
    case home
    case files
    case patches
    case cleaner
    case wallpapers

    var id: Int { rawValue }
}

enum WallpaperFeatureSupportPolicy {
    static func isSupported(major: Int) -> Bool { [17, 18, 26, 27].contains(major) }
}

struct FeatureVisibility: Equatable {
    static let cleanerStorageKey = "feature.cleaner.enabled"
    static let wallpapersStorageKey = "feature.wallpapers.enabled"
    let cleanerEnabled: Bool
    let wallpapersEnabled: Bool
    let wallpapersSupported: Bool

    init(cleanerEnabled: Bool = false, wallpapersEnabled: Bool = false, wallpapersSupported: Bool = true) {
        self.cleanerEnabled = cleanerEnabled
        self.wallpapersEnabled = wallpapersEnabled
        self.wallpapersSupported = wallpapersSupported
    }

    // Cleaner, Wallpapers, and Home remain in the project but are intentionally not exposed.
    var visibleSections: [AppSection] { [.files, .patches] }
    func isVisible(_ section: AppSection) -> Bool { visibleSections.contains(section) }
}

struct AppTabNavigationState: Equatable {
    private(set) var selectedTab: Int
    private(set) var filesTabs: FilesTabSession
    init(selectedTab: Int = AppSection.files.rawValue, filesNavigationPath: [FileBrowserDestination] = []) {
        self.selectedTab = selectedTab
        var session = FilesTabSession()
        session.setActiveNavigationPath(filesNavigationPath)
        filesTabs = session
    }
    mutating func select(_ tab: Int) { selectedTab = tab }
    mutating func setFilesNavigationPath(_ path: [FileBrowserDestination]) { filesTabs.setActiveNavigationPath(path) }
    var filesNavigationPath: [FileBrowserDestination] { filesTabs.activeTab?.navigationPath ?? [] }
    mutating func setFilesTabs(_ session: FilesTabSession) { filesTabs = session }
    mutating func reconcileSelection(with visibility: FeatureVisibility) {
        if !visibility.isVisible(AppSection(rawValue: selectedTab) ?? .files) { selectedTab = AppSection.files.rawValue }
    }
}

struct FileBrowserDestination: Hashable { let containerPath: String; let startPath: String; let title: String; let bundleID: String? }
struct FilesTabState: Identifiable, Equatable {
    let id: UUID
    var customTitle: String?
    var navigationPath: [FileBrowserDestination]
    func displayTitle(defaultTitle: String) -> String { customTitle ?? navigationPath.last?.title ?? defaultTitle }
    var currentPath: String? { navigationPath.last?.startPath }
}
struct FilesTabSession: Equatable {
    private(set) var tabs: [FilesTabState]
    private(set) var selectedTabID: UUID
    init(initialTabID: UUID = UUID()) { tabs = [FilesTabState(id: initialTabID, customTitle: nil, navigationPath: [])]; selectedTabID = initialTabID }
    var activeTab: FilesTabState? { tabs.first { $0.id == selectedTabID } }
    mutating func setActiveNavigationPath(_ path: [FileBrowserDestination]) { guard let i = tabs.firstIndex(where: { $0.id == selectedTabID }) else { return }; tabs[i].navigationPath = path }
    mutating func openTab(id: UUID = UUID(), navigationPath: [FileBrowserDestination] = []) { tabs.append(FilesTabState(id: id, customTitle: nil, navigationPath: navigationPath)); selectedTabID = id }
    mutating func selectTab(_ id: UUID) { if tabs.contains(where: { $0.id == id }) { selectedTabID = id } }
    mutating func renameTab(_ id: UUID, to name: String) { guard let i = tabs.firstIndex(where: { $0.id == id }) else { return }; let value = name.trimmingCharacters(in: .whitespacesAndNewlines); tabs[i].customTitle = value.isEmpty ? nil : value }
    mutating func closeTab(_ id: UUID, replacementID: UUID = UUID()) { guard let i = tabs.firstIndex(where: { $0.id == id }) else { return }; if tabs.count == 1 { tabs = [FilesTabState(id: replacementID, customTitle: nil, navigationPath: [])]; selectedTabID = replacementID } else { tabs.remove(at: i); if selectedTabID == id { selectedTabID = tabs[min(i, tabs.count - 1)].id } } }
    mutating func closeOtherTabs(keeping id: UUID) { guard let tab = tabs.first(where: { $0.id == id }) else { return }; tabs = [tab]; selectedTabID = id }
}
