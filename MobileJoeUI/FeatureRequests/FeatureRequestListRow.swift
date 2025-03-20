import SwiftUI
import MobileJoe

struct FeatureRequestListRow: View {
  let feature: MobileJoe.FeatureRequest
  let vote: (MobileJoe.FeatureRequest) -> Void
  
  var body: some View {
    HStack(spacing: 6) {
      VStack(alignment: .leading, spacing: 6) {
        Text(feature.title)
          .fontWeight(.medium)
        Text(feature.body)
          .lineLimit(2)
          .font(.callout)
          .foregroundStyle(.secondary)
        
        Status()
      }
      
      Spacer()
      VoteButton()
    }
    .padding(.vertical, 8)
    .frame(maxWidth: .infinity)
  }
}

extension FeatureRequestListRow {
  func VoteButton() -> some View {
    Button {
      vote(feature)
    } label: {
      VStack(spacing: 4) {
        Image(systemName: "chevron.up")
          .font(.caption)
        Text(verbatim: "\(feature.score)")
          .lineLimit(1)
          .minimumScaleFactor(0.5)
      }
      .foregroundStyle(foregroundColor)
      .frame(maxWidth: 32)
      .padding(8)
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .stroke(strokeColor, lineWidth: 1)
          .fill(backgroundColor)
      )
    }
    .buttonStyle(.plain)
  }
  
  func Status() -> some View {
    HStack(spacing: 4) {
      Circle()
        .frame(width: 6)
      
      Text(feature.status.localizedCapitalized)
        .font(.caption)
        .fontWeight(.medium)
    }
    .foregroundStyle(feature.statusColor)
    .padding(.vertical, 2)
    .padding(.horizontal, 6)
    .background(feature.statusColor.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    .padding(.top, 6)
  }
}

extension FeatureRequestListRow {
  private var backgroundColor: Color {
    feature.isVoted ? .accentColor.opacity(0.1) : .clear
  }
  
  private var strokeColor: Color {
    feature.isVoted ? .accentColor : .secondary
  }
  
  private var foregroundColor: Color {
    feature.isVoted ? .accentColor : .primary
  }
}

extension MobileJoe.FeatureRequest {
  var statusColor: Color {
    Color(hex: "\(statusHexColor)ff") ?? .blue
  }
}

#Preview("Voted") {
  List {
    FeatureRequestListRow(feature: .fixture(isVoted: true), vote: { _ in })
    FeatureRequestListRow(feature: .fixture(isVoted: false), vote: { _ in })
  }
}
