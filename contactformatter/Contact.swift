import Contacts
import PhoneNumberKit

class Contact: Identifiable {
  let id = UUID()
  private let formatter = CNContactFormatter()
  private let phoneNumberUtility = PhoneNumberUtility()

  let deviceContact: CNContact
  var devicePhoneNumber: CNLabeledValue<CNPhoneNumber>
  var parsedPhoneNumber: PhoneNumber

  var isChecked: Bool = true

  var name: String {
    return formatter.string(from: deviceContact as CNContact) ?? "unknown name"
  }

  var phoneNumber: String {
    return devicePhoneNumber.value.stringValue
  }

  init(
    deviceContact: CNContact,
    devicePhoneNumber: CNLabeledValue<CNPhoneNumber>,
    isChecked: Bool = true
  ) {
    self.deviceContact = deviceContact
    self.devicePhoneNumber = devicePhoneNumber
    self.isChecked = isChecked

    do {
      parsedPhoneNumber = try phoneNumberUtility.parse(
        devicePhoneNumber.value.stringValue,
        ignoreType: true
      )
    } catch {
      parsedPhoneNumber = PhoneNumber.notPhoneNumber()
    }
  }

  var hasValidPhoneNumber: Bool {
    return parsedPhoneNumber != PhoneNumber.notPhoneNumber()
  }

  func needsFormatting(toFormat: PhoneNumberFormat) -> Bool {
    if !hasValidPhoneNumber {
      return false
    }

    let formatted = phoneNumberUtility.format(parsedPhoneNumber, toType: toFormat)
    if phoneNumber == formatted {
      return false
    }

    return true
  }

  func formatPhoneNumber(_ toFormat: PhoneNumberFormat) -> String {
    return phoneNumberUtility.format(parsedPhoneNumber, toType: toFormat)    
  }
}
