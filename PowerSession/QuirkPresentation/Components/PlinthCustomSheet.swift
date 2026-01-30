import SwiftUI
import UIKit

struct PlinthCustomSheet<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let content: Content
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor(red: 0, green: 0x2C/255.0, blue: 0x71/255.0, alpha: 1)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let hostingController = UIHostingController(rootView: content)
            hostingController.view.backgroundColor = UIColor(red: 0, green: 0x2C/255.0, blue: 0x71/255.0, alpha: 1)
            
            if let sheet = hostingController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = false
            }
            
            uiViewController.present(hostingController, animated: true)
        } else if !isPresented && uiViewController.presentedViewController != nil {
            uiViewController.dismiss(animated: true)
        }
    }
}

extension View {
    func murkyCustomSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        background(
            PlinthCustomSheet(isPresented: isPresented, content: content())
        )
    }
}

