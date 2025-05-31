import Contacts
import PhoneNumberKit
import SwiftUI

// NavigationLink(destination: DetailView()) {
//     Text("Go to Detail View")
// }

struct MainView: View {
  @State var authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)

  var welcomeMessage = """
    Clean Dial needs access to your contacts in order to load, format, and save contact phone \
    numbers. Unfortunately, Clean Dial doesn't have access yet. 

    Please tap the button below to grant access. Your contact information never leaves your device.
    """

  var restrictedMessage = """
    This application is not authorized to access contact data.

    You cannot change this application’s status, possibly due to active restrictions such as \
    parental controls being in place.
    """

  var deniedMessage = """
    This device has been denied access to your contacts. Please update your settings to allow \
    access.
    """

  var body: some View {
    switch authorizationStatus {
    case .authorized, .limited:
      ContactListView()
    case .notDetermined:
      ActionView(
        message: welcomeMessage,
        button: "Grant Access",
        action: {
          requestContactsAuthorization()
        }
      )
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

  func requestContactsAuthorization() {
    CNContactStore().requestAccess(for: .contacts) { granted, error in
      authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
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
