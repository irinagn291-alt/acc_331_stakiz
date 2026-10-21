import SwiftUI

struct PetsSheet: View {
    @ObservedObject var vault: JauntVault
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocused: Bool
    @State private var name = ""
    @State private var shareImage: UIImage?

    var body: some View {
        NavigationStack {
            Group {
                if let error = vault.loadError {
                    retry(error) { vault.retryLoad() }
                        .padding(ThemeTokens.space * 2)
                } else if vault.ledger.pets.isEmpty {
                    VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                        Image("chl_EmptyHouseholdCutout")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 280)
                            .accessibilityHidden(true)
                        Text("No pets yet.")
                            .font(ThemeTokens.font(.display))
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Add a pet and a chore.")
                            .font(ThemeTokens.font(.body))
                            .foregroundStyle(DesignTokens.ink)
                        Spacer(minLength: ThemeTokens.space)
                        addField
                    }
                    .padding(ThemeTokens.space * 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    List {
                        Section { addField }
                        Section {
                            ForEach(vault.ledger.pets) { pet in
                                VStack(alignment: .leading, spacing: ThemeTokens.space) {
                                    Text(pet.name)
                                        .font(ThemeTokens.font(.title))
                                        .foregroundStyle(DesignTokens.ink)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    if let tag = vault.ledger.tags.first(where: { $0.petID == pet.id }) {
                                        Text(tag.code)
                                            .font(ThemeTokens.font(.body))
                                            .foregroundStyle(DesignTokens.muted)
                                            .lineLimit(1)
                                        Button("Print collar sheet") {
                                            shareImage = TagSheetPrinter.image(code: tag.code, name: pet.name)
                                        }
                                        .frame(minHeight: 44)
                                    }
                                }
                                .padding(.vertical, ThemeTokens.space)
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .background(DesignTokens.bg)
            .navigationTitle("Pets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .frame(minHeight: 44)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { nameFocused = false }
                }
            }
            .sheet(isPresented: Binding(get: { shareImage != nil }, set: { if !$0 { shareImage = nil } })) {
                if let shareImage {
                    ShareLink(item: Image(uiImage: shareImage), preview: SharePreview("Collar sheet", image: Image(uiImage: shareImage))) {
                        Text("Share collar sheet")
                    }
                    .padding(ThemeTokens.space * 3)
                    .presentationDetents([.medium])
                }
            }
        }
    }

    private var addField: some View {
        VStack(alignment: .leading, spacing: ThemeTokens.space) {
            TextField("Pet name", text: $name)
                .font(ThemeTokens.font(.body))
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .focused($nameFocused)
                .frame(minHeight: 44)
            Button("Add pet") {
                vault.addPet(name: name)
                name = ""
                nameFocused = false
            }
            .buttonStyle(ProminentPressStyle())
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}

/// Cover name for the pet roster. The sheet owns the stack.
struct PetScreen: View {
    @ObservedObject var vault: JauntVault

    var body: some View {
        PetsSheet(vault: vault)
    }
}
