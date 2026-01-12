import SwiftUI
import Contacts
import ContactsUI

struct ContactDetailView: UIViewControllerRepresentable {
    let contact: CNContact
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = CNContactViewController(for: contact)
        vc.allowsEditing = true
        vc.delegate = context.coordinator
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }

    class Coordinator: NSObject, CNContactViewControllerDelegate {
        var parent: ContactDetailView

        init(_ parent: ContactDetailView) {
            self.parent = parent
        }

        func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
            parent.dismiss()
        }
    }
}
