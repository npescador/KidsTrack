import Domain
import Presentation
import Shared
import Testing

@MainActor
@Suite("CreateSchoolSlotViewModel")
struct CreateSchoolSlotViewModelTests {
    @Test("Selects first child by default")
    func selectsFirstChild() async throws {
        let family = Family(id: "fam-1", name: "Family", ownerId: "owner")
        let children = [Child(id: "child-1", familyId: family.id, name: "Alex")]
        let vm = CreateSchoolSlotViewModel(
            family: family,
            children: children,
            initialChild: nil,
            createSchoolSlot: CreateSchoolSlotUseCase(repository: PreviewScheduleRepository())
        )

        #expect(vm.selectedChildId == children.first?.id)
        #expect(vm.isFormValid == false)
        vm.subject = "Math"
        #expect(vm.isFormValid)
    }

    @Test("Keeps selected child when list changes")
    func keepsSelectedChildOnUpdate() async throws {
        let family = Family(id: "fam-1", name: "Family", ownerId: "owner")
        let childA = Child(id: "child-1", familyId: family.id, name: "Alex")
        let childB = Child(id: "child-2", familyId: family.id, name: "Sam")
        let vm = CreateSchoolSlotViewModel(
            family: family,
            children: [childA, childB],
            initialChild: childB,
            createSchoolSlot: CreateSchoolSlotUseCase(repository: PreviewScheduleRepository())
        )

        #expect(vm.selectedChildId == childB.id)
        vm.updateChildren([childA])
        #expect(vm.selectedChildId == childA.id)
    }
}
