import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    var onImagesPicked: ([UIImage]) -> Void  // 🔥 Notice: now [UIImage]

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.image], asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true // 🔥 allow multiple selection
        return picker
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(onImagesPicked: onImagesPicked)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onImagesPicked: ([UIImage]) -> Void

        init(onImagesPicked: @escaping ([UIImage]) -> Void) {
            self.onImagesPicked = onImagesPicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            var images: [UIImage] = []
            for url in urls {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            onImagesPicked(images) // 🔥 send all images
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { }
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}
