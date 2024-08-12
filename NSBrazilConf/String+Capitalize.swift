public extension String {
    func capitalizedWord()-> String {
        let list = self.components(separatedBy: .whitespaces)
        let capitalized: [String] = list.map { $0.count <= 2 ? $0.lowercased()  : $0 }
        return capitalized.joined(separator: " ")
    }
}
