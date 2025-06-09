import SwiftUI

struct WarningHeaderView: View {
  var body: some View {
    VStack {
      Image(systemName: "exclamationmark.triangle")
        .resizable()
        .foregroundStyle(.yellow)
        .scaledToFit()
        .frame(width: 85, height: 85)

      Text("Warning")
        .font(.largeTitle)
        .bold()
        .padding()
    }
  }
}

#Preview {
  WarningHeaderView()
}
