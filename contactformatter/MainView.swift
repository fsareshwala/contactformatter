import Contacts
import PhoneNumberKit
import SwiftUI

// NavigationLink(destination: DetailView()) {
//     Text("Go to Detail View")
// }

struct FormatTypeOption {
  var formatType: PhoneNumberFormat
  var label: String
}

struct FormatTypeList: View {
  private let formatTypes: [(FormatTypeOption)] = [
    FormatTypeOption(formatType: .e164, label: "e.164: +15555648583"),
    FormatTypeOption(formatType: .international, label: "International: +1 555-564-8583"),
    FormatTypeOption(formatType: .national, label: "National: (555) 564-8583"),
  ]

  @Binding var selectedFormatType: PhoneNumberFormat

  var body: some View {
    ForEach(formatTypes, id: \.formatType) { item in
      HStack {
        Button(action: {
          selectedFormatType = item.formatType
        }) {
          let selected = (selectedFormatType == item.formatType)
          Image(systemName: selected ? "checkmark.circle.fill" : "circle")
            .foregroundColor(selected ? .blue : .gray)
        }

        Text(item.label)
      }
    }
  }
}

struct Contact {
  var contact: CNContact
  var phoneNumber: CNLabeledValue<CNPhoneNumber>
  var parsedPhoneNumber: PhoneNumber = PhoneNumber.notPhoneNumber()
  var isChecked: Bool = true

  var name: String {
    if !contact.givenName.isEmpty || !contact.familyName.isEmpty {
      return "\(contact.givenName) \(contact.familyName)"
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    return contact.organizationName
  }
}

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

struct MainView: View {
  @State private var contacts: [Contact] = []
  @State private var contactsAccess: Bool = false
  @State private var selectedFormatType: PhoneNumberFormat = .international

  let phoneNumberUtility = PhoneNumberUtility()

  var body: some View {
    NavigationView {
      List {
        if contactsAccess {
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
        } else {
          Text(
            "This device does not have access to your contacts. Please update your settings to allow access."
          )
          .padding()
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity, alignment: .center)
        }
      }
      .navigationTitle("Contact Formatter")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear(perform: getContacts)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: { getContacts() }) { Text("Reload") }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { saveContacts() }) { Text("Format") }
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
        print("Contact updated successfully")
      } catch {
        print("Error saving contact: \(error)")
      }
    }

    getContacts()
  }

  func getContacts() {
    let status = CNContactStore.authorizationStatus(for: .contacts)
    switch status {
    case .authorized:
      contactsAccess = true
      makeContactsFetchRequest()
    case .limited:
      contactsAccess = true
      makeContactsFetchRequest()
    case .notDetermined:
      contactsAccess = false
      requestContactsAuthorization()
    case .restricted:
      contactsAccess = false
      print("restricted")
    case .denied:
      contactsAccess = false
      print("denied")
    @unknown default:
      contactsAccess = false
      print("default")
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
        CNContactGivenNameKey,
        CNContactFamilyNameKey,
        CNContactOrganizationNameKey,
        CNContactPhoneNumbersKey,
      ] as [CNKeyDescriptor]

    let request = CNContactFetchRequest(keysToFetch: keys)
    DispatchQueue.global().async {
      do {
        var newContacts: [Contact] = []

        try store.enumerateContacts(with: request) {
          contact, stop in
          for phoneNumber in contact.phoneNumbers {
            print(
              "Name: \(contact.givenName) \(contact.familyName), phone number: \(phoneNumber.value.stringValue)"
            )

            var contact = Contact(contact: contact, phoneNumber: phoneNumber)
            contact.parsedPhoneNumber = parsePhoneNumber(contact.phoneNumber.value)
            newContacts.append(contact)
          }
        }

        contacts = newContacts
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

#Preview {
  MainView()
}
