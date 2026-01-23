import SwiftUI

struct ManageEnvelopesView: View {
    @StateObject var viewModel: ManageEnvelopesViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 24) {
                Text("Manage Envelopes")
                    .font(Typography.h1())
                    .foregroundColor(ColorTheme.Text.inverse)
                    .padding(.top, 40)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(viewModel.envelopes.enumerated()), id: \.element.id) { index, envelope in
                            HStack(spacing: 12) {
                                TextField("Envelope name", text: $viewModel.envelopes[index].name)
                                    .font(Typography.body())
                                    .padding()
                                    .background(ColorTheme.Background.raised)
                                    .cornerRadius(12)
                                    .foregroundColor(ColorTheme.Text.primary)
                                
                                Button(action: {
                                    viewModel.removeEnvelope(at: index)
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(ColorTheme.Accent.accent500)
                                        .frame(width: 44, height: 44)
                                        .background(ColorTheme.Background.raised)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
                        Button(action: {
                            viewModel.addEnvelope()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Envelope")
                                    .font(Typography.body())
                            }
                            .foregroundColor(ColorTheme.Accent.accent500)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(ColorTheme.Background.raised)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                
                Button(action: {
                    viewModel.save {
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

