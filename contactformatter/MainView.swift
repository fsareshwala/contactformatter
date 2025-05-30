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
    FormatTypeOption(formatType: .international, label: "International: +1 555-564-8583"),
    FormatTypeOption(formatType: .national, label: "National: (555) 564-8583"),
    FormatTypeOption(formatType: .e164, label: "e.164: +15555648583"),
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
    let formatter = CNContactFormatter()
    return formatter.string(from: contact as CNContact) ?? "unknown name"
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
      .navigationTitle("Contact Formatter")
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

struct ActionView: View {
  let message: String
  let button: String
  let action: () -> Void

  var body: some View {
    VStack {
      Spacer()

      Image(systemName: "person.2.badge.plus")
        .resizable()
        .renderingMode(.original)
        .scaledToFit()
        .frame(width: 100, height: 100)

      Text("Clean Dial")
        .font(.title)
        .bold()

      Text(message)
        .font(.callout)
        .padding()
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)

      Spacer()

      Button(action: {
        action()
      }) {
        Text(button)
          .font(.headline)
          .foregroundColor(.white)
          .frame(minWidth: 200)
          .padding()
          .background(Color.accentColor)
          .cornerRadius(10)
      }
      .padding(.bottom, 50)
    }
  }
}

struct MessageView: View {
  let message: String

  var body: some View {
    VStack {
      Image(systemName: "person.2.badge.plus")
        .resizable()
        .renderingMode(.original)
        .scaledToFit()
        .frame(width: 100, height: 100)

      Text("Clean Dial")
        .font(.title)
        .bold()

      Text(message)
        .padding()
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)
    }
  }
}

struct MainView: View {
  @State var authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)

  var welcomeMessage = """
    Clean Dial needs access to your contacts in order to load, format, and save contact phone \
    numbers. Unfortunately, Clean Dial doesn't have access yet. 

    Please tap the button below to grant access. Your contact information never leaves your device.
    """

  var restrictedMessage = """
    This application is not authorized to access contact data.

    You cannot change this application’s status, possibly due to active restrictions such as \
    parental controls being in place.
    """

  var deniedMessage = """
    This device has been denied access to your contacts. Please update your settings to allow \
    access.
    """

  var body: some View {
    switch authorizationStatus {
    case .authorized, .limited:
      ContactListView()
    case .notDetermined:
      ActionView(
        message: welcomeMessage,
        button: "Grant Access",
        action: {
          requestContactsAuthorization()
        }
      )
    case .restricted:
      MessageView(message: restrictedMessage)
    case .denied:
      ActionView(
        message: deniedMessage,
        button: "Open Settings",
        action: {
          openSettings()
        }
      )
    @unknown default:
      ActionView(
        message: deniedMessage,
        button: "Open Settings",
        action: {
          openSettings()
        }
      )
    }
  }

  func requestContactsAuthorization() {
    CNContactStore().requestAccess(for: .contacts) { granted, error in
      authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }
  }

  func openSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url)
    }
  }
}

#Preview {
  MainView()
}
