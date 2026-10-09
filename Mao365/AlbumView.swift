import SwiftUI
import UIKit

private let paperColor = Color(red: 0.984, green: 0.973, blue: 0.949)
private let inkColor = Color(red: 0.22, green: 0.24, blue: 0.23)
private let warmAccent = Color(red: 0.57, green: 0.35, blue: 0.23)
private let illustrationAspectRatio: CGFloat = 9.0 / 16.0

struct AlbumView: View {
    @ObservedObject var album: AlbumStore
    @State private var selectedDay: Int
    @State private var isChoosingDay = false
    @State private var detailDesign: DayDesign?
    @ScaledMetric(relativeTo: .caption) private var captionHeight: CGFloat = 86
    @ScaledMetric(relativeTo: .caption) private var descriptionHeight: CGFloat = 36
    @ScaledMetric(relativeTo: .caption) private var descriptionFontSize: CGFloat = 13
    @ScaledMetric(relativeTo: .subheadline) private var regionFontSize: CGFloat = 13

    init(album: AlbumStore) {
        self.album = album
        let arguments = ProcessInfo.processInfo.arguments
        let initialDay = arguments.firstIndex(of: "--day")
            .flatMap { index in arguments.indices.contains(index + 1) ? Int(arguments[index + 1]) : nil }
        _selectedDay = State(initialValue: min(max(initialDay ?? 1, 1), 365))
    }

    private var currentDesign: DayDesign? {
        album.designs.first { $0.day == selectedDay }
    }

    var body: some View {
        Group {
            if let design = currentDesign {
                GeometryReader { geometry in
                    // Every page shares the same viewport. Text must not resize the artwork.
                    let footerHeight = captionHeight
                    let pictureHeight = max(1, geometry.size.height - footerHeight)
                    VStack(spacing: 0) {
                        TabView(selection: $selectedDay) {
                            ForEach(album.designs) { item in
                                DayIllustration(design: item)
                                    .tag(item.day)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(width: geometry.size.width, height: pictureHeight)
                        .accessibilityIdentifier("album.pager")

                        caption(for: design)
                            .frame(width: geometry.size.width, height: footerHeight)
                    }
                }
                .background(paperColor)
                .sheet(isPresented: $isChoosingDay) {
                    DayPicker(designs: album.designs, selectedDay: $selectedDay)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
                .sheet(item: $detailDesign) { item in
                    SceneDetail(design: item)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            } else {
                ContentUnavailableView(
                    "画册暂时无法打开",
                    systemImage: "book.closed",
                    description: Text(album.errorMessage ?? "请稍后再试。")
                )
            }
        }
        .background(paperColor.ignoresSafeArea())
        .statusBarHidden(true)
    }

    private func caption(for design: DayDesign) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 13) {
                Button {
                    isChoosingDay = true
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("DAY")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(1.3)
                        Text(String(format: "%02d", design.day))
                            .font(.system(size: 21, weight: .regular, design: .serif))
                            .monospacedDigit()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundStyle(warmAccent.opacity(0.55))
                    }
                    .foregroundStyle(warmAccent)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("album.dayPicker")
                .accessibilityLabel("Day \(design.day)，选择日期")

                Text(design.regionDisplay)
                    .font(.system(size: regionFontSize, weight: .medium))
                    .foregroundStyle(inkColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .accessibilityIdentifier("album.region")
                Spacer(minLength: 0)
            }

            Text(design.scene)
                .font(.system(size: descriptionFontSize))
                .foregroundStyle(inkColor.opacity(0.68))
                .lineSpacing(3)
                .lineLimit(2)
                .frame(height: descriptionHeight, alignment: .topLeading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture { detailDesign = design }
                .accessibilityLabel(design.scene)
                .accessibilityHint("轻点查看完整描述")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("album.description")
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(paperColor)
    }
}

private struct DayIllustration: View {
    let design: DayDesign

    var body: some View {
        GeometryReader { geometry in
            let imageWidth = min(geometry.size.width, geometry.size.height * illustrationAspectRatio)
            let imageHeight = imageWidth / illustrationAspectRatio
            Group {
                if let image = UIImage(named: design.id) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidth, height: imageHeight)
                        .accessibilityLabel("Day \(design.day) · \(design.region) · \(design.scene)")
                        .accessibilityIdentifier("album.image.\(design.id)")
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 28, weight: .ultraLight))
                        Text("这一天的画面，正在准备")
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(inkColor.opacity(0.35))
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("album.placeholder.\(design.id)")
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(paperColor)
        }
    }
}

private struct SceneDetail: View {
    let design: DayDesign
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(design.regionDisplay)
                        .font(.title3.weight(.medium))
                    Text(design.scene)
                        .font(.body)
                        .lineSpacing(6)
                        .accessibilityIdentifier("album.fullDescription")
                }
                .foregroundStyle(inkColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            .background(paperColor)
            .navigationTitle("Day \(design.day)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .tint(warmAccent)
    }
}

private struct DayPicker: View {
    let designs: [DayDesign]
    @Binding var selectedDay: Int
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    private var matchingDays: [DayDesign] {
        designs.filter { $0.matches(search.trimmingCharacters(in: .whitespacesAndNewlines)) }
    }

    var body: some View {
        NavigationStack {
            List(matchingDays) { design in
                Button {
                    selectedDay = design.day
                    dismiss()
                } label: {
                    HStack(spacing: 14) {
                        Text("\(design.day)")
                            .font(.system(.body, design: .rounded).weight(.medium))
                            .monospacedDigit()
                            .foregroundStyle(inkColor)
                            .frame(width: 40, alignment: .leading)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(design.regionDisplay)
                                .font(.subheadline)
                                .foregroundStyle(inkColor)
                            Text(design.date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if selectedDay == design.day {
                            Image(systemName: "checkmark")
                                .foregroundStyle(inkColor)
                        }
                    }
                }
                .accessibilityIdentifier("day.select.\(design.id)")
            }
            .navigationTitle("选择一天")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $search, prompt: "Day、日期或省市")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .tint(inkColor)
    }
}

#Preview {
    AlbumView(album: AlbumStore())
}
