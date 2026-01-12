import Contacts
import ContactsUI
import FirebaseAnalytics
import PhoneNumberKit
import SwiftUI

@MainActor
class ContactListViewModel: ObservableObject {
  @Published var validContacts: [Contact] = []
  @Published var invalidContacts: [Contact] = []
  @Published var selectedFormatType: PhoneNumberFormat = .international

  private let phoneNumberUtility = PhoneNumberUtility()
  private var isFetchingContacts = false

  init() {
    Task {
      await getContacts()
    }
  }

  func anyContactNeedsFormatting() -> Bool {
    return validContacts.contains { $0.needsFormatting(toFormat: selectedFormatType) }
  }

  func saveContacts() async {
    guard anyContactNeedsFormatting() else { return }

    let contactsToFormat = validContacts.filter {
      $0.isChecked && $0.needsFormatting(toFormat: selectedFormatType)
    }

    guard !contactsToFormat.isEmpty else { return }

    await Task.detached {
      for c in contactsToFormat {
        guard let index = c.deviceContact.phoneNumbers.firstIndex(of: c.devicePhoneNumber) else {
          continue
        }

        guard let contact = c.deviceContact.mutableCopy() as? CNMutableContact else {
          continue
        }

        let formatted = await c.formatPhoneNumber(self.selectedFormatType)
        contact.phoneNumbers[index] = CNLabeledValue(
          label: c.devicePhoneNumber.label,
          value: CNPhoneNumber(stringValue: formatted)
        )

        let saveRequest = CNSaveRequest()
        saveRequest.update(contact)

        do {
          try CNContactStore().execute(saveRequest)
        } catch {
          print("Error saving contact \(c.name): \(error)")
        }
      }
    }.value

    logFormatType()
    await getContacts()
  }

  func getContacts() async {
    guard !isFetchingContacts else { return }
    isFetchingContacts = true
    defer { isFetchingContacts = false }

    let status = CNContactStore.authorizationStatus(for: .contacts)
    switch status {
    case .authorized, .limited:
      await fetchContacts()
    case .notDetermined:
      if await requestAuthorization() {
        await fetchContacts()
      }
    case .restricted, .denied:
      break
    @unknown default:
      break
    }
  }

  private func requestAuthorization() async -> Bool {
    let store = CNContactStore()
    do {
      return try await store.requestAccess(for: .contacts)
    } catch {
      print("Error requesting contact access: \(error)")
      return false
    }
  }

  private func fetchContacts() async {
    self.validContacts = []
    self.invalidContacts = []

    let contactStream = createContactStream()
    var contactBatch: [Contact] = []
    let batchSize = 50

    for await contact in contactStream {
      contactBatch.append(contact)
      if contactBatch.count >= batchSize {
        self.validContacts.append(contentsOf: contactBatch.filter { $0.hasValidPhoneNumber })
        self.invalidContacts.append(contentsOf: contactBatch.filter { !$0.hasValidPhoneNumber })
        contactBatch.removeAll()
      }
    }

    if !contactBatch.isEmpty {
      self.validContacts.append(contentsOf: contactBatch.filter { $0.hasValidPhoneNumber })
      self.invalidContacts.append(contentsOf: contactBatch.filter { !$0.hasValidPhoneNumber })
    }

    self.validContacts.sort { $0.name < $1.name }
    self.invalidContacts.sort { $0.name < $1.name }
  }

  private func createContactStream() -> AsyncStream<Contact> {
    AsyncStream { continuation in
      Task.detached(priority: .userInitiated) {
        let store = CNContactStore()
        let keys: [any CNKeyDescriptor] =
        await [
            CNContactTypeKey as any CNKeyDescriptor,
            CNContactPhoneNumbersKey as any CNKeyDescriptor,
            CNContactViewController.descriptorForRequiredKeys(),
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
          ]
        let request = CNContactFetchRequest(keysToFetch: keys)

        do {
          try store.enumerateContacts(with: request) { contact, stop in
            for phoneNumber in contact.phoneNumbers {
              let newContact = Contact(deviceContact: contact, devicePhoneNumber: phoneNumber)
              continuation.yield(newContact)
            }
          }
          continuation.finish()
        } catch {
          print("Error enumerating contacts: \(error)")
          continuation.finish()
        }
      }
    }
  }

  private func logFormatType() {
    let formatType: String
    switch selectedFormatType {
    case .e164:
      formatType = "E164"
    case .international:
      formatType = "International"
    case .national:
      formatType = "National"
    }
    Analytics.logEvent(
      AnalyticsEventSelectItem,
      parameters: [
        AnalyticsParameterItemID: "format-type",
        AnalyticsParameterItemName: "Format Type",
        AnalyticsParameterContentType: formatType,
      ]
    )
  }
}
