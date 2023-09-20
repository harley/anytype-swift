import ProtobufMessages

struct MiddlewareString: Hashable, Equatable {
    let text: String
    let marks: Anytype_Model_Block.Content.Text.Marks
}
