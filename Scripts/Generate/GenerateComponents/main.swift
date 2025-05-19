#!/usr/bin/swift

import Foundation

// MARK: - Descoberta de componentes disponíveis

let componentConfiguration = ComponentConfiguration()
let interactionMenu = InteractionMenu()

// Se executado com argumentos, usar modo de linha de comando
// Senão, iniciar interface interativa
if CommandLine.arguments.count > 1 {
    let componentName = CommandLine.arguments[1]
    let success = interactionMenu.createSampleFile(for: componentName)
    exit(success ? 0 : 1)
} else {
    // Iniciar interface interativa
    interactionMenu.mainMenu {
        exit(0)
    }
}
