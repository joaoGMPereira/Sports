import DesignSystem
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
    let setPlans: Int?
    let minRep: Int?
    let maxRep: Int?
}

struct CreateExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var name: String
    @State private var quantity: String
    @State private var minRep: String
    @State private var maxRep: String
    private var items: [String]
    @State var filteredItems: [String] = []
    @State var state: StateSaving = .writing
    @Binding var hasJustName: Bool
    @State private var showPopover = false
    @State private var sheetModel = GridSheetModel(items: [])
    @Query private var fetchedSetPlans: [SetPlan]
    @State private var setPlan: SetPlan? = nil
    
    var completion: ((
        _ name: String,
        _ setPlan: SetPlan?
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
        ) -> Void)
    ) {
        _name = State(initialValue: data.name ?? String())
        _quantity = State(initialValue: data.setPlans.stringValue)
        _minRep = State(initialValue: data.minRep.stringValue)
        _maxRep = State(initialValue: data.maxRep.stringValue)
        let hasFilledInfo = data.name.isNotEmpty && data.setPlans.stringValue.isNotEmpty && data.minRep.stringValue.isNotEmpty && data.maxRep.stringValue.isNotEmpty
        _state = State(initialValue: hasFilledInfo ? .save : .writing)
        
        self.items = data.items
        self._hasJustName = data.hasJustName
        self.completion = completion
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemSymbol: image)
                    .foregroundStyle(color)
            }
            TextField("Nome", text: $name)
                .textFieldStyle(DSStateTextFieldStyle(isEnabled: state != .save))
                .onChange(of: name) {
                    self.applyFilter(with: name)
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            self.showPopover = items.isNotEmpty
                        }
                )
                .popover(
                    isPresented: $showPopover,
                    attachmentAnchor: .point(
                        .top
                    )
                ) {
                    ChipGridView(
                        chips: (
                            .constant(filteredItems.isEmpty ? items.filter(
                                {
                                    $0.trimmingCharacters(
                                        in: .whitespaces
                                    ).isNotEmpty
                                }) : filteredItems
                        ))
                    ) { item in
                        self.name = item
                        DispatchQueue.main.async {
                            showPopover = false
                        }
                        hideKeyboard()
                    }
                    .padding()
                    .frame(minWidth: 50, minHeight: 80, maxHeight: 400)
                    .presentationCompactAdaptation(.popover)
                }
            if hasJustName == false {
                Group {
                    Button {
                        sheetModel.set(items: fetchedSetPlans.compactMap { $0.name })
                    } label: {
                        HStack {
                            Text("Escolher Série")
                            Spacer()
                            if let name = setPlan?.name {
                                ChipView(label: name, isSelected: false, style: .small) { name in
                                    setPlan = nil
                                }
                            }
                            Image(systemSymbol: .chevronRight)
                                .foregroundColor(.gray)
                        }
                    }
                    .foregroundStyle(Color.primary)
                }
            }
            Button(state == .save ? "Editar" : "Salvar") {
                setPlanAction()
            }
            .buttonStyle(WithoutBackgroundPrimaryButtonStyle())
        }
        .gridSheet(
            model: $sheetModel,
            setPlanCreated: { quantity, minRep, maxRep in
                guard let quantity = Int(quantity), let minRep = Int(minRep), let maxRep = Int(maxRep) else { return }
                let selectedSetPlan = SetPlan(quantity: quantity, minRep: minRep, maxRep: maxRep)

                modelContext.insert(selectedSetPlan)
                try? modelContext.save()
                sheetModel.set(items: fetchedSetPlans.compactMap { $0.name })
            },
            setPlanRemoved: { setPlan in
                if let setPlan = self.fetchedSetPlans.first(where: { $0.name == setPlan }) {
                    if setPlan.name == self.setPlan?.name {
                        self.setPlan = nil
                    }
                    modelContext.delete(setPlan)
                    try? modelContext.save()
                    sheetModel.set(items: fetchedSetPlans.compactMap { $0.name })
                }
            }) { selectedSetPlan in
                self.setPlan = self.fetchedSetPlans.first(where: { $0.name == selectedSetPlan })
                self.sheetModel.dismiss()
            }
        .onChange(of: hasJustName, {
            if hasJustName {
                self.quantity = String()
                self.minRep = String()
                self.maxRep = String()
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
