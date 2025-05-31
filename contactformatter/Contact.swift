import Contacts
import PhoneNumberKit

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
