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
    @State private var name: String
    @State private var setPlans: String
    @State private var minRep: String
    @State private var maxRep: String
    private var items: [String]
    @State var filteredItems: [String] = []
    @State var state: StateSaving = .writing
    @Binding var hasJustName: Bool
    @State private var showPopover = false
    var completion: ((
        _ name: String,
        _ setPlans: String,
        _ minRep: String,
        _ maxRep: String
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
            _ setPlans: String,
            _ minRep: String,
            _ maxRep: String
        ) -> Void)
    ) {
        _name = State(initialValue: data.name ?? String())
        _setPlans = State(initialValue: data.setPlans.stringValue)
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
                TextField("Series", text: $setPlans)
                    .keyboardType(.numberPad)
                TextField("Repetições Minimas", text: $minRep)
                    .keyboardType(.numberPad)
                TextField("Repetições Máximas", text: $maxRep)
                    .keyboardType(.numberPad)
            }
            Button(state == .save ? "Editar" : "Salvar") {
                var hasFilledInfo = name.isNotEmpty && setPlans.isNotEmpty && minRep.isNotEmpty && maxRep.isNotEmpty
                if hasJustName {
                    hasFilledInfo = name.isNotEmpty
                }
                if hasFilledInfo {
                    if state == .writing || state == .error || state == .edit {
                        state = .save
                        completion(name, setPlans, minRep, maxRep)
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
            .buttonStyle(WithoutBackgroundPrimaryButtonStyle())
        }
        .onChange(of: hasJustName, {
            if hasJustName {
                self.setPlans = String()
                self.minRep = String()
                self.maxRep = String()
            }
        })
        .padding(4)
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
