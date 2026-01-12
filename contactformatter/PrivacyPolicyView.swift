import SwiftUI

struct PrivacyPolicyView: View {
  var body: some View {
    ScrollView {
      Text(
        """
        **Effective Date:** June 11, 2025

        Your privacy is our priority. This app is designed to format contact information locally on your device. Your presonal contact data is never collected, stored, or shared.

        **1. Local Processing**
        All contact formatting is performed entirely on your device. None of your contacts, phone numbers, or address book details are ever uploaded to a server, stored, or shared with third parties.

        **2. Open Source**
        To ensure total transparency, this app is open source. Users can review its source code to verify the privacy claims and see exactly how your data is handled. You can find the source code at: https://github.com/fsareshwala/contactformatter.

        **3. Information Collected**
        To help improve the app’s performance and stability, two types of anonymous data are collected:

          **Usage Analytics:** Google Analytics to collect anonymous information about how the app is used (e.g., which buttons are clicked or which features are most popular). This does not include any personal information or contact data.

          **Crash Reporting:** If the app crashes, the app uploads a technical report containing details about the error and your device model on the next app launch. This helps identify and fix bugs to make the app more stable.

        **4. Data Security**
        Because your contact data never leaves your device, it remains under your total control. Industry-standard practices and methods ensure that the anonymous technical data the app uploads is handled securely.

        **5. Third-Party Services**
        This app uses the following third-party services.

          Google Analytics
          Crashlytics/Firebase

        **6. Changes to This Policy**
        This policy may be updated from time to time. Any changes will be reflected by the "Effective Date" at the top of this page.
        """
      )
      .padding()
    }
    .navigationTitle("Privacy Policy")
    .navigationBarTitleDisplayMode(.inline)
  }
}
