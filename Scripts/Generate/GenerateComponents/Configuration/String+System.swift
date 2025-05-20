extension String {
    func readFile() -> String? {
        do {
            return try String(contentsOfFile: self, encoding: .utf8)
        } catch {
            Log.log("Erro ao ler o arquivo \(self): \(error)", level: .error)
            return nil
        }
    }
}
