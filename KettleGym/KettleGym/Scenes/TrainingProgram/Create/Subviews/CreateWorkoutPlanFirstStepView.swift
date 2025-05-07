//
//  WorkoutPlan.swift
//  KettleGym
//
//  Created by joao gabriel medeiros pereira on 15/04/25.
//
import SwiftUI
import Zenith
import ZenithCoreInterface

@Observable
final class CreateWorkoutPlanBasicInfoViewModel: Equatable {
    var name = String()
    var selectedItems: Set<String> = []
    var startDate = Date()
    var uniqueSetPlan: SetPlan? = nil
    var showStartDate = false
    
    init(
        name: String = "",
        selectedItems: Set<String> = [],
        startDate: Date? = nil,
        uniqueSetPlan: SetPlan? = nil
    ) {
        self.name = name
        self.selectedItems = selectedItems
        if let startDate = startDate {
            self.startDate = startDate
            self.showStartDate = true
        } else {
            self.showStartDate = false
            self.startDate = Date()
        }
        self.uniqueSetPlan = uniqueSetPlan
    }
    
    static func == (lhs: CreateWorkoutPlanBasicInfoViewModel, rhs: CreateWorkoutPlanBasicInfoViewModel) -> Bool {
        lhs.name == rhs.name &&
        lhs.selectedItems == rhs.selectedItems &&
        lhs.startDate == rhs.startDate &&
        lhs.uniqueSetPlan?.name == rhs.uniqueSetPlan?.name
    }
}

typealias BasicInfoCompletion = (CreateWorkoutPlanBasicInfoViewModel) -> Void

struct CreateWorkoutPlanBasicInfoView: View, BaseThemeDependencies {
    @Environment(Router<WorkoutPlanRoute>.self) var workoutPlanRoute
    @Environment(ToastModel.self) var toast
    @State private var sheetModel = GridSheetModel(items: [])
    @State var setPlans: [SetPlan]
    @Binding var viewModel: CreateWorkoutPlanBasicInfoViewModel
    let completion: BasicInfoCompletion
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    init(
        viewModel: Binding<CreateWorkoutPlanBasicInfoViewModel>,
        setPlans: [SetPlan] = .mocks(),
        completion: @escaping BasicInfoCompletion
    ) {
        self._viewModel = viewModel
        self.setPlans = setPlans
        self.completion = completion
    }
    
    var body: some View {
        Group {
            TextField(String(), text: $viewModel.name)
                .textfieldStyle(.contentA(.enabled), placeholder: "Nome")
            
            Text("Dias de Treino")
                .textStyle(.small(.highlightA))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, spacings.medium)
                .padding(.bottom, spacings.small)
            CheckBoxBundle(
                selectedItems: $viewModel.selectedItems,
                items: [
                    .init(
                        placeholder: "Seg",
                        id: "1"
                    ),
                    .init(
                        placeholder: "Ter",
                        id: "2"
                    ),
                    .init(
                        placeholder: "Qua",
                        id: "3"
                    ),
                    .init(
                        placeholder: "Qui",
                        id: "4"
                    ),
                    .init(
                        placeholder: "Sex",
                        id: "5"
                    ),
                    .init(
                        placeholder: "Sab",
                        id: "6"
                    ),
                    .init(
                        placeholder: "Dom",
                        id: "7"
                    )
                ]
            )
            .padding(.bottom, spacings.small)
            Toggle(isOn: $viewModel.showStartDate) {
                Text("Configurar Data de Início")
                    .textStyle(.small(.contentA))
            }
            .toggleStyle(.default(.highlightA))
            .padding(.bottom, spacings.small)
            if viewModel.showStartDate {
                DatePicker(
                    "Data de Início",
                    selection: $viewModel.startDate,
                    displayedComponents: .date
                )
            }
            uniqueSetPlanView
        }
        .gridSheet(
            model: $sheetModel,
            setPlanCreated: { quantity, minRep, maxRep in
                guard let quantity = Int(quantity), let minRep = Int(minRep), let maxRep = Int(maxRep) else { return }
                let selectedSetPlan = SetPlan(quantity: quantity, minRep: minRep, maxRep: maxRep)
                setPlans.append(selectedSetPlan)
                sheetModel.set(items: setPlans.compactMap { $0.name })
            },
            setPlanRemoved: { setPlan in
                if let setPlan = self.setPlans.first(where: { $0.name == setPlan }) {
                    if setPlan.name == viewModel.uniqueSetPlan?.name {
                        viewModel.uniqueSetPlan = nil
                    }
                    
                    setPlans.removeAll(where: { $0.name == setPlan.name })
                    sheetModel.set(items: setPlans.compactMap { $0.name })
                }
            }) { selectedSetPlan in
                viewModel.uniqueSetPlan = self.setPlans.first(where: { $0.name == selectedSetPlan })
                self.sheetModel.dismiss()
            }
            .onChange(of: viewModel.showStartDate) {
                sendCompletion()
            }
            .onChange(of: viewModel.name) {
                sendCompletion()
            }
            .onChange(of: viewModel.startDate) {
                sendCompletion()
            }
            .onChange(of: viewModel.uniqueSetPlan) {
                sendCompletion()
            }
            .onChange(of: viewModel.selectedItems) {
                sendCompletion()
            }
    }
    
    var uniqueSetPlanView: some View {
        Group {
            Button {
                sheetModel.set(items: setPlans.compactMap { $0.name })
            } label: {
                HStack {
                    Text("Escolher Série unica")
                        .textStyle(.small(.contentA))
                    Image(systemSymbol: .questionmarkCircle)
                        .onTapGesture {
                            toast.showInfo(
                                title:"Informativo",
                                message: "Está série será aplicada para todos os exercícios do treino"
                            )
                        }
                    Spacer()
                    if let name = viewModel.uniqueSetPlan?.name {
                        ChipView(label: name, isSelected: false, style: .small) { name in
                            viewModel.uniqueSetPlan = nil
                        }
                    } else {
                        Color.clear
                            .frame(width: 20, height: 28)
                    }
                    Image(systemSymbol: .chevronRight)
                        .foregroundColor(.gray)
                }
            }
            .foregroundStyle(Color.primary)
        }
    }
    
    func sendCompletion() {
        let startDate = viewModel.showStartDate ? viewModel.startDate : nil
        print(viewModel.name, viewModel.showStartDate, viewModel.startDate, viewModel.uniqueSetPlan, viewModel.selectedItems)
        completion(viewModel)
    }
}
