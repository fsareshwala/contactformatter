import SwiftUI

struct InvalidContactsInfoView: View {
  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationStack {
      VStack {
        Spacer()
        WarningHeaderView()
        Text(
          """
          Invalid contacts are those which have phone numbers that Clean Dial cannot parse and \
          will not format. Please update your contacts with valid phone numbers and try again.
          """
        )
        .padding()
        .font(.callout)
        .multilineTextAlignment(.center)
        Spacer()
      }
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          Button("Dismiss") { dismiss() }
            .font(.title3)
            .bold()
        }
      }
    }
  }
}

#Preview {
  InvalidContactsInfoView()
}
