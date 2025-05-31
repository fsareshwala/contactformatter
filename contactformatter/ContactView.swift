import SwiftUI

struct ContactView: View {
  @Binding var isChecked: Bool
  var name: String
  var phoneNumber: String

  var body: some View {
    HStack {
      Button(action: {
        isChecked.toggle()
      }) {
        Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
          .foregroundColor(isChecked ? .blue : .gray)
          .padding(.trailing)
      }

      Text(name)
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
