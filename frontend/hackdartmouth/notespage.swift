import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import Vision

struct NotesPage: View {
    @State private var selectedImage: UIImage? = nil
    @State private var showDocumentPicker = false
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    @State private var showSummarySheet = false
    @State private var summaryText = ""
    @State private var showOptionsDialog = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Upload box
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                        .foregroundColor(.orange)
                        .frame(width: 320, height: 250)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 6)

                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 230)
                            .cornerRadius(15)
                    } else {
                        VStack {
                            Image(systemName: "plus")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            Text("Upload Notes")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .onTapGesture {
                    showOptions()
                }
                .padding(.top, 40)

                // Upload button
                Button(action: {
                    showOptions()
                }) {
                    Text("Select From Photos / Files")
                        .font(.headline)
                        .frame(width: 300, height: 90)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }

                // Summarize Button
                Button(action: {
                    summarizeNotes()
                }) {
                    Text("Summarize Notes ✨")
                        .font(.headline)
                        .frame(width: 300, height: 90)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
            .background(Color(red: 249/255, green: 244/255, blue: 233/255)) // creamy background inside NavigationView
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color(red: 249/255, green: 244/255, blue: 233/255)) // creamy background outside too
        .confirmationDialog("Select Source", isPresented: $showOptionsDialog, titleVisibility: .visible) {
            Button("Camera") { pickFromCamera() }
            Button("Photo Library") { pickFromLibrary() }
            Button("Files") { showDocumentPicker = true }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: sourceType) { image in
                self.selectedImage = image
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { images in
                self.selectedImage = images.first
            }
        }

        .sheet(isPresented: $showSummarySheet) {
            SummarySheet(summaryText: summaryText)
        }
    }

    func showOptions() {
        showOptionsDialog = true
    }

    func pickFromCamera() {
        sourceType = .camera
        showImagePicker = true
    }

    func pickFromLibrary() {
        sourceType = .photoLibrary
        showImagePicker = true
    }

    func summarizeNotes() {
        guard let image = selectedImage else { return }
 // ⚡ pick first uploaded image
        
        recognizeText(from: image) { recognizedText in
            guard let recognizedText = recognizedText else {
                print("❌ Failed to recognize text")
                return
            }
            
            print("✅ OCR Recognized Text:", recognizedText) // See what OCR reads
            
            GeminiAPI.summarize(text: recognizedText) { result in
                DispatchQueue.main.async {
                    if let result = result {
                        print("✅ Gemini Summary:", result) // See what Gemini responds
                        self.summaryText = result // Put result inside the sheet
                        self.showSummarySheet = true // Open the sheet
                    } else {
                        print("❌ Failed to get summary from Gemini")
                    }
                }
            }
        }
    }


    
    func recognizeText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            if let observations = request.results as? [VNRecognizedTextObservation] {
                let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                completion(text)
            } else {
                completion(nil)
            }
        }

        do {
            try requestHandler.perform([request])
        } catch {
            completion(nil)
        }
    }
}
