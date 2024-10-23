import DesignSystem
import SwiftUI
import SwiftData
import SFSafeSymbols
import SwiftUIIntrospect

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct Item: Identifiable {
    let id = UUID()
    let title: String
    let executions: [Execution]
    var isExpanded: Bool = false
}

struct OwnerKey: Hashable {
    let id: UUID
    let name: String
}

struct DetailWorkoutView: View {
    @State var workout: Workout
    @State private var executionItems: [Item] = []
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isExpanded: Bool = true
    
    init(workout: Workout) {
        self.workout = workout
        self._executionItems = State(initialValue: groupExecutionsByOwner(workout: workout))
    }
    
    func groupExecutionsByOwner(workout: Workout) -> [Item] {
        // Group executions by owner using Dictionary with OwnerKey
        let groupedExecutions = Dictionary(grouping: workout.executions, by: { OwnerKey(id: $0.owner.id, name: $0.owner.name) })

        // Map the grouped executions into an array of Item
        let items: [Item] = groupedExecutions.map { (key, executions) in
            return Item(title: key.name, executions: executions.sorted(by: { $0.date > $1.date }))
        }
        
        return items
    }
    
    var body: some View {
        Form {
            Section("Treinos") {
                VStack(alignment: .leading, spacing: 4) {
                    Spacer(minLength: 4)
                    TrainingsView(trainings: workout.orderedTrainings)
                    Spacer(minLength: 4)
                }
            }
            if workout.executions.count > 0 {
                Section("Histórico") {
                    ForEach($executionItems) { $item in
                        DisclosureGroup(item.title, isExpanded: $item.isExpanded) {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(item.executions) { itemExecution in
                                    Text(itemExecution.training.name)
                                        .font(.subheadline)
                                    Text("Exercícios")
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                        .font(.caption)
                                    ForEach(itemExecution.training.exercises) { exercise in
                                        Text(exercise.name)
                                        if let quantity = exercise.serie.quantity,
                                           let minRep = exercise.serie.minRep,
                                           let maxRep = exercise.serie.maxRep {
                                            Text(
                                                "\(quantity) (\(minRep)x\(maxRep))"
                                            )
                                        }
                                        ForEach(exercise.executions) { execution in
                                            Text(
                                                "Peso: \(execution.weight), Rep: \(execution.reps)"
                                            )
                                        }
                                    }
                                    Text("Feito: \(formattedDate(itemExecution.date))")
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                        .font(.caption)
                                        .padding(.bottom, 8)
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                }
            }
            
            Section("Cadastrar Execução") {
               AddExecutionView(workout: workout)
            }
            Section("Meta dados") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Data de criação")
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .font(.caption)
                    Text(workout.startDate, style: .date)
                        .listRowSeparator(.hidden)
                    if let endDate = workout.endDate {
                        Text("Data de encerramento")
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .font(.caption)
                        Text(endDate, style: .date)
                            .listRowSeparator(.hidden)
                    } else {
                        DSFillButton(title: "Encerrar", color: .red) {
                            workout.hasFinished = true
                            workout.endDate = .now
                            try? modelContext.save()
                        }
                    }
                }
            }
        }
        .onChange(
            of: workout.executions,
            {
                executionItems = groupExecutionsByOwner(workout: workout)
            }
        )
        .navigationTitle(workout.title)
        .toolbar(.hidden, for: .tabBar)
    }
    
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct AddExecutionView: View {
    @Environment(\.modelContext) private var modelContext
    @State var workout: Workout
    @State var selectedTraining: ExecutionTraining?
    @State var owner: String = String()
    @State var selectedOwner: Owner?
    @State private var filteredOwners: [Owner] = []
    @Query private var owners: [Owner] = []
    @State private var showOwnersPopover = false
    var body: some View {
        Group {
            HStack {
                TextField("Executor", text: $owner)
                    .introspect(.textField, on: .iOS(.v17, .v18)) { textField in
                        textField.inputAccessoryView = nil
                        textField.reloadInputViews()
                    }
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded {
                                self.showOwnersPopover = true
                            }
                    )
                    .onChange(of: owner) {
                        self.applyFilter(with: owner)
                    }
                    .onSubmit {
                        showOwnersPopover = false
                        hideKeyboard()
                    }
                    .popover(
                        isPresented: $showOwnersPopover,
                        attachmentAnchor: .point(
                            .top
                        )
                    ) {
                        ChipGridView(chips: (filteredOwners.isEmpty ? owners : filteredOwners).map { $0.name }) { owner in
                            self.owner = owner
                            self.selectedOwner = owners.first(where: { $0.name == owner })
                            DispatchQueue.main.async {
                                showOwnersPopover = false
                            }
                        }
                        .padding()
                        .frame(minWidth: 50, maxHeight: 400)
                        .presentationCompactAdaptation(.popover)
                    }
                    .onChange(of: selectedOwner) { oldValue, newValue in
                        print(newValue)
                    }
                Spacer()
                DSBorderedButton(
                    title: "+",
                    isEnabled: owners.filter({ $0.name.localizedLowercase == owner.localizedLowercase }).count == 0 ||
                    owner.isEmpty,
                    horizontalPadding: 12
                ) {
                    if owner.isNotEmpty, owners.filter({ $0.name.localizedLowercase == owner.localizedLowercase }).count == 0 {
                        let selectedOwner = Owner(name: owner)
                        self.selectedOwner = selectedOwner
                        modelContext.insert(selectedOwner)
                        try? modelContext.save()
                        hideKeyboard()
                    }
                }
            }
            .padding(.top, 4)
            ChipGridView(chips: workout.trainings.map { $0.name }, isSelectable: true) { training in
                showOwnersPopover = false
                if let selectedTraining = workout.trainings.first(where: { $0.name == training }) {
                    let executionSelectedTraining = ExecutionTraining(
                        name: selectedTraining.name,
                        exercises: selectedTraining.exercises.map { .init(
                            name: $0.name,
                            serie: $0.serie,
                            executions: []
                        )
                        }
                    )
                    self.modelContext.insert(executionSelectedTraining)
                    self.selectedTraining = executionSelectedTraining
                } else {
                    self.selectedTraining = nil
                }
            }
            if let selectedTraining {
                TrainingExecutionView(training: .init(get: { return selectedTraining }, set: { _ in }), owner: $selectedOwner)
            }
            DSFillButton(title: "Salvar") {
                if let selectedOwner, let selectedTraining, selectedTraining.hasEmptyExecutions() == false {
                    workout.executions.append(.init(date: .now, owner: selectedOwner, training: selectedTraining))
                    try? modelContext.save()
                }
            }
        }
        .listRowSeparator(.hidden)
    }
    
    private func applyFilter(with text: String) {
        if text.isEmpty {
            filteredOwners = []
            showOwnersPopover = false
        } else {
            filteredOwners = owners.filter { $0.name.localizedCaseInsensitiveContains(text) }
            showOwnersPopover = filteredOwners.count > 0
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct TrainingsView: View {
    var trainings: [Training]
    
    var body: some View {
        ForEach(trainings) { training in
            Text(training.name)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .font(.caption)
            ForEach(training.exercises) { exercise in
                HStack {
                    Text(exercise.name)
                    Spacer()
                    if let quantity = exercise.serie.quantity,
                       let minRep = exercise.serie.minRep,
                       let maxRep = exercise.serie.maxRep {
                        Text(
                            "\(quantity) (\(minRep)x\(maxRep))"
                        )
                    }
                }
            }
        }
    }
}

struct TrainingExecutionView: View {
    @Binding var training: ExecutionTraining
    @State private var textFieldsValues: [[(String, String)]]
    @Binding var owner: Owner?
    // Struct para controlar o foco
    struct FocusField: Hashable {
        let exerciseIndex: Int
        let serieIndex: Int
        let fieldType: FieldType
    }
    
    enum FieldType {
        case reps
        case weight
    }
    
    @FocusState private var focusedField: FocusField?
    @Environment(\.modelContext) private var modelContext
    @State var hasSaved: Bool = false
    
    init(training: Binding<ExecutionTraining>, owner: Binding<Owner?>) {
        _training = training
        _textFieldsValues = State(initialValue: training.wrappedValue.exercises.map { exercise in
            Array(repeating: ("", ""), count: exercise.serie.quantity ?? 0)
        })
        self._owner = owner
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(training.name)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .font(.caption)
            ForEach(training.exercises.indices, id: \.self) { exerciseIndex in
                let exercise = training.exercises[exerciseIndex]
                
                Text(exercise.name)
                    .font(.headline)
                
                if let quantity = exercise.serie.quantity {
                    HStack {
                        ForEach(0..<quantity, id: \.self) { serieIndex in
                            TextField("Reps", text: $textFieldsValues[exerciseIndex][serieIndex].0)
                                .textFieldStyle(DSRoundedBorderTextFieldStyle(isEnabled: !hasSaved))
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: FocusField(exerciseIndex: exerciseIndex, serieIndex: serieIndex, fieldType: .reps))
                                .onChange(of: textFieldsValues[exerciseIndex][serieIndex].0) { oldValue, newValue in
                                    if newValue.count > 1 {
                                        moveToNextField()
                                    }
                                }
                        }
                    }
                    
                    HStack {
                        ForEach(0..<quantity, id: \.self) { serieIndex in
                            TextField("Peso", text: $textFieldsValues[exerciseIndex][serieIndex].1)
                                .textFieldStyle(DSRoundedBorderTextFieldStyle(isEnabled: !hasSaved))
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: FocusField(exerciseIndex: exerciseIndex, serieIndex: serieIndex, fieldType: .weight))
                                .onChange(of: textFieldsValues[exerciseIndex][serieIndex].1) { oldValue, newValue in
                                    if newValue.count > 2 {
                                        moveToNextField()
                                    }
                                }
                        }
                    }
                    DSBorderedButton(
                        title: hasSaved ? "Editar" : "Gravar"
                    ) {
                        
                        save(exercise: exercise, index: exerciseIndex)
                    }
                }
            }
        }
        .onChange(of: training, {
            textFieldsValues = training.exercises.map { exercise in
                Array(repeating: ("", ""), count: exercise.serie.quantity ?? 0)
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
    
    func save(exercise: ExecutionExercise, index: Int) {
        if hasSaved == false {
            if textFieldsValues[index].contains(where: { $0.0 == "" && $0.1 == ""}) == false {
                exercise.executions = textFieldsValues[index]
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
            if currentField.serieIndex < (training.exercises[currentField.exerciseIndex].serie.quantity ?? 0) - 1 {
                // Move para o próximo campo de reps na mesma série
                focusedField = FocusField(exerciseIndex: currentField.exerciseIndex, serieIndex: currentField.serieIndex + 1, fieldType: .reps)
            } else {
                // Se não houver mais campos de reps, move para o primeiro campo de peso
                focusedField = FocusField(exerciseIndex: currentField.exerciseIndex, serieIndex: 0, fieldType: .weight)
            }
        } else if currentField.fieldType == .weight {
            if currentField.serieIndex < (training.exercises[currentField.exerciseIndex].serie.quantity ?? 0) - 1 {
                // Move para o próximo campo de peso na mesma série
                focusedField = FocusField(exerciseIndex: currentField.exerciseIndex, serieIndex: currentField.serieIndex + 1, fieldType: .weight)
            } else if currentField.exerciseIndex < training.exercises.count - 1 {
                // Se não houver mais campos de peso, move para o próximo exercício
                focusedField = FocusField(exerciseIndex: currentField.exerciseIndex + 1, serieIndex: 0, fieldType: .reps)
            } else {
                // Se for o último campo, desativa o foco
                focusedField = nil
            }
        }
    }
}

struct ChipGridView: View {
    // Lista de chips
    let chips: [String]
    let isSelectable: Bool
    @State var chipSelected: String?
    let onClick: (String) -> Void
    
    init(chips: [String], isSelectable: Bool = false, onClick: @escaping (String) -> Void) {
        self.chips = chips
        self.isSelectable = isSelectable
        self.onClick = onClick
    }
    
    var body: some View {
        ScrollView {
            Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(chips.divided(into: 3), id: \.self) { chipsPart in
                    GridRow {
                        ForEach(chipsPart, id: \.self) { chip in
                            ChipView(label: chip, isSelected: chipSelected == chip)
                                .onTapGesture {
                                    if isSelectable {
                                        chipSelected = chip == chipSelected ? nil : chip
                                    } else {
                                        chipSelected = chip
                                    }
                                    onClick(chipSelected ?? String())
                                }
                        }
                    }
                }
            }
        }
    }
}

struct ChipView: View {
    var label: String
    var isSelected: Bool
    
    var body: some View {
        Text(label)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Asset.primary.swiftUIColor.opacity(0.6) : Asset.primary.swiftUIColor.opacity(0.2))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Asset.primary.swiftUIColor, lineWidth: 1)
            )
            .foregroundColor(Asset.primary.swiftUIColor)
            .padding(2)
    }
}

extension Array {
    func divided(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        
        var result: [[Element]] = []
        var chunk: [Element] = []
        
        for element in self {
            chunk.append(element)
            if chunk.count == size {
                result.append(chunk)
                chunk = []
            }
        }
        
        if !chunk.isEmpty {
            result.append(chunk)
        }
        
        return result
    }
}
