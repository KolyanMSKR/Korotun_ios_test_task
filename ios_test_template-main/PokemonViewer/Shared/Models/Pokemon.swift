struct Pokemon: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let imageURLString: String
    
    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
        return lhs.id == rhs.id
    }
}
