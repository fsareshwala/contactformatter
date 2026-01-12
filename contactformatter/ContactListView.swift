import Contacts
import PhoneNumberKit
import SwiftUI

struct ContactListView: View {
  @StateObject var viewModel: ContactListViewModel = ContactListViewModel()
  @State var activeSheet: Sheet?
  @State var isFormattingInProgress: Bool = false
  @State private var selectedInvalidContact: Contact?

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
        Section(header: Text("Format Type")) {
          FormatTypeList(selectedFormatType: $viewModel.selectedFormatType)
        }

        Section(header: Text("Contacts")) {
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
                phoneNumber: formatted,
                originalPhoneNumber: c.phoneNumber,
                phoneNumberLabel: c.phoneNumberLabel
              )
            }
          }
        }

        if !$viewModel.invalidContacts.isEmpty {
          Section(
            header: HStack {
              Text(("Invalid Contacts"))
              Button(action: { activeSheet = .invalidContactsInfo }) {
                Image(systemName: "info.circle")
                  .foregroundColor(.blue)
              }
            }
          ) {
            ForEach(viewModel.invalidContacts) { contact in
              Button(action: {
                selectedInvalidContact = contact
              }) {
                VStack(alignment: .leading) {
                  HStack {
                    Text(contact.name)
                      .foregroundColor(.primary)
                    Spacer()
                    Text(contact.devicePhoneNumber.value.stringValue)
                      .font(.footnote)
                      .foregroundColor(.primary)
                  }
                  HStack {
                    Spacer()
                    Text(contact.phoneNumberLabel)
                  }
                  .font(.footnote)
                  .foregroundColor(.secondary)
                }
              }
            }
          }
        }
      }
      .sheet(item: $selectedInvalidContact) { contact in
        ContactDetailView(contact: contact.deviceContact)
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
      .sheet(item: $activeSheet) { sheet in sheet.view }
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
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: { activeSheet = .about }) {
            Image(systemName: "info.circle")
          }
        }
        ToolbarItem(placement: .bottomBar) { Spacer() }

        if viewModel.anyContactNeedsFormatting() {
          ToolbarItem(placement: .bottomBar) {
            Button(action: { doFormat() }) {
              Image(systemName: "person.crop.circle.badge.checkmark")
            }
            .foregroundStyle(.blue)
          }
        }
      }
    }
  }
}
