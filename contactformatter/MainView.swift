import Contacts
import PhoneNumberKit
import SwiftUI

// NavigationLink(destination: DetailView()) {
//     Text("Go to Detail View")
// }

struct MainView: View {
  @State var authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)

  let restrictedMessage = """
    This application is not authorized to access contact data.

    You cannot change this application’s status, possibly due to active restrictions such as \
    parental controls being in place.
    """

  let deniedMessage = """
    This device has been denied access to your contacts. Please update your settings to allow \
    access.
    """

  var body: some View {
    switch authorizationStatus {
    case .authorized, .limited:
      ContactListView()
    case .notDetermined:
        WelcomeView(authorizationStatus: $authorizationStatus)
    case .restricted:
      MessageView(message: restrictedMessage)
    case .denied:
      ActionView(
        message: deniedMessage,
        button: "Open Settings",
        action: {
          openSettings()
        }
      )
    @unknown default:
      ActionView(
        message: deniedMessage,
        button: "Open Settings",
        action: {
          openSettings()
        }
      )
    }
  }

  func openSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url)
    }
  }
}

#Preview {
  MainView()
}
