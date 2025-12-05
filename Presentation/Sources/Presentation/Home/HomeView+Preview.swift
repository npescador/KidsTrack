import Domain
import Shared
import SwiftUI

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            viewModel: .preview(),
            onManageFamilies: {},
            onOpenActivities: {},
            onOpenExpenses: {},
            onLogout: {},
            makeCreateChildViewModel: { family in
                .preview(family: family)
            },
            makeEditChildViewModel: { family, child in
                CreateChildViewModel(
                    family: family,
                    createChild: CreateChildUseCase(repository: PreviewChildrenRepository()),
                    updateChild: UpdateChildUseCase(repository: PreviewChildrenRepository()),
                    existingChild: child
                )
            },
            makeDeleteChildViewModel: { family, child in
                DeleteChildViewModel.preview(family: family, child: child)
            },
            makeCreateSchoolSlotViewModel: { family, children, child in
                CreateSchoolSlotViewModel(
                    family: family,
                    children: children,
                    initialChild: child ?? children.first,
                    createSchoolSlot: CreateSchoolSlotUseCase(repository: PreviewScheduleRepository())
                )
            }
        )
    }
}
#endif
