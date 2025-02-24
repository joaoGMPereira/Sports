import Zenith
import ZenithCore
import SwiftData
import SFSafeSymbols
import SwiftUI

enum StateSaving {
    case writing
    case save
    case edit
    case error
}

extension Optional<Int> {
    var stringValue: String {
        guard let self else { return "" }
        return String(self)
    }
}

struct CreateExerciseData {
    let items: [String]
    let hasJustName: Binding<Bool>
    let name: String?
    let setPlan: SetPlan?
}

struct CreateExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var name: String
    private var items: [String]
    @State var filteredItems: [String] = []
    @State var state: StateSaving = .writing
    @Binding var hasJustName: Bool
    @State private var showPopover = false
    @State private var setPlanSheetModel = GridSheetModel(items: [])
    @State private var exerciseSheetModel = GridSheetModel(items: [])
    @Query private var fetchedSetPlans: [SetPlan]
    @State private var setPlan: SetPlan? = nil
    
    var completion: ((
        _ name: String,
        _ setPlan: SetPlan?
    ) -> Void)
    
    var exerciseCreateCompletion: ((
        _ name: String
    ) -> Void)
    
    var exerciseDeleteCompletion: ((
        _ name: String
    ) -> Void)
    
    var image: SFSymbol {
        switch state {
        case .writing:
                .scribble
        case .save:
                .checkmark
        case .edit:
                .pencil
        case .error:
                .xmark
        }
    }
    
    var color: Color {
        switch state {
        case .writing:
                .primary
        case .save:
                .green
        case .edit:
                .yellow
        case .error:
                .red
        }
    }
    
    init(
        data: CreateExerciseData,
        completion: @escaping ((
            _ name: String,
            _ setPlan: SetPlan?
        ) -> Void),
        exerciseCreateCompletion: @escaping ((
            _ name: String
        ) -> Void),
        exerciseDeleteCompletion: @escaping ((
            _ name: String
        ) -> Void)
    ) {
        _name = State(initialValue: data.name ?? String())
        _setPlan = State(initialValue: data.setPlan)
        
        let hasFilledInfo = data.name.isNotEmpty && data.setPlan != nil
        _state = State(initialValue: hasFilledInfo ? .save : .writing)
        
        self.items = data.items
        self._hasJustName = data.hasJustName
        self.completion = completion
        self.exerciseCreateCompletion = exerciseCreateCompletion
        self.exerciseDeleteCompletion = exerciseDeleteCompletion
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemSymbol: image)
                    .foregroundStyle(color)
            }
            SelectionView(title: "Escolher Exercício", selectedTitle: $name) {
                exerciseSheetModel.set(items: items)
            }
            .padding(.vertical, 16)
            if hasJustName == false {
                SelectionView(title: "Escolher Série", selectedTitle: $name) {
                    exerciseSheetModel.set(items: items)
                }
                .padding(.bottom, 16)
            }
            Button(state == .save ? "Editar" : "Salvar") {
                setPlanAction()
            }
            .buttonStyle(WithoutBackgroundPrimaryButtonStyle())
        }
        .gridSheet(
            model: $setPlanSheetModel,
            setPlanCreated: { quantity, minRep, maxRep in
                guard let quantity = Int(quantity), let minRep = Int(minRep), let maxRep = Int(maxRep) else { return }
                let selectedSetPlan = SetPlan(quantity: quantity, minRep: minRep, maxRep: maxRep)
                
                modelContext.insert(selectedSetPlan)
                try? modelContext.save()
                setPlanSheetModel.set(items: fetchedSetPlans.compactMap { $0.name })
            },
            setPlanRemoved: { setPlan in
                if let setPlan = self.fetchedSetPlans.first(where: { $0.name == setPlan }) {
                    if setPlan.name == self.setPlan?.name {
                        self.setPlan = nil
                    }
                    modelContext.delete(setPlan)
                    try? modelContext.save()
                    setPlanSheetModel.set(items: fetchedSetPlans.compactMap { $0.name })
                }
            }) { selectedSetPlan in
                self.setPlan = self.fetchedSetPlans.first(where: { $0.name == selectedSetPlan })
                self.setPlanSheetModel.dismiss()
            }
            .gridSheet(
                title: "Criar Exercício",
                model: $exerciseSheetModel,
                created: { name in
                    self.name = name
                    self.exerciseSheetModel.dismiss()
                    self.exerciseCreateCompletion(name)
                    exerciseSheetModel.items.append(name)
                },
                removed: { name in
                    if let name = self.items.first(where: { $0 == name }) {
                        if name == self.name {
                            self.name = ""
                        }
                        self.exerciseDeleteCompletion(name)
                        exerciseSheetModel.items.removeAll(where: { $0 == name })
                    }
                }) { name in
                    self.name = name
                    self.exerciseSheetModel.dismiss()
                }
                .onChange(of: hasJustName, {
                    if hasJustName {
                        self.setPlan = nil
                    }
                })
                .padding(4)
    }
    
    private func setPlanAction() {
        var hasFilledInfo = name.isNotEmpty && setPlan != nil
        if hasJustName {
            hasFilledInfo = name.isNotEmpty
        }
        if hasFilledInfo {
            if state == .writing || state == .error || state == .edit {
                state = .save
                completion(name, setPlan)
                return
            }
            
            if state == .save {
                state = .edit
                return
            }
            
        } else {
            state = .error
        }
    }
    
    private func applyFilter(with text: String) {
        if text.isEmpty {
            filteredItems = []
            showPopover = false
        } else {
            filteredItems = items.filter { $0.localizedCaseInsensitiveContains(text) &&  $0.trimmingCharacters(in: .whitespaces).isNotEmpty }
            showPopover = filteredItems.count > 0
        }
    }
}
