import Zenith
import ZenithCoreInterface
import SwiftUI

struct TrainingTextFieldsState {
    var textFields: [TrainingTextFieldData]
    var hasSaved = false
}
struct TrainingTextFieldData {
    var reps: String
    var weight: String
}

struct TrainingExecutionView: View {
    @Binding var scheduledTraining: ScheduledTraining
    @State private var textFieldsValues: [TrainingTextFieldsState]
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
    
    init(scheduledTraining: Binding<ScheduledTraining>, user: Binding<User?>) {
        _scheduledTraining = scheduledTraining
        _textFieldsValues = State(
            initialValue: scheduledTraining.wrappedValue.performedExercises.map { performedExercise in
                    .init(
                        textFields: Array(
                            repeating: .init(
                                reps: "",
                                weight: ""
                            ),
                            count: performedExercise.setPlan.quantity ?? 0
                        )
                    )
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
                
                if let quantity = performedExercise.setPlan.quantity,
                   textFieldsValues.isNotEmpty,
                   let textFieldData = $textFieldsValues[safe: exerciseIndex] {
                    HStack {
                        ForEach(0..<quantity, id: \.self) { setPlanIndex in
                            if let text = textFieldData.textFields[safe: setPlanIndex]?.reps {
                                TextField("Reps", text: text)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: FocusField(exerciseIndex: exerciseIndex, setPlanIndex: setPlanIndex, fieldType: .reps))
                                    .onChange(of: textFieldsValues[exerciseIndex].textFields[setPlanIndex].reps) { oldValue, newValue in
                                        textFieldDidChange(
                                            oldValue: oldValue,
                                            newValue: newValue,
                                            validator: 1
                                        )
                                    }
                            }
                        }
                    }
                    
                    HStack {
                        ForEach(0..<quantity, id: \.self) { setPlanIndex in
                            if let text = textFieldData.textFields[safe: setPlanIndex]?.weight {
                                TextField("Peso", text: text)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: FocusField(exerciseIndex: exerciseIndex, setPlanIndex: setPlanIndex, fieldType: .weight))
                                    .onChange(of: textFieldsValues[exerciseIndex].textFields[setPlanIndex].weight) {
                                        oldValue, newValue in
                                        textFieldDidChange(
                                            oldValue: oldValue,
                                            newValue: newValue,
                                            validator: 2
                                        )
                                    }
                            }
                        }
                    }
                    DSBorderedButton(
                        title: textFieldData.hasSaved.wrappedValue ? "Editar" : "Gravar"
                    ) {
                        
                        save(performedExercise: performedExercise, index: exerciseIndex)
                    }
                }
            }
        }
        .onChange(of: scheduledTraining, {
            textFieldsValues = scheduledTraining.performedExercises.map { performedExercise in
                    .init(
                        textFields: Array(
                            repeating: .init(
                                reps: "",
                                weight: ""
                            ),
                            count: performedExercise.setPlan.quantity ?? 0
                        )
                    )
            }
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
    
    func textFieldDidChange(oldValue: String, newValue: String, validator: Int) {
        if newValue.isEmpty {
            moveToPreviousField()
            return
        }
        if newValue.count > validator && newValue.count > oldValue.count {
            moveToNextField()
        }
        
        if newValue.count > validator + 1 {
            // Mantém o valor anterior caso o novo valor exceda o validador
            if let currentFocusedField = focusedField {
                if currentFocusedField.fieldType == .reps {
                    textFieldsValues[currentFocusedField.exerciseIndex].textFields[currentFocusedField.setPlanIndex].reps = oldValue
                } else if currentFocusedField.fieldType == .weight {
                    textFieldsValues[currentFocusedField.exerciseIndex].textFields[currentFocusedField.setPlanIndex].weight = oldValue
                }
            }
        }
    }
    func save(performedExercise: PerformedExercise, index: Int) {
        if textFieldsValues[safe: index]?.hasSaved == false {
            if textFieldsValues[index].textFields.contains(where: { $0.reps == "" && $0.weight == ""}) == false {
                performedExercise.exerciseSets = textFieldsValues[index].textFields
                    .map { .init(weight: Int($0.reps) ?? 0, reps: Int($0.weight) ?? 0) }
                textFieldsValues[index].hasSaved.toggle()
            }
            return
        }
        if textFieldsValues[safe: index]?.hasSaved == true {
            textFieldsValues[index].hasSaved.toggle()
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
    
    private func moveToPreviousField() {
        guard let currentField = focusedField else { return }

        if currentField.fieldType == .weight {
            if currentField.setPlanIndex > 0 {
                // Move para o campo de peso anterior na mesma série
                focusedField = FocusField(exerciseIndex: currentField.exerciseIndex, setPlanIndex: currentField.setPlanIndex - 1, fieldType: .weight)
            } else {
                // Se não houver mais campos de peso, move para o último campo de reps do exercício anterior
                focusedField = FocusField(exerciseIndex: currentField.exerciseIndex, setPlanIndex: (scheduledTraining.performedExercises[currentField.exerciseIndex].setPlan.quantity ?? 1) - 1, fieldType: .reps)
            }
        } else if currentField.fieldType == .reps {
            if currentField.setPlanIndex > 0 {
                // Move para o campo de reps anterior na mesma série
                focusedField = FocusField(exerciseIndex: currentField.exerciseIndex, setPlanIndex: currentField.setPlanIndex - 1, fieldType: .reps)
            } else if currentField.exerciseIndex > 0 {
                // Se não houver mais campos de reps, move para o último campo de peso do exercício anterior
                focusedField = FocusField(exerciseIndex: currentField.exerciseIndex - 1, setPlanIndex: (scheduledTraining.performedExercises[currentField.exerciseIndex - 1].setPlan.quantity ?? 1) - 1, fieldType: .weight)
            } else {
                // Se for o primeiro campo, desativa o foco
                focusedField = nil
            }
        }
    }
}
