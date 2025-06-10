import Contacts
import SwiftUI

struct FeatureView: View {
  let imageName: String
  let title: String
  let subtitle: String

  var body: some View {
    HStack {
      Image(systemName: imageName)
        .resizable()
        .foregroundStyle(.tint)
        .scaledToFit()
        .frame(width: 35, height: 35)
        .padding(.trailing)

      VStack(alignment: .leading) {
        Text(title)
          .font(.headline)
          .foregroundColor(.primary)

        Text(subtitle)
          .font(.callout)
          .foregroundColor(.secondary)
      }
    }
  }
}

struct WelcomeView: View {
  @Binding var authorizationStatus: CNAuthorizationStatus

  var body: some View {
    VStack {
      Spacer()

      LogoHeaderView()
      VStack(alignment: .leading, spacing: 25) {
        FeatureView(
          imageName: "person.text.rectangle",
          title: "Format contact phone numbers",
          subtitle: "Choose from standard formats"
        )

        FeatureView(
          imageName: "switch.2",
          title: "Easily switch between formats",
          subtitle: "Choose from standard formats"
        )

        FeatureView(
          imageName: "hand.raised.app",
          title: "Privacy focused",
          subtitle: "Your contacts never leave your device"
        )
      }
      .padding()

      Spacer()
      Text("Please tap the button below to grant Clean Dial access to your contacts")
        .font(.callout)
        .padding()
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)

      Button(action: { requestAuthorization() }) {
        Text("Continue")
          .font(.headline)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .padding()
    }
  }

  private func requestAuthorization() {
    CNContactStore().requestAccess(for: .contacts) { granted, error in
      authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }
  }
}

#Preview {
  WelcomeView(authorizationStatus: .constant(.notDetermined))
}
