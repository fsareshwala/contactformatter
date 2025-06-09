import PhoneNumberKit
import SwiftUI

struct FormatTypeOption: Identifiable {
  let id = UUID()
  let formatType: PhoneNumberFormat
  let label: String
}

struct FormatTypeList: View {
  private let formatTypes: [(FormatTypeOption)] = [
    FormatTypeOption(formatType: .international, label: "International"),
    FormatTypeOption(formatType: .national, label: "National"),
    FormatTypeOption(formatType: .e164, label: "e.164"),
  ]

  @Binding var selectedFormatType: PhoneNumberFormat

  var body: some View {
    ForEach(formatTypes) { item in
      HStack {
        Button(action: {
          selectedFormatType = item.formatType
        }) {
          let selected = (selectedFormatType == item.formatType)
          Image(systemName: selected ? "checkmark.circle.fill" : "circle")
            .foregroundColor(selected ? .blue : .gray)
        }

        Text(item.label).font(.callout)
      }
    }
  }
}
