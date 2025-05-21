extension String {
    func readFile() -> String? {
        do {
            return try String(contentsOfFile: self, encoding: .utf8)
        } catch {
            Log.log("Erro ao ler o arquivo \(self): \(error)", level: .error)
            return nil
        }
    }
    
    // Remove comments from Swift code to avoid false positives
    func removeComments() -> String {
        var result = self
        
        // Remove block comments (/* ... */)
        while let range = result.range(of: "/\\*[\\s\\S]*?\\*/", options: .regularExpression) {
            result.removeSubrange(range)
        }
        
        // Remove line comments (// ...)
        let lines = result.components(separatedBy: .newlines)
        let processedLines = lines.map { line -> String in
            if let range = line.range(of: "//.*$", options: .regularExpression) {
                return String(line[..<range.lowerBound])
            }
            return line
        }
        
        return processedLines.joined(separator: "\n")
    }
}
