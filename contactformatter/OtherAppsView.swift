import SwiftUI
import FirebaseAnalytics

struct AppInfo {
  let iconName: String
  let appName: String
  let description: String
  let appStoreLink: String
}

struct OtherAppsView: View {
  @State private var app = AppInfo(
    iconName: "forecash",
    appName: "Forecash",
    description: "Plan bill pay dates, forecast your finances. Project your future balance so you can plan ahead.",
    appStoreLink: "https://apps.apple.com/us/app/forecash-bill-planner/id6747775439"
  )

  var body: some View {
    Button(action: {
      Analytics.logEvent("tap_other_app", parameters: ["app_name": app.appName])
      if let url = URL(string: app.appStoreLink) {
        UIApplication.shared.open(url)
      }
    }) {
      HStack(spacing: 15) {
        Image(app.iconName)
          .resizable()
          .scaledToFit()
          .frame(width: 50, height: 50)
          .foregroundColor(.accentColor)
          .cornerRadius(12)

        VStack(alignment: .leading, spacing: 4) {
          Text(app.appName)
            .font(.headline)

          Text(app.description)
            .font(.caption)
            .foregroundColor(.secondary)
            .lineLimit(2)
        }
      }
    }
  }
}

#Preview {
  OtherAppsView()
}
