import Foundation
// MARK: - Modelos de componentes nativos

struct NativeComponentParameter {
    let label: String?
    let name: String
    let type: String
    let defaultValue: String?
    let isAction: Bool
}

struct NativeComponent {
    let typePath: String
    let defaultContent: String?
    let defaultStyleCase: String
    let initParams: [NativeComponentParameter]
    let exampleCode: String
}

let NATIVE_COMPONENTS: [String: NativeComponent] = [
    "Button": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: "Button",
        defaultStyleCase: "contentA",
        initParams: [
            NativeComponentParameter(label: nil, name: "title", type: "String", defaultValue: nil, isAction: false),
            NativeComponentParameter(label: nil, name: "action", type: "() -> Void", defaultValue: nil, isAction: true)
        ],
        exampleCode: """
        Button(sampleText) {
            // Ação do botão
        }
        """
    ),
    "Text": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: "Text",
        defaultStyleCase: "smallContentA",
        initParams: [
            NativeComponentParameter(label: nil, name: "content", type: "String", defaultValue: nil, isAction: false)
        ],
        exampleCode: """
        Text(sampleText)
        """
    ),
    "Divider": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: nil,
        defaultStyleCase: "contentA",
        initParams: [],
        exampleCode: """
        Divider()
        """
    ),
    "Toggle": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: "Toggle",
        defaultStyleCase: "mediumHighlightA",
        initParams: [
            NativeComponentParameter(label: nil, name: "isOn", type: "Binding<Bool>", defaultValue: nil, isAction: false),
            NativeComponentParameter(label: nil, name: "label", type: "String", defaultValue: nil, isAction: false)
        ],
        exampleCode: """
        Toggle(sampleText, isOn: $isEnabled)
        """
    ),
    "TextField": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: "TextField",
        defaultStyleCase: "contentA",
        initParams: [
            NativeComponentParameter(label: nil, name: "text", type: "Binding<String>", defaultValue: nil, isAction: false),
            NativeComponentParameter(label: nil, name: "placeholder", type: "String", defaultValue: nil, isAction: false)
        ],
        exampleCode: """
        TextField("Placeholder", text: $sampleText)
        """
    )
]

