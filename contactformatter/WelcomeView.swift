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
        .frame(width: 30, height: 30)
        .padding(.trailing, 20)

      VStack(alignment: .leading) {
        Text(title)
          .font(.headline)

        Text(subtitle)
          .font(.callout)
          .foregroundStyle(.gray)
      }
    }
  }
}

struct WelcomeView: View {
  @Binding var authorizationStatus: CNAuthorizationStatus

  var body: some View {
    VStack {
      Spacer()

      LogoView()
      VStack(alignment: .leading, spacing: 25) {
        FeatureView(
          imageName: "person.text.rectangle",
          title: "Format contact phone numbers",
          subtitle: "Choose from standard formats"
        )

        FeatureView(
          imageName: "switch.2",
          title: "Easily switch between formats",
          subtitle: "Choose from standard formats (national, international, e.164)"
        )

        FeatureView(
          imageName: "hand.raised.app",
          title: "Privacy focused",
          subtitle: "Your contact information never leaves your device"
        )
      }
      .padding(.leading, 20)
      .padding(.trailing, 20)

      Spacer()
      Text("Please tap the button below to grant Clean Dial access to your contacts")
      .font(.callout)
      .padding()
      .multilineTextAlignment(.center)
      .frame(maxWidth: .infinity, alignment: .center)

      Button(action: {
        requestContactsAuthorization()
      }) {
        Text("Grant Access")
          .font(.headline)
          .foregroundColor(.white)
          .frame(minWidth: 200)
          .padding()
          .background(Color.accentColor)
          .cornerRadius(10)
      }
      .padding(.bottom, 50)
    }
  }

  func requestContactsAuthorization() {
    CNContactStore().requestAccess(for: .contacts) { granted, error in
      authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }
  }
}

#Preview {
  WelcomeView(authorizationStatus: .constant(.notDetermined))
}
