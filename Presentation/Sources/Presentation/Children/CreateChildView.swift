import Shared
import SwiftUI

public struct CreateChildView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var viewModel: CreateChildViewModel
    private let onSaved: (Child) -> Void
    private let onCancel: () -> Void

    private let colorOptions: [String] = [
        "#4A90E2", "#1ABC9C", "#FF3B30", "#F5A524", "#A259FF", "#2ECC71", "#FF6B6B"
    ]

    public init(
        viewModel: CreateChildViewModel,
        onSaved: @escaping (Child) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
        self.onCancel = onCancel
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        Form {
            Section(header: Text("child.form.section.info".localizedText())) {
                TextField("child.form.name.placeholder".localizedText(), text: $viewModel.name)
                    .textContentType(.name)
                TextField("child.form.grade.placeholder".localizedText(), text: $viewModel.grade)
                    .textContentType(.none)
                Toggle(isOn: $viewModel.includeBirthDate) {
                    Text("child.form.birthdate.label".localizedText())
                }
                if viewModel.includeBirthDate {
                    DatePicker(
                        "",
                        selection: $viewModel.birthDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                }
            }

            Section(header: Text("child.form.color.label".localizedText())) {
                colorPalette(selected: viewModel.selectedColorHex) { selected in
                    viewModel.selectedColorHex = selected
                }
                if let selected = viewModel.selectedColorHex,
                   let color = Color(hex: selected) {
                    HStack {
                        Circle()
                            .fill(color)
                            .frame(width: 22, height: 22)
                        Text(selected.uppercased())
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        Spacer()
                        Button("child.form.color.clear".localizedText()) {
                            viewModel.selectedColorHex = nil
                        }
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                    }
                } else {
                    Text("child.form.color.helper".localizedText())
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if let error = viewModel.error {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }

            Section {
                Button {
                    viewModel.submit(onSaved: onSaved)
                } label: {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(submitLabel)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.isFormValid)

                Button("child.form.cancel".localizedText(), role: .cancel, action: onCancel)
            }
        }
        .navigationTitle(Text(formTitle))
    }
}

private extension CreateChildView {
    var formTitle: String {
        viewModel.isEditing ? "child.form.title.edit".localizedText() : "child.form.title".localizedText()
    }

    var submitLabel: String {
        viewModel.isEditing ? "child.form.submit.edit".localizedText() : "child.form.submit".localizedText()
    }

    func colorPalette(selected: String?, onSelect: @escaping (String?) -> Void) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(colorOptions, id: \.self) { hex in
                    let color = Color(hex: hex) ?? .gray
                    Button {
                        if selected == hex {
                            onSelect(nil)
                        } else {
                            onSelect(hex)
                        }
                    } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 32, height: 32)
                            .overlay {
                                if selected == hex {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .overlay(
                                Circle()
                                    .stroke(
                                        selected == hex ? Color.kidsTrackBorder(for: colorScheme) : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(hex))
                }
            }
            .padding(.vertical, 6)
        }
    }
}
