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
    let contextualModule: Bool
    let initParams: [NativeComponentParameter]
    let exampleCode: String
}

let NATIVE_COMPONENTS: [String: NativeComponent] = [
    "Button": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: "Button",
        defaultStyleCase: "contentA",
        contextualModule: false,
        initParams: [],
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
        contextualModule: false,
        initParams: [
            NativeComponentParameter(label: nil, name: "content", type: "String", defaultValue: "\"\"", isAction: false)
        ],
        exampleCode: """
        Text(sampleText)
        """
    ),
    "Divider": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: nil,
        defaultStyleCase: "contentA",
        contextualModule: false,
        initParams: [],
        exampleCode: """
        Divider()
        """
    ),
    "Toggle": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: "Toggle",
        defaultStyleCase: "mediumHighlightA",
        contextualModule: false,
        initParams: [
            NativeComponentParameter(label: nil, name: "isOn", type: "Bool", defaultValue: "false", isAction: false)
        ],
        exampleCode: """
        Toggle(sampleText, isOn: $isOn)
        """
    ),
    "TextField": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: "TextField",
        defaultStyleCase: "contentA",
        contextualModule: true,
        initParams: [
            NativeComponentParameter(label: nil, name: "placeholder", type: "String", defaultValue: "\"\"", isAction: false)
        ],
        exampleCode: """
        TextField(placeholder, text: $sampleText)
        """
    )
]

