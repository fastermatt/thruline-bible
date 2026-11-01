import SwiftUI

/// A resource access map, using the existing translation manager for installation.
/// It reads only bundled catalogue metadata and the library's current translation scan.
struct ResourceCenterView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        ResourceCenterContent(library: state.library, includesHCF: state.studyResources.registry["hcf"] != nil)
    }
}

private struct ResourceCenterContent: View {
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var library: ScriptureLibrary
    let includesHCF: Bool

    var body: some View {
        Form {
            Section {
                Text("Your study library").font(.title3.weight(.semibold))
                Button("Open Library & downloads") { openWindow(id: "resource-library") }
                Text(ResourceCatalog.coreAccessSummary)
                    .font(.callout).foregroundStyle(.secondary)
                Label(includesHCF ? "Fathers extracts are present under mixed rights; see Rights review below." : "Fathers extracts are withheld from this build pending rights review.",
                      systemImage: "exclamationmark.triangle")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Your own AI") {
                Text("Connect a local or hosted model in the AI panel, or let your AI tool call Thruline’s read-only CLI. Core Bible study still works without AI.")
                Button("Open AI panel & CLI setup") { openWindow(id: "ai-assistant") }
            }
            Section(ResourceAccessGroup.included.rawValue) {
                ForEach(ResourceCatalog.resources(in: .included)) { resource in
                    resourceRow(resource)
                    if resource.id == "scripture" {
                        ForEach(["BSB", "KJV", "WEB"], id: \.self) { id in
                            bibleStatus(id: id, title: id)
                        }
                    }
                }
            }

            Section(ResourceAccessGroup.downloads.rawValue) {
                ForEach(ResourceCatalog.resources(in: .downloads)) { resource in
                    resourceRow(resource)
                    if resource.id == "tyndale" || resource.id == "commentary-packs" {
                        Button("Add free study resources") { openWindow(id: "add-resources") }
                    } else if resource.id == "offline-bibles" {
                        ForEach(BibleDownload.catalog) { edition in
                            bibleStatus(id: edition.id, title: "\(edition.id) · \(edition.language)")
                            DarbyComparisonNotice(translationID: edition.id)
                        }
                        Button("Manage Bible downloads") {
                            SettingsOpener.shared.destination = .translations
                        }
                    } else if resource.id == "historic-works" {
                        Text("\(HistoricWork.catalog.count) optional works. Open Library → Fathers & reception or Free study resources to add one.")
                            .font(.callout)
                        Button("Open the Library") { openWindow(id: "add-resources") }
                    } else if resource.id == "tcp-reading" {
                        if let count = ResourceCatalog.readingWorkCount {
                            Text("\(count) work and volume entries in this catalogue.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Text("Open Library → Historic works to find, download and read a work.")
                            .font(.callout)
                    }
                }
            }

            Section(ResourceAccessGroup.ownAccount.rawValue) {
                ForEach(ResourceCatalog.resources(in: .ownAccount)) { resource in
                    resourceRow(resource)
                }
                ForEach(library.translations.filter { $0.delivery == .installedPack && !BibleDownload.catalog.map(\.id).contains($0.id) }) { translation in
                    Label("\(translation.id) · Installed offline pack", systemImage: "checkmark.circle")
                        .font(.caption)
                }
                Button("Open translation settings") {
                    SettingsOpener.shared.destination = .translations
                }
                Text("Publisher keys belong to you and are stored in your macOS Keychain. They are not supplied by Thruline.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section(ResourceAccessGroup.rightsReview.rawValue) {
                ForEach(ResourceCatalog.resources(in: .rightsReview, includesHCF: includesHCF)) { resource in
                    resourceRow(resource, needsReview: true)
                }
                Text("Study access and redistribution permission are different. A free download, ancient author or source link alone does not establish permission to republish a translation.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private func resourceRow(_ resource: StudyResourceInfo, needsReview: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if needsReview {
                Label(resource.title, systemImage: "exclamationmark.triangle")
                    .font(.headline)
            } else {
                Text(resource.title).font(.headline)
            }
            Text(resource.detail).font(.callout).fixedSize(horizontal: false, vertical: true)
            Text(resource.rights).font(.caption).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Link(needsReview ? "Read upstream rights notice" : "Source and terms", destination: resource.sourceURL)
                .font(.caption)
        }
        .padding(.vertical, 5)
        .textSelection(.enabled)
    }

    private func bibleStatus(id: String, title: String) -> some View {
        let availability = ResourceCatalog.availability(of: id, in: library.translations)
        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title).font(.caption.weight(.medium))
            Spacer(minLength: 8)
            Label(availability.label, systemImage: availability.symbol).font(.caption)
        }
        .accessibilityElement(children: .combine)
    }
}
