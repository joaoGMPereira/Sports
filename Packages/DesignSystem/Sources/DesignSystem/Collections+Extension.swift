import Foundation

public extension Array {
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

public extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    var isNotEmpty: Bool {
        !isEmpty
    }
}

