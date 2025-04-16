import SwiftUI
import Zenith

enum Option: Sendable {
    case a, b, c
}

struct RadioButtonSample: View {
    @State var isExpanded = false
    @State var isSelected = false
    @State var isSelectedWithoutText = false
    @State var isDisabledSelected = false
    @State var selectedOption: Option? = nil
    @State var isDisabled = true
    
    var body: some View {
        SectionView(title: "RADIOBUTTON", isExpanded: $isExpanded) {
            ForEach(RadioButtonStyleCase.allCases, id: \.self) { style in
                RadioButton(
                    isSelected: $isSelected,
                    text: "Single Radio Button With Text"
                )
                .radiobuttonStyle(
                    style.style()
                )
                RadioButton(
                    tag: .a,
                    selection: $selectedOption,
                    text: "Radio Button With multiple options"
                )
                .radiobuttonStyle(
                    style.style()
                )
                RadioButton(
                    tag: .b,
                    selection: $selectedOption,
                    text: "Radio Button With multiple options"
                )
                .radiobuttonStyle(
                    style.style()
                )
                RadioButton(
                    tag: .c,
                    selection: $selectedOption,
                    text: "Radio Button With multiple options"
                )
                .radiobuttonStyle(
                    style.style()
                )
                RadioButton(
                    isSelected: $isSelectedWithoutText
                )
                .radiobuttonStyle(
                    style.style()
                )
                RadioButton(
                    isSelected: .constant(false),
                    text: "Single Radio Button With Text Disabled"
                )
                .isDisabled(true)
                RadioButton(
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
        }
    }
}
