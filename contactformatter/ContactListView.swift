import Contacts
import PhoneNumberKit
import SwiftUI

struct Contact {
  var contact: CNContact
  var phoneNumber: CNLabeledValue<CNPhoneNumber>
  var parsedPhoneNumber: PhoneNumber = PhoneNumber.notPhoneNumber()
  var isChecked: Bool = true

  var name: String {
    let formatter = CNContactFormatter()
    return formatter.string(from: contact as CNContact) ?? "unknown name"
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
            ForEach($contacts, id: \.phoneNumber) { contact in
              let formatted = phoneNumberUtility.format(
                contact.parsedPhoneNumber.wrappedValue,
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
          } else {
            Text("All contact phone numbers are formatted correctly")
              .padding()
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

  func anyContactNeedsFormatting() -> Bool {
    for c in contacts {
      let formatted = phoneNumberUtility.format(c.parsedPhoneNumber, toType: selectedFormatType)
      if c.phoneNumber.value.stringValue != formatted {
        return true
      }
    }

    return false
  }

  func saveContacts() {
    if !anyContactNeedsFormatting() {
      return
    }


    for c in contacts {
      if !c.isChecked {
        continue
      }

      guard let index = c.contact.phoneNumbers.firstIndex(of: c.phoneNumber) else {
        continue
      }

      guard let contact = c.contact.mutableCopy() as? CNMutableContact else {
        continue
      }

      let value = phoneNumberUtility.format(c.parsedPhoneNumber, toType: selectedFormatType)
      contact.phoneNumbers[index] = CNLabeledValue(
        label: c.phoneNumber.label,
        value: CNPhoneNumber(stringValue: value)
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

  func getContacts() {
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

  func requestContactsAuthorization() {
    let store = CNContactStore()

    store.requestAccess(for: .contacts) { granted, error in
      if granted {
        makeContactsFetchRequest()
      }
    }
  }

  func makeContactsFetchRequest() {
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
            var contact = Contact(contact: contact, phoneNumber: phoneNumber)
            contact.parsedPhoneNumber = parsePhoneNumber(contact.phoneNumber.value)
            newContacts.append(contact)
          }
        }

        contacts = newContacts.sorted(by: { $0.name < $1.name })
      } catch {
        print("Error on contact fetching \(error)")
      }
    }
  }

  func parsePhoneNumber(_ phoneNumber: CNPhoneNumber) -> PhoneNumber {
    do {
      return try phoneNumberUtility.parse(phoneNumber.stringValue, ignoreType: true)
    } catch {
      print("invalid number: \(phoneNumber.stringValue)")
    }

    return PhoneNumber.notPhoneNumber()
  }
}
