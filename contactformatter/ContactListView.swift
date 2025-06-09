import Contacts
import PhoneNumberKit
import SwiftUI

class Contact: Identifiable {
  let id = UUID()
  private let formatter = CNContactFormatter()
  private let phoneNumberUtility = PhoneNumberUtility()

  let contact: CNContact
  var phoneNumber: CNLabeledValue<CNPhoneNumber>
  var parsed: PhoneNumber

  var isChecked: Bool = true
  var name: String {
    return formatter.string(from: contact as CNContact) ?? "unknown name"
  }

  init(
    contact: CNContact,
    phoneNumber: CNLabeledValue<CNPhoneNumber>,
    isChecked: Bool = true
  ) {
    self.contact = contact
    self.phoneNumber = phoneNumber
    self.isChecked = isChecked

    do {
      parsed = try phoneNumberUtility.parse(
        phoneNumber.value.stringValue,
        ignoreType: true
      )
    } catch {
      parsed = PhoneNumber.notPhoneNumber()
    }
  }

  public func hasValidPhoneNumber() -> Bool {
    return parsed != PhoneNumber.notPhoneNumber()
  }
}

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

struct ContactListView: View {
  @State private var contacts: [Contact] = []
  @State private var selectedFormatType: PhoneNumberFormat = .international

  let phoneNumberUtility = PhoneNumberUtility()

  var body: some View {
    NavigationView {
      List {
        Section(header: Text("Format Type").textCase(.none)) {
          FormatTypeList(selectedFormatType: $selectedFormatType)
        }

        Section(header: Text("Contacts").textCase(.none)) {
          if anyContactNeedsFormatting() {
            ForEach($contacts) { contact in
              if contact.wrappedValue.hasValidPhoneNumber() {
                let formatted = phoneNumberUtility.format(
                  contact.parsed.wrappedValue,
                  toType: selectedFormatType
                )

                if contact.phoneNumber.wrappedValue.value.stringValue != formatted {
                  ContactView(
                    isChecked: contact.isChecked,
                    name: contact.wrappedValue.name,
                    phoneNumber: formatted
                  )
                }
              }
            }
          } else {
            Text("All contact phone numbers are formatted correctly")
              .padding()
              .font(.callout)
              .multilineTextAlignment(.center)
              .frame(maxWidth: .infinity, alignment: .center)
          }
        }
      }
      .navigationTitle("Clean Dial")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear(perform: getContacts)
      .refreshable {
        getContacts()
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { saveContacts() }) {
            Text("Format").disabled(!anyContactNeedsFormatting())
          }
        }
      }
    }
  }

  private func anyContactNeedsFormatting() -> Bool {
    for c in contacts {
      if !c.hasValidPhoneNumber() {
        continue
      }

      let formatted = phoneNumberUtility.format(c.parsed, toType: selectedFormatType)
      if c.phoneNumber.value.stringValue != formatted {
        return true
      }
    }

    return false
  }

  private func saveContacts() {
    if !anyContactNeedsFormatting() {
      return
    }

    for c in contacts {
      if !c.isChecked {
        continue
      }

      if !c.hasValidPhoneNumber() {
        continue
      }

      guard let index = c.contact.phoneNumbers.firstIndex(of: c.phoneNumber) else {
        continue
      }

      guard let contact = c.contact.mutableCopy() as? CNMutableContact else {
        continue
      }

      let formatted = phoneNumberUtility.format(c.parsed, toType: selectedFormatType)
      contact.phoneNumbers[index] = CNLabeledValue(
        label: c.phoneNumber.label,
        value: CNPhoneNumber(stringValue: formatted)
      )

      let saveRequest = CNSaveRequest()
      saveRequest.update(contact)

      do {
        let store = CNContactStore()
        try store.execute(saveRequest)
      } catch {
        print("Error saving contact: \(error)")
      }
    }

    getContacts()
  }

  private func getContacts() {
    let status = CNContactStore.authorizationStatus(for: .contacts)
    switch status {
    case .authorized, .limited:
      makeContactsFetchRequest()
    case .notDetermined:
      requestContactsAuthorization()
    case .restricted, .denied:
      fallthrough
    @unknown default:
      print("foo")
    }
  }

  private func requestContactsAuthorization() {
    let store = CNContactStore()

    store.requestAccess(for: .contacts) { granted, error in
      if granted {
        makeContactsFetchRequest()
      }
    }
  }

  private func makeContactsFetchRequest() {
    let store = CNContactStore()
    let keys: [CNKeyDescriptor] =
      [
        CNContactTypeKey,
        CNContactNamePrefixKey,
        CNContactGivenNameKey,
        CNContactMiddleNameKey,
        CNContactFamilyNameKey,
        CNContactNameSuffixKey,
        CNContactOrganizationNameKey,
        CNContactPhoneNumbersKey,
      ] as [CNKeyDescriptor]

    let request = CNContactFetchRequest(keysToFetch: keys)
    DispatchQueue.global().async {
      do {
        var newContacts: [Contact] = []

        try store.enumerateContacts(with: request) {
          contact,
          stop in
          for phoneNumber in contact.phoneNumbers {
            let contact = Contact(
              contact: contact,
              phoneNumber: phoneNumber,
            )
            newContacts.append(contact)
          }
        }

        contacts = newContacts.sorted(by: { $0.name < $1.name })
      } catch {
        print("Error on contact fetching \(error)")
      }
    }
  }
}
