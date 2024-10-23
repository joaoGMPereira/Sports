import DesignSystem
import SFSafeSymbols
import SwiftUI

enum StateSaving {
    case writing
    case save
    case edit
    case error
}

struct CreateExerciseView: View {
    @State private var exercise: Exercise
    @State private var name: String = String()
    @State private var series: String = String()
    @State private var minRep: String = String()
    @State private var maxRep: String = String()
    @State private var isPressed = false
    @State var state: StateSaving = .writing
    @Binding var uniqueSerie: Serie?
    @Binding var uniqueSerieEnabled: Bool
    let create: ((Exercise) -> Void)
    
    init(
        exercise: Exercise,
        uniqueSerie: Binding<Serie?>,
        uniqueSerieEnabled: Binding<Bool>,
        create: @escaping ((Exercise) -> Void)
    ) {
        self.exercise = exercise
        self._uniqueSerie = uniqueSerie
        self._uniqueSerieEnabled = uniqueSerieEnabled
        self.create = create
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemSymbol: image)
                    .foregroundStyle(color)
            }
            TextField("Nome", text: $name)
            if uniqueSerieEnabled == false {
                TextField("Series", text: $series)
                    .keyboardType(.numberPad)
                TextField("Repetições Minimas", text: $minRep)
                    .keyboardType(.numberPad)
                TextField("Repetições Máximas", text: $maxRep)
                    .keyboardType(.numberPad)
            }
            Button(state == .save ? "Editar" : "Salvar") {
                var hasFilledInfo = name.isNotEmpty && series.isNotEmpty && minRep.isNotEmpty && maxRep.isNotEmpty
                if uniqueSerieEnabled {
                    hasFilledInfo = name.isNotEmpty && uniqueSerie != nil
                }
                if hasFilledInfo {
                    if state == .writing || state == .error || state == .edit {
                        state = .save
                        exercise.name = name
                        if let uniqueSerie {
                            exercise.serie = uniqueSerie
                        } else {
                            exercise.serie.quantity = Int(series) ?? 0
                            exercise.serie.minRep = Int(minRep) ?? 0
                            exercise.serie.maxRep = Int(maxRep) ?? 0
                        }
                        create(exercise)
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
        .onChange(of: uniqueSerieEnabled, {
            if uniqueSerieEnabled {
                self.series = String()
                self.minRep = String()
                self.maxRep = String()
            }
        })
        .padding(4)
    }
    
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
}
