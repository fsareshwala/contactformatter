import Contacts
import FirebaseAnalytics
import PhoneNumberKit

class ContactListViewModel: ObservableObject {
  @Published var validContacts: [Contact] = []
  @Published var invalidContacts: [Contact] = []
  @Published var selectedFormatType: PhoneNumberFormat = .international

  private let phoneNumberUtility = PhoneNumberUtility()

  init() {
    getContacts()
  }

  public func anyContactNeedsFormatting() -> Bool {
    for c in validContacts {
      if c.needsFormatting(toFormat: selectedFormatType) {
        return true
      }
    }

    return false
  }

  public func saveContacts() {
    if !anyContactNeedsFormatting() {
      return
    }

    for c in validContacts {
      if !c.isChecked {
        continue
      }

      guard let index = c.deviceContact.phoneNumbers.firstIndex(of: c.devicePhoneNumber) else {
        continue
      }

      guard let contact = c.deviceContact.mutableCopy() as? CNMutableContact else {
        continue
      }

      let formatted = c.formatPhoneNumber(selectedFormatType)
      contact.phoneNumbers[index] = CNLabeledValue(
        label: c.devicePhoneNumber.label,
        value: CNPhoneNumber(stringValue: formatted)
      )

      let saveRequest = CNSaveRequest()
      saveRequest.update(contact)

      do {
        try CNContactStore().execute(saveRequest)
      } catch {
        print("Error saving contact: \(error)")
      }
    }

    logFormatType()
    getContacts()
  }

  public func getContacts() {
    let status = CNContactStore.authorizationStatus(for: .contacts)
    switch status {
    case .authorized, .limited:
      fetchContacts()
    case .notDetermined:
      requestAuthorization()
    case .restricted, .denied:
      fallthrough
    @unknown default:
      print("foo")
    }
  }

  private func requestAuthorization() {
    let store = CNContactStore()

    store.requestAccess(for: .contacts) { granted, error in
      if granted {
        self.fetchContacts()
      }
    }
  }

  private func fetchContacts() {
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
        var validContacts: [Contact] = []
        var invalidContacts: [Contact] = []

        try store.enumerateContacts(with: request) {
          contact,
          stop in
          for phoneNumber in contact.phoneNumbers {
            let contact = Contact(deviceContact: contact, devicePhoneNumber: phoneNumber)
            if contact.hasValidPhoneNumber() {
              validContacts.append(contact)
            } else {
              invalidContacts.append(contact)
            }
          }
        }

        DispatchQueue.main.async {
          self.validContacts = validContacts.sorted(by: { $0.name < $1.name })
          self.invalidContacts = invalidContacts.sorted(by: { $0.name < $1.name })
        }
      } catch {
        print("Error on contact fetching \(error)")
      }
    }
  }

  private func logFormatType() {
    var formatType: String = ""
    switch selectedFormatType {
      case .e164:
        formatType = "E164"
      case .international:
        formatType = "International"
      case .national:
        formatType = "National"
    }
    Analytics.logEvent(AnalyticsEventSelectItem, parameters: [
      AnalyticsParameterItemID: "format-type",
      AnalyticsParameterItemName: "Format Type",
      AnalyticsParameterContentType: formatType,
    ])
  }
}
