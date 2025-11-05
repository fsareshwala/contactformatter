import Foundation

struct Util {
  static func GetAppVersion() -> String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown Version"
  }
}
