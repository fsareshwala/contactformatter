import SwiftUI

struct AboutView: View {
  private let github = "https://github.com/fsareshwala/contactformatter"
  private let appStore = "https://apps.apple.com/us/app/clean-dial/id6745625133"

  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationStack {
      ZStack {
        Color(UIColor.systemGroupedBackground).ignoresSafeArea()
        VStack (spacing: 20) {
          Image("AppIconInApp")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .cornerRadius(20)
            .shadow(radius: 10)

          Text("Clean Dial")
            .font(.largeTitle)
            .fontWeight(.bold)

          Text("Version \(Util.GetAppVersion())")
            .font(.subheadline)
            .foregroundColor(.secondary)

          Form {
            Section {
              List {
                NavigationLink(destination: PrivacyPolicyView()) {
                  Label("Privacy Policy", systemImage: "questionmark.text.page")
                }
                ShareLink(
                  item: URL(string: appStore)!,
                  message: Text("Check out Clean Dial, the easiest way to format your contacts!")
                ) {
                  Label("Share Clean Dial", systemImage: "square.and.arrow.up")
                }
                Link(destination: URL(string: "\(github)/issues")!) {
                  Label("Report a Bug", systemImage: "exclamationmark.circle")
                }

                Link(destination: URL(string: github)!) {
                  Label {
                    Text("Source Code")
                      .font(.body)
                    Text("This app is fully open source. You can read the code on GitHub.")
                      .font(.subheadline)
                      .foregroundColor(.secondary)
                  } icon: {
                    Image(systemName: "curlybraces.square")
                  }
                }
              }
            }
          }
        }
        .padding(.top, 40)
        .navigationTitle("About This App")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button(action: { dismiss() }) {
              Image(systemName: "xmark")
            }
          }
        }
      }
    }
  }
}

#Preview {
  AboutView()
}
