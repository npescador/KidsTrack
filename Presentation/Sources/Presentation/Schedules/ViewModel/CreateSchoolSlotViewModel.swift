import Domain
import Foundation
import Observation
import Shared

@MainActor
@Observable
public final class CreateSchoolSlotViewModel: Identifiable {
    public let id = UUID()
    public let family: Family
    public private(set) var children: [Child]
    public var selectedChildId: String?
    public var weekday: Weekday
    public var startTime: Date
    public var endTime: Date
    public var subject: String
    public var room: String
    public private(set) var error: String?
    public private(set) var isSubmitting = false

    private let createSchoolSlot: CreateSchoolSlotUseCase
    private let calendar: Calendar

    public init(
        family: Family,
        children: [Child],
        initialChild: Child?,
        createSchoolSlot: CreateSchoolSlotUseCase,
        calendar: Calendar = .current
    ) {
        self.family = family
        self.children = children
        self.selectedChildId = initialChild?.id ?? children.first?.id
        self.weekday = Self.weekday(for: Date(), calendar: calendar) ?? .monday
        self.startTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        self.endTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        self.subject = ""
        self.room = ""
        self.createSchoolSlot = createSchoolSlot
        self.calendar = calendar
    }

    public var isFormValid: Bool {
        guard !isSubmitting else { return false }
        guard let selectedChildId else { return false }
        guard !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard startTime < endTime else { return false }
        return !selectedChildId.isEmpty
    }

    public func updateChildren(_ children: [Child]) {
        self.children = children
        if let selectedChildId, children.contains(where: { $0.id == selectedChildId }) {
            return
        }
        selectedChildId = children.first?.id
    }

    public func submit(onSaved: @escaping (SchoolSlot) -> Void) {
        guard isFormValid, let childId = selectedChildId else { return }
        isSubmitting = true
        error = nil

        Task {
            let request = CreateSchoolSlotRequest(
                familyId: family.id,
                childId: childId,
                weekday: weekday,
                startTime: calendar.dateComponents([.hour, .minute], from: startTime),
                endTime: calendar.dateComponents([.hour, .minute], from: endTime),
                subject: subject,
                room: room
            )
            do {
                let slot = try await createSchoolSlot.execute(request)
                await MainActor.run {
                    self.isSubmitting = false
                    onSaved(slot)
                }
            } catch {
                await MainActor.run {
                    self.error = map(error)
                    self.isSubmitting = false
                }
            }
        }
    }
}

private extension CreateSchoolSlotViewModel {
    func map(_ error: Error) -> String {
        if let validation = error as? SchoolSlotValidationError {
            switch validation {
            case .missingChild:
                return "schoolSlot.error.child.missing".localizedText()
            case .emptySubject:
                return "schoolSlot.error.subject.empty".localizedText()
            case .invalidTimeRange:
                return "schoolSlot.error.timerange.invalid".localizedText()
            }
        }
        return error.localizedDescription
    }

    static func weekday(for date: Date, calendar: Calendar) -> Weekday? {
        switch calendar.component(.weekday, from: date) {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }
}

#if DEBUG
public extension CreateSchoolSlotViewModel {
    static func preview(family: Family, children: [Child]) -> CreateSchoolSlotViewModel {
        CreateSchoolSlotViewModel(
            family: family,
            children: children,
            initialChild: children.first,
            createSchoolSlot: CreateSchoolSlotUseCase(repository: PreviewScheduleRepository())
        )
    }
}
#endif
