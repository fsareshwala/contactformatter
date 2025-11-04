import Contacts
import PhoneNumberKit
import SwiftUI

struct ContactListView: View {
  @StateObject var viewModel: ContactListViewModel = ContactListViewModel()
  @State var invalidContactsSheetPresented: Bool = false
  @State var isFormattingInProgress: Bool = false

  @Environment(\.scenePhase) var scenePhase

  fileprivate func doFormat() {
    isFormattingInProgress = true
    Task {
      await viewModel.saveContacts()
      isFormattingInProgress = false
    }
  }

  var body: some View {
    NavigationStack {
      List {
        Section(header: Text("Format Type").textCase(.none)) {
          FormatTypeList(selectedFormatType: $viewModel.selectedFormatType)
        }

        Section(header: Text("Contacts").textCase(.none)) {
          if !viewModel.anyContactNeedsFormatting() {
            ContentUnavailableView {
              Label("No Contacts", systemImage: "person.crop.circle.badge.checkmark")
            } description: {
              Text("All contact phone numbers are formatted correctly")
            }
          }

          ForEach($viewModel.validContacts) { contact in
            let c = contact.wrappedValue
            if c.needsFormatting(toFormat: viewModel.selectedFormatType) {
              let formatted = c.formatPhoneNumber(viewModel.selectedFormatType)
              ContactView(
                isChecked: contact.isChecked,
                name: c.name,
                phoneNumber: formatted
              )
            }
          }
        }

        if !$viewModel.invalidContacts.isEmpty {
          Section(
            header: HStack {
              Text(("Invalid Contacts")).textCase(.none)
              Button(action: { invalidContactsSheetPresented = true }) {
                Image(systemName: "info.circle")
                  .foregroundColor(.blue)
              }
            }
          ) {
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
      .refreshable { await viewModel.getContacts() }
      .onChange(of: scenePhase) {
        if scenePhase == .active {
          Task {
            await viewModel.getContacts()
          }
        }
      }
      .sheet(isPresented: $invalidContactsSheetPresented) {
        InvalidContactsInfoView()
          .presentationDetents([.medium])
      }
      .disabled(isFormattingInProgress)
      .overlay {
        if isFormattingInProgress {
          VStack {
            ProgressView()
              .controlSize(.large)
            Text("Formatting...")
              .padding(.top)
          }
          .padding(30)
          .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 16))
          .shadow(radius: 10)
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { doFormat() }) {
            Text("Format")
              .disabled(!viewModel.anyContactNeedsFormatting())
          }
        }
      }
    }
  }
}
