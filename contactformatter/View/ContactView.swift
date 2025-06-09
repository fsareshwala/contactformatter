import SwiftUI

struct ContactView: View {
  @Binding var isChecked: Bool
  let name: String
  let phoneNumber: String

  var body: some View {
    HStack {
      Button(action: {
        isChecked.toggle()
      }) {
        Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
          .foregroundColor(isChecked ? .blue : .gray)
          .padding(.trailing)
      }

      Text(name).font(.callout)
      Spacer()
      Text(phoneNumber).font(.footnote)
    }
    .onAppear {
      isChecked = true
    }
    .onDisappear {
      isChecked = false
    }
  }
}
