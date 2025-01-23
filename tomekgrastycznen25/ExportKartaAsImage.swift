//
//  ExportKartaAsImage.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 23/01/2025.
//
import SwiftUI
#if os(macOS)
    func saveAndShareImage(image: NSImage, playerName: String) {
        // Ensure the filename is descriptive and ends with .png
        let sanitizedPlayerName = playerName.replacingOccurrences(of: " ", with: "_")
        let fileName = "\(sanitizedPlayerName).png"

        do {
            let tempURL = try saveImageWithMetadata(image: image, fileName: fileName)

            // Create a sharing service picker
            let sharingPicker = NSSharingServicePicker(items: [tempURL])
            
            // Display the picker relative to a view (assuming you have access to a `NSView` instance)
            if let keyWindow = NSApplication.shared.keyWindow,
               let contentView = keyWindow.contentView {
                sharingPicker.show(relativeTo: contentView.bounds, of: contentView, preferredEdge: .minY)
            }
        } catch {
            print("Failed to write image to file: \(error)")
        }
    }

    // Helper function to save the image with metadata
    func saveImageWithMetadata(image: NSImage, fileName: String) throws -> URL {
        // Create a temporary directory for saving the file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)

        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            throw NSError(domain: "SaveErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create PNG data"])
        }

        try pngData.write(to: fileURL)
        return fileURL
    }
    #else

    func saveImageWithMetadata(image: UIImage, fileName: String) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        guard let imageData = image.pngData(),
              let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let type = CGImageSourceGetType(source) else {
            print("Failed to create image source")
            return nil
        }

        let metadata = NSMutableDictionary()
        metadata[kCGImagePropertyTIFFDictionary as String] = [
            kCGImagePropertyTIFFArtist as String: "SwiftUI App",
            kCGImagePropertyTIFFSoftware as String: "Custom Renderer"
        ]

        guard let destination = CGImageDestinationCreateWithURL(tempURL as CFURL, type, 1, nil) else {
            print("Failed to create image destination")
            return nil
        }

        CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
        if CGImageDestinationFinalize(destination) {
            print("Image with metadata saved at \(tempURL)")
            return tempURL
        } else {
            print("Failed to save image with metadata")
            return nil
        }
    }

    func saveAndShareImage(image: UIImage, playerName: String) {
        // Ensure the filename is descriptive and ends with .png
        let sanitizedPlayerName = playerName.replacingOccurrences(of: " ", with: "_")
        let fileName = "\(sanitizedPlayerName).png"


        do {
            let tempURL = saveImageWithMetadata(image: image, fileName: fileName)
            // Present the share sheet
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)

            // For iPad, set the sourceView and sourceRect to avoid crashes
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                if let popoverController = activityVC.popoverPresentationController {
                    popoverController.sourceView = rootVC.view
                    popoverController.sourceRect = CGRect(
                        x: rootVC.view.bounds.midX,
                        y: rootVC.view.bounds.midY,
                        width: 0,
                        height: 0
                    )
                    popoverController.permittedArrowDirections = []
                }
                rootVC.present(activityVC, animated: true, completion: nil)
            }
        } catch {
            print("Failed to write image to file: \(error)")
        }
    }
#endif
