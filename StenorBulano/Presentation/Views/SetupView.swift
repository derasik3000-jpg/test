import SwiftUI

struct SetupView: View {
    @StateObject var viewModel: SetupViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 24) {
                Text("Rename Envelopes")
                    .font(Typography.h1())
                    .foregroundColor(ColorTheme.Text.inverse)
                    .padding(.top, 40)
                
                Text("Names apply to current week only")
                    .font(Typography.body())
                    .foregroundColor(ColorTheme.Text.secondaryInverse)
                
                VStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Envelope \(index + 1)")
                                .font(Typography.caption())
                                .foregroundColor(ColorTheme.Text.secondaryInverse)
                            
                            TextField("Name", text: $viewModel.names[index])
                                .font(Typography.body())
                                .padding()
                                .background(ColorTheme.Background.raised)
                                .cornerRadius(12)
                                .foregroundColor(ColorTheme.Text.primary)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    viewModel.save {
                        NotificationCenter.default.post(name: NSNotification.Name("EnvelopesUpdated"), object: nil)
                        dismiss()
                    }
                }) {
                    Text("Save")
                        .font(Typography.body())
                        .foregroundColor(ColorTheme.Button.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(ColorTheme.Button.fill)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.load()
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

