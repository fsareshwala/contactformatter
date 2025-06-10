import Contacts
import PhoneNumberKit
import SwiftUI

struct DeniedView: View {
  let deniedMessage = """
    This device has been denied access to your contacts. Please update your settings to allow \
    access.
    """

  var body: some View {
    ActionView(
      message: deniedMessage,
      button: "Open Settings",
      action: {
        openSettings()
      }
    )
  }

  func openSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url)
    }
  }
}

struct RestrictedView: View {
  let restrictedMessage = """
    This application is not authorized to access contact data.

    You cannot change this application’s status, possibly due to active restrictions such as \
    parental controls being in place.
    """

  var body: some View {
    MessageView(message: restrictedMessage)
  }
}

struct MainView: View {
  @State var authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)

  var body: some View {
    switch authorizationStatus {
    case .authorized, .limited:
      ContactListView()
    case .notDetermined:
      LandingView(authorizationStatus: $authorizationStatus)
    case .restricted:
      RestrictedView()
    case .denied:
      DeniedView()
    @unknown default:
      DeniedView()
    }
  }
}

#Preview {
  MainView()
}
