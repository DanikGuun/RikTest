

public struct User: Identifiable, Equatable {
    public var id: Int
    public var sex: UserSex
    public var name: String
    public var isOnline: Bool
    public var age: Int
    public var files: [UserFile]
    
    public init(id: Int = 0, sex: UserSex = .male, name: String = "", isOnline: Bool = false, age: Int = 0, files: [UserFile] = []) {
        self.id = id
        self.sex = sex
        self.name = name
        self.isOnline = isOnline
        self.age = age
        self.files = files
    }
}

public enum UserSex: String {
    case male = "male"
    case female = "female"
}
