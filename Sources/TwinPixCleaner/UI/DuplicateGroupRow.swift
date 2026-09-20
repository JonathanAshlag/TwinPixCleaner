import SwiftUI

struct DuplicateGroupRow: View {
    @ObservedObject var viewModel: AppViewModel
    let group: DuplicateGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: AppConstants.Icons.exactMatch) // Changed from square.on.square
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(FrostTheme.Colors.brand)
                
                Text("Duplicate Set")
                    .font(.system(size: 15, weight: .semibold))
                
                Spacer()
                
                HStack(spacing: 16) {
                    Label(ByteCountFormatter.string(fromByteCount: group.fileSize, countStyle: .file), systemImage: AppConstants.Icons.docText)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Label("\(group.fileURLs.count) copies", systemImage: AppConstants.Icons.photoCopies)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        viewModel.selectAllDuplicates(in: group)
                    }) {
                        Label(AppConstants.Strings.selectAllDuplicates, systemImage: AppConstants.Icons.checkmarkCircle)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                    .buttonStyle(.frostPrimary)

                    // "Liked" only exists for Apple Photos library assets, not local-folder scans.
                    if group.fileURLs.first?.scheme == "photos" {
                        if viewModel.hasLikedPhotos(in: group) {
                            Button(action: {
                                viewModel.keepLikedOnly(in: group)
                            }) {
                                Label(AppConstants.Strings.keepLikedOnly, systemImage: AppConstants.Icons.heartFill)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                            }
                            .buttonStyle(.frostPrimary)
                        } else {
                            Label(AppConstants.Strings.noLikedPhotos, systemImage: AppConstants.Icons.heartSlash)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            
            Divider()

            // Images — an adaptive grid so sets reflow to use available window width
            // instead of requiring horizontal scroll, and wrap into rows for larger sets.
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 12)], alignment: .leading, spacing: 12) {
                ForEach(group.fileURLs, id: \.self) { url in
                    DuplicateItemView(
                        url: url,
                        isSelected: viewModel.selectedFiles.contains(url),
                        isLiked: viewModel.isFavorite(url: url),
                        metadata: viewModel.getFileMetadata(url: url),
                        onToggleSelection: { viewModel.toggleSelection(for: url) },
                        onDelete: { viewModel.deleteFile(url: url, in: group) },
                        onKeep: { viewModel.keepOnly(url, in: group) },
                        onPreview: {
                            let idx = group.fileURLs.firstIndex(of: url) ?? 0
                            viewModel.toggleQuickLook(for: group.fileURLs, at: idx)
                        }
                    )
                }
            }
            .padding(16)
        }
        .frostCard(cornerRadius: AppConstants.UI.cardCornerRadius)
    }
}
