import Domain
import Foundation
import Shared
import Testing

@Suite("CreateSchoolSlotUseCase")
struct CreateSchoolSlotUseCaseTests {
    private var repository: MockScheduleRepository { MockScheduleRepository() }

    @Test("Fails when subject is empty")
    func emptySubjectThrows() async {
        let repo = repository
        let useCase = CreateSchoolSlotUseCase(repository: repo)
        let request = CreateSchoolSlotRequest(
            familyId: "fam-1",
            childId: "child-1",
            weekday: .monday,
            startTime: DateComponents(hour: 9, minute: 0),
            endTime: DateComponents(hour: 10, minute: 0),
            subject: "  "
        )

        do {
            _ = try await useCase.execute(request)
            Issue.record("Expected validation error")
        } catch {
            #expect(error as? SchoolSlotValidationError == .emptySubject)
        }
    }

    @Test("Fails when child is missing")
    func missingChildThrows() async {
        let repo = repository
        let useCase = CreateSchoolSlotUseCase(repository: repo)
        let request = CreateSchoolSlotRequest(
            familyId: "fam-1",
            childId: " ",
            weekday: .monday,
            startTime: DateComponents(hour: 9, minute: 0),
            endTime: DateComponents(hour: 10, minute: 0),
            subject: "Math"
        )

        do {
            _ = try await useCase.execute(request)
            Issue.record("Expected validation error")
        } catch {
            #expect(error as? SchoolSlotValidationError == .missingChild)
        }
    }

    @Test("Fails when end time is before start time")
    func invalidTimeRangeThrows() async {
        let repo = repository
        let useCase = CreateSchoolSlotUseCase(repository: repo)
        let request = CreateSchoolSlotRequest(
            familyId: "fam-1",
            childId: "child-1",
            weekday: .monday,
            startTime: DateComponents(hour: 11, minute: 0),
            endTime: DateComponents(hour: 10, minute: 0),
            subject: "Science"
        )

        do {
            _ = try await useCase.execute(request)
            Issue.record("Expected validation error")
        } catch {
            #expect(error as? SchoolSlotValidationError == .invalidTimeRange)
        }
    }

    @Test("Trims subject and room before persisting")
    func trimsFieldsBeforeSaving() async throws {
        let repo = repository
        let useCase = CreateSchoolSlotUseCase(repository: repo)
        let request = CreateSchoolSlotRequest(
            familyId: "fam-1",
            childId: "child-1",
            weekday: .tuesday,
            startTime: DateComponents(hour: 8, minute: 30),
            endTime: DateComponents(hour: 9, minute: 15),
            subject: "  Math  ",
            room: " 101 "
        )

        let slot = try await useCase.execute(request)
        #expect(slot.subject == "Math")
        #expect(slot.room == "101")
        #expect(repo.createdRequest?.subject == "Math")
        #expect(repo.createdRequest?.room == "101")
    }
}
