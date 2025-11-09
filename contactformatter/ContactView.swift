import SwiftUI

struct ContactView: View {
  @Binding var isChecked: Bool
  let name: String
  let phoneNumber: String
  let originalPhoneNumber: String
  let phoneNumberLabel: String

  var body: some View {
    HStack {
      Button(action: { isChecked.toggle() }) {
        Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
          .foregroundColor(isChecked ? .blue : .gray)
          .padding(.trailing)
      }

      VStack(alignment: .leading) {
        HStack {
          Text(name)
          Spacer()
          Text(phoneNumber)
            .font(.footnote)
        }
        HStack {
          Text(phoneNumberLabel)
          Spacer()
          Text(originalPhoneNumber)
            .strikethrough()
        }
        .font(.footnote)
        .foregroundColor(.secondary)
      }
    }
  }
}
