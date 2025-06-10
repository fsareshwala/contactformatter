import Contacts
import PhoneNumberKit
import SwiftUI

struct ContactListView: View {
  @StateObject var viewModel: ContactListViewModel = ContactListViewModel()
  @State var invalidContactsSheetPresented: Bool = false

  @Environment(\.scenePhase) var scenePhase

  var body: some View {
    NavigationView {
      List {
        Section(header: Text("Format Type").textCase(.none)) {
          FormatTypeList(selectedFormatType: $viewModel.selectedFormatType)
        }

        Section(header: Text("Contacts").textCase(.none)) {
          if !viewModel.anyContactNeedsFormatting() {
            Text("All contact phone numbers are formatted correctly")
              .padding()
              .multilineTextAlignment(.center)
              .frame(maxWidth: .infinity, alignment: .center)
          }

          ForEach($viewModel.validContacts) { contact in
            let c = contact.wrappedValue
            if c.needsFormatting(toFormat: viewModel.selectedFormatType) {
              let formatted = c.formatPhoneNumber(viewModel.selectedFormatType)
              if c.phoneNumber != formatted {
                ContactView(
                  isChecked: contact.isChecked,
                  name: c.name,
                  phoneNumber: formatted
                )
              }
            }
          }
        }

        if !$viewModel.invalidContacts.isEmpty {
          Section(header: HStack{
            Text(("Invalid Contacts")).textCase(.none)
            Button(action: { invalidContactsSheetPresented = true }) {
              Image(systemName: "info.circle")
                .foregroundColor(.blue)
            }
          }) {
            ForEach($viewModel.invalidContacts) { contact in
              HStack {
                let c = contact.wrappedValue
                Text(c.name)
                Spacer()
                Text(c.devicePhoneNumber.value.stringValue)
                  .font(.footnote)
              }
            }
          }
        }
      }
      .navigationTitle("Clean Dial")
      .navigationBarTitleDisplayMode(.inline)
      .refreshable { viewModel.getContacts() }
      .onChange(of: scenePhase) { newPhase in
        switch newPhase {
        case .active:
          viewModel.getContacts()
        case .inactive, .background:
          break
        @unknown default:
          break
        }
      }
      .sheet(
        isPresented: $invalidContactsSheetPresented,
        onDismiss: { invalidContactsSheetPresented = false }
      ) { InvalidContactsInfoView(isPresented: $invalidContactsSheetPresented) }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { viewModel.saveContacts() }) {
            Text("Format").disabled(!viewModel.anyContactNeedsFormatting())
          }
        }
      }
    }
  }
}
