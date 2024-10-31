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

struct CreateExerciseView: View {
    @State private var workoutExercise: WorkoutExercise
    @State private var name: String = String()
    @State private var setPlans: String = String()
    @State private var minRep: String = String()
    @State private var maxRep: String = String()
    @State private var isPressed = false
    @State var state: StateSaving = .writing
    @Binding var uniqueSetPlan: SetPlan?
    @Binding var uniqueSetPlanEnabled: Bool
    @Query private var items: [Exercise]
    @State var filteredItems: [Exercise] = []
    @State private var showPopover = false
    
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
        workoutExercise: WorkoutExercise,
        uniqueSetPlan: Binding<SetPlan?>,
        uniqueSetPlanEnabled: Binding<Bool>
    ) {
        self.workoutExercise = workoutExercise
        self._uniqueSetPlan = uniqueSetPlan
        self._uniqueSetPlanEnabled = uniqueSetPlanEnabled
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
                    ChipGridView(chips: (filteredItems.isEmpty ? items.filter({ $0.name.trimmingCharacters(in: .whitespaces).isNotEmpty }) : filteredItems).map { $0.name }) { section in
                        self.name = section
                        DispatchQueue.main.async {
                            showPopover = false
                        }
                        hideKeyboard()
                    }
                    .padding()
                    .frame(minWidth: 50, minHeight: 80, maxHeight: 400)
                    .presentationCompactAdaptation(.popover)
                }
            if uniqueSetPlanEnabled == false {
                TextField("Series", text: $setPlans)
                    .keyboardType(.numberPad)
                TextField("Repetições Minimas", text: $minRep)
                    .keyboardType(.numberPad)
                TextField("Repetições Máximas", text: $maxRep)
                    .keyboardType(.numberPad)
            }
            Button(state == .save ? "Editar" : "Salvar") {
                var hasFilledInfo = name.isNotEmpty && setPlans.isNotEmpty && minRep.isNotEmpty && maxRep.isNotEmpty
                if uniqueSetPlanEnabled {
                    hasFilledInfo = name.isNotEmpty && uniqueSetPlan != nil
                }
                if hasFilledInfo {
                    if state == .writing || state == .error || state == .edit {
                        state = .save
                        workoutExercise.exercise = items.first(where: { $0.name == name }) ?? .init(name: name)
                        if let uniqueSetPlan {
                            workoutExercise.setPlan = uniqueSetPlan
                        } else {
                            workoutExercise.setPlan?.quantity = Int(setPlans) ?? 0
                            workoutExercise.setPlan?.minRep = Int(minRep) ?? 0
                            workoutExercise.setPlan?.maxRep = Int(maxRep) ?? 0
                        }
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
        .onChange(of: uniqueSetPlanEnabled, {
            if uniqueSetPlanEnabled {
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
            filteredItems = items.filter { $0.name.localizedCaseInsensitiveContains(text) &&  $0.name.trimmingCharacters(in: .whitespaces).isNotEmpty }
            showPopover = filteredItems.count > 0
        }
    }
}
