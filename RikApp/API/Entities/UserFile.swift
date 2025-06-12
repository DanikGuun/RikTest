
public struct UserFile: Identifiable, Equatable {
    public var id: Int
    public var type: FileType
    public var urlString: String
    
    public init(id: Int = 0, type: FileType = .avatar, urlString: String = "") {
        self.id = id
        self.type = type
        self.urlString = urlString
    }
    
    public enum FileType: String {
        case avatar = "avatar"
    }
}
