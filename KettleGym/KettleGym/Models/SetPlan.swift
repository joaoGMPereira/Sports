import Foundation

final class SetPlan: Codable, Equatable, Identifiable, CustomStringConvertible {
    static func == (lhs: SetPlan, rhs: SetPlan) -> Bool {
        lhs.id == rhs.id && lhs.quantity == rhs.quantity && lhs.minRep == rhs.minRep && lhs.maxRep == rhs.maxRep
    }
    
    var id: UUID
    var quantity: Int
    var minRep: Int
    var maxRep: Int
    
    var name: String {
        return "\(quantity) (\(minRep)x\(maxRep))"
    }
    
    init(quantity: Int, minRep: Int, maxRep: Int) {
        self.id = .init()
        self.quantity = quantity
        self.minRep = minRep
        self.maxRep = maxRep
    }
    
    var description: String {
        return "Serie(id: \(id), quantity: \(String(describing: quantity)), minRep: \(String(describing: minRep)), maxRep: \(String(describing: maxRep)))"
    }
}

extension Array where Element == SetPlan {
    static func mocks() -> [SetPlan] {
        return [
            SetPlan(quantity: 3, minRep: 8, maxRep: 12),
            SetPlan(quantity: 4, minRep: 6, maxRep: 8),
            SetPlan(quantity: 5, minRep: 5, maxRep: 5),
            SetPlan(quantity: 3, minRep: 12, maxRep: 15),
            SetPlan(quantity: 2, minRep: 15, maxRep: 20),
            SetPlan(quantity: 4, minRep: 10, maxRep: 12),
            SetPlan(quantity: 3, minRep: 6, maxRep: 10),
            SetPlan(quantity: 5, minRep: 3, maxRep: 5),
            SetPlan(quantity: 2, minRep: 20, maxRep: 25),
            SetPlan(quantity: 1, minRep: 30, maxRep: 30)
        ]
    }
    
    /// Retorna mocks categorizados por tipo de treino
    static func categorizedMocks() -> [String: [SetPlan]] {
        return [
            "Força": [
                SetPlan(quantity: 5, minRep: 3, maxRep: 5),
                SetPlan(quantity: 4, minRep: 6, maxRep: 8),
                SetPlan(quantity: 3, minRep: 6, maxRep: 10)
            ],
            "Hipertrofia": [
                SetPlan(quantity: 4, minRep: 8, maxRep: 12),
                SetPlan(quantity: 3, minRep: 8, maxRep: 12),
                SetPlan(quantity: 4, minRep: 10, maxRep: 12)
            ],
            "Resistência": [
                SetPlan(quantity: 3, minRep: 12, maxRep: 15),
                SetPlan(quantity: 2, minRep: 15, maxRep: 20),
                SetPlan(quantity: 2, minRep: 20, maxRep: 25),
                SetPlan(quantity: 1, minRep: 30, maxRep: 30)
            ]
        ]
    }
}
