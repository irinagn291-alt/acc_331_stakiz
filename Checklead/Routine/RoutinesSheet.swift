import SwiftUI

struct RoutinesSheet: View {
    @ObservedObject var vault: JauntVault
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool
    @State private var label = ""
    @State private var window = "Morning"
    @State private var petID: UUID?

    var body: some View {
        NavigationStack {
            Group {
                if let error = vault.loadError {
                    retry(error) { vault.retryLoad() }
                        .padding(ThemeTokens.space * 2)
                } else if vault.ledger.routines.isEmpty {
                    VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                        Image("chl_TwistHero")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 240)
                            .accessibilityHidden(true)
                        Text("No chores yet.")
                            .font(ThemeTokens.font(.display))
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Add a pet and a chore.")
                            .font(ThemeTokens.font(.body))
                            .foregroundStyle(DesignTokens.ink)
                        Spacer(minLength: ThemeTokens.space)
                        editor
                    }
                    .padding(ThemeTokens.space * 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    List {
                        Section { editor }
                        Section {
                            ForEach(vault.ledger.routines) { routine in
                                VStack(alignment: .leading, spacing: ThemeTokens.space) {
                                    TextField("Chore name", text: Binding(
                                        get: { routine.label },
                                        set: { vault.updateRoutineLabel(routine.id, label: $0) }
                                    ))
                                    .font(ThemeTokens.font(.body))
                                    .focused($focused)
                                    Text(vault.ledger.pets.first { $0.id == routine.petID }?.name ?? "")
                                        .font(ThemeTokens.font(.body))
                                        .foregroundStyle(DesignTokens.muted)
                                        .lineLimit(1)
                                    Text(routine.window)
                                        .font(ThemeTokens.font(.body))
                                        .foregroundStyle(DesignTokens.ink)
                                        .lineLimit(1)
                                    Toggle("Active today", isOn: Binding(
                                        get: { routine.isActive },
                                        set: { vault.setRoutineActive(routine.id, active: $0) }
                                    ))
                                    .frame(minHeight: 44)
                                }
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .navigationTitle("Chores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.frame(minHeight: 44)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = false }
                }
            }
            .onAppear { petID = vault.ledger.pets.first?.id }
        }
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: ThemeTokens.space) {
            if vault.ledger.pets.isEmpty {
                Text("Add a pet first.")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
            } else {
                Picker("Pet", selection: $petID) {
                    ForEach(vault.ledger.pets) { pet in
                        Text(pet.name).tag(Optional(pet.id))
                    }
                }
                TextField("Chore name", text: $label)
                    .font(ThemeTokens.font(.body))
                    .focused($focused)
                    .frame(minHeight: 44)
                TextField("Time window", text: $window)
                    .font(ThemeTokens.font(.body))
                    .focused($focused)
                    .frame(minHeight: 44)
                Button("Add chore") {
                    if let petID { vault.addRoutine(petID: petID, label: label, window: window) }
                    label = ""
                    focused = false
                }
                .buttonStyle(ProminentPressStyle())
                .disabled(label.trimmingCharacters(in: .whitespaces).isEmpty || petID == nil)
            }
        }
    }
}

/// Cover name for chore templates.
struct RoutineScreen: View {
    @ObservedObject var vault: JauntVault

    var body: some View {
        RoutinesSheet(vault: vault)
    }
}
