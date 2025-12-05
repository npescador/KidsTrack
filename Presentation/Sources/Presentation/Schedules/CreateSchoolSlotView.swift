import Shared
import SwiftUI

public struct CreateSchoolSlotView: View {

    @State private var viewModel: CreateSchoolSlotViewModel
    private let onSaved: (SchoolSlot) -> Void
    private let onCancel: () -> Void

    public init(
        viewModel: CreateSchoolSlotViewModel,
        onSaved: @escaping (SchoolSlot) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
        self.onCancel = onCancel
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        Form {
            Section(header: Text("schoolSlot.form.section.details".localizedText())) {
                Picker("schoolSlot.form.child.label".localizedText(), selection: $viewModel.selectedChildId) {
                    ForEach(viewModel.children, id: \.id) { child in
                        Text(child.name).tag(Optional(child.id))
                    }
                }

                Picker("schoolSlot.form.weekday.label".localizedText(), selection: $viewModel.weekday) {
                    ForEach(Weekday.allCases, id: \.rawValue) { weekday in
                        Text(weekday.localizedLabel).tag(weekday)
                    }
                }
                .pickerStyle(.segmented)

                DatePicker(
                    "schoolSlot.form.start.label".localizedText(),
                    selection: $viewModel.startTime,
                    displayedComponents: [.hourAndMinute]
                )
                DatePicker(
                    "schoolSlot.form.end.label".localizedText(),
                    selection: $viewModel.endTime,
                    displayedComponents: [.hourAndMinute]
                )
            }

            Section(header: Text("schoolSlot.form.section.meta".localizedText())) {
                TextField("schoolSlot.form.subject.placeholder".localizedText(), text: $viewModel.subject)
                    .textContentType(.none)
                TextField("schoolSlot.form.room.placeholder".localizedText(), text: $viewModel.room)
                    .textContentType(.location)
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
                        Text("schoolSlot.form.submit".localizedText())
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.isFormValid)

                Button("schoolSlot.form.cancel".localizedText(), role: .cancel, action: onCancel)
            }
        }
        .navigationTitle(Text("schoolSlot.form.title".localizedText()))
    }
}

private extension Weekday {
    var localizedLabel: String {
        switch self {
        case .monday: return "weekday.monday".localizedText()
        case .tuesday: return "weekday.tuesday".localizedText()
        case .wednesday: return "weekday.wednesday".localizedText()
        case .thursday: return "weekday.thursday".localizedText()
        case .friday: return "weekday.friday".localizedText()
        case .saturday: return "weekday.saturday".localizedText()
        case .sunday: return "weekday.sunday".localizedText()
        }
    }
}
