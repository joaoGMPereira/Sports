import SwiftUI
import Zenith

struct CheckBoxSample: View {
    @State var isSelected = false
    @State var isSelectedWithoutText = false
    @State var isDisabledSelected = false
    @State var isDisabled = true
    @State private var selectedItems: Set<Int> = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ForEach(CheckBoxStyleCase.allCases, id: \.self) { style in
            CheckBox(
                isSelected: $isSelected,
                text: "Single CheckBox With Text"
            )
            .checkboxStyle(
                style.style()
            )
            CheckBox(
                isSelected: Binding(
                    get: { selectedItems.contains(0) },
                    set: { isSelected in
                        if isSelected {
                            selectedItems.insert(0)
                        } else {
                            selectedItems.remove(0)
                        }
                    }
                ),
                text: "Multiple CheckBox With Text 1"
            )
            .checkboxStyle(
                style.style()
            )
            CheckBox(
                isSelected: Binding(
                    get: { selectedItems.contains(1) },
                    set: { isSelected in
                        if isSelected {
                            selectedItems.insert(1)
                        } else {
                            selectedItems.remove(1)
                        }
                    }
                ),
                text: "Multiple CheckBox With Text 2"
            )
            .checkboxStyle(
                style.style()
            )
            CheckBox(
                isSelected: Binding(
                    get: { selectedItems.contains(2) },
                    set: { isSelected in
                        if isSelected {
                            selectedItems.insert(2)
                        } else {
                            selectedItems.remove(2)
                        }
                    }
                ),
                text: "Multiple CheckBox With Text 3"
            )
            .checkboxStyle(
                style.style()
            )
            CheckBox(
                isSelected: Binding(
                    get: { selectedItems.contains(3) },
                    set: { isSelected in
                        if isSelected {
                            selectedItems.insert(3)
                        } else {
                            selectedItems.remove(3)
                        }
                    }
                ),
                text: "Multiple CheckBox With Text 4"
            )
            .checkboxStyle(
                style.style()
            )
            CheckBox(
                isSelected: $isSelectedWithoutText
            )
            .checkboxStyle(
                style.style()
            )
            CheckBox(
                isSelected: .constant(false),
                text: "Single Radio Button With Text Disabled"
            )
            .isDisabled(true)
            CheckBox(
                isSelected: $isDisabledSelected,
                text: "Single Radio Button With Text Disabled Mutation"
            )
            .isDisabled(isDisabled)
        }.onAppear {
            Task {
                // Delay for 3 seconds (in nanoseconds)
                try await Task.sleep(for: .seconds(3))
                
                // Run your async task here
                await MainActor.run {
                    isDisabled = false
                }
            }
        }
        Button(action: showSelectedCount) {
            Text("Show Selected Count")
        }
        .buttonStyle(.highlightA())
        .padding(.top, 16)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Selection Count"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    private func showSelectedCount() {
        alertMessage = "Selected Items Count: \(selectedItems.count)"
        showAlert = true
    }
}
