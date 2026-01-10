import Foundation
import SwiftUI

enum Sheet: String, Identifiable {
  case invalidContactsInfo
  case about

  var id: String { rawValue }

  @ViewBuilder
  var view: some View {
    switch self {
    case .invalidContactsInfo:
      InvalidContactsInfoView()
        .presentationDetents([.medium])
    case .about:
      AboutView()
    }
  }
}
