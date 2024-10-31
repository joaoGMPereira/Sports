import DesignSystem
import SwiftUI

struct TrainingExecutionView: View {
    @Binding var scheduledTraining: ScheduledTraining
    @State private var textFieldsValues: [[(String, String)]]
    @Binding var user: User?
    // Struct para controlar o foco
    struct FocusField: Hashable {
        let exerciseIndex: Int
        let setPlanIndex: Int
        let fieldType: FieldType
    }
    
    enum FieldType {
        case reps
        case weight
    }
    
    @FocusState private var focusedField: FocusField?
    @Environment(\.modelContext) private var modelContext
    @State var hasSaved: Bool = false
    
    init(scheduledTraining: Binding<ScheduledTraining>, user: Binding<User?>) {
        _scheduledTraining = scheduledTraining
        _textFieldsValues = State(initialValue: scheduledTraining.wrappedValue.performedExercises.map { performedExercise in
            Array(repeating: ("", ""), count: performedExercise.setPlan.quantity ?? 0)
        })
        self._user = user
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(scheduledTraining.name)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .font(.caption)
            ForEach(scheduledTraining.performedExercises.indices, id: \.self) { exerciseIndex in
                let performedExercise = scheduledTraining.performedExercises[exerciseIndex]
                
                Text(performedExercise.name)
                    .font(.headline)
                
                if let quantity = performedExercise.setPlan.quantity, textFieldsValues.isNotEmpty {
                    HStack {
                        ForEach(0..<quantity, id: \.self) { setPlanIndex in
                            TextField("Reps", text: $textFieldsValues[exerciseIndex][setPlanIndex].0)
                                .textFieldStyle(DSRoundedBorderTextFieldStyle(isEnabled: !hasSaved))
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: FocusField(exerciseIndex: exerciseIndex, setPlanIndex: setPlanIndex, fieldType: .reps))
                                .onChange(of: textFieldsValues[exerciseIndex][setPlanIndex].0) { oldValue, newValue in
                                    if newValue.count > 1 {
                                        moveToNextField()
                                    }
                                }
                        }
                    }
                    
                    HStack {
                        ForEach(0..<quantity, id: \.self) { setPlanIndex in
                            TextField("Peso", text: $textFieldsValues[exerciseIndex][setPlanIndex].1)
                                .textFieldStyle(DSRoundedBorderTextFieldStyle(isEnabled: !hasSaved))
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: FocusField(exerciseIndex: exerciseIndex, setPlanIndex: setPlanIndex, fieldType: .weight))
                                .onChange(of: textFieldsValues[exerciseIndex][setPlanIndex].1) { oldValue, newValue in
                                    if newValue.count > 2 {
                                        moveToNextField()
                                    }
                                }
                        }
                    }
                    DSBorderedButton(
                        title: hasSaved ? "Editar" : "Gravar"
                    ) {
                        
                        save(performedExercise: performedExercise, index: exerciseIndex)
                    }
                }
            }
        }
        .onChange(of: scheduledTraining, {
            textFieldsValues = scheduledTraining.performedExercises.map { performedExercise in
                Array(repeating: ("", ""), count: performedExercise.setPlan.quantity ?? 0)
            }
            hasSaved = false
        })
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Concluir") {
                    focusedField = nil // Remove o foco
                }
                Button("Próximo") {
                    moveToNextField()
                }
            }
        }
    }
    
    func save(performedExercise: PerformedExercise, index: Int) {
        if hasSaved == false {
            if textFieldsValues[index].contains(where: { $0.0 == "" && $0.1 == ""}) == false {
                performedExercise.exerciseSets = textFieldsValues[index]
                    .map { .init(weight: Int($0.0) ?? 0, reps: Int($0.1) ?? 0) }
                hasSaved.toggle()
            }
            return
        }
        if hasSaved == true {
            hasSaved.toggle()
        }
    }
    
    // Função para mover para o próximo campo
    private func moveToNextField() {
        guard let currentField = focusedField else { return }
        
        if currentField.fieldType == .reps {
            if currentField.setPlanIndex < (scheduledTraining.performedExercises[currentField.exerciseIndex].setPlan.quantity ?? 0) - 1 {
                // Move para o próximo campo de reps na mesma série
                focusedField = FocusField(exerciseIndex: currentField.exerciseIndex, setPlanIndex: currentField.setPlanIndex + 1, fieldType: .reps)
            } else {
                // Se não houver mais campos de reps, move para o primeiro campo de peso
                focusedField = FocusField(exerciseIndex: currentField.exerciseIndex, setPlanIndex: 0, fieldType: .weight)
            }
        } else if currentField.fieldType == .weight {
            if currentField.setPlanIndex < (scheduledTraining.performedExercises[currentField.exerciseIndex].setPlan.quantity ?? 0) - 1 {
                // Move para o próximo campo de peso na mesma série
                focusedField = FocusField(exerciseIndex: currentField.exerciseIndex, setPlanIndex: currentField.setPlanIndex + 1, fieldType: .weight)
            } else if currentField.exerciseIndex < scheduledTraining.performedExercises.count - 1 {
                // Se não houver mais campos de peso, move para o próximo exercício
                focusedField = FocusField(exerciseIndex: currentField.exerciseIndex + 1, setPlanIndex: 0, fieldType: .reps)
            } else {
                // Se for o último campo, desativa o foco
                focusedField = nil
            }
        }
    }
}
