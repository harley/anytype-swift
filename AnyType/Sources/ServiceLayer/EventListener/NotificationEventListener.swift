import Foundation
import Combine
import ProtobufMessages

class NotificationEventListener {

    private var subscription: AnyCancellable?
    private let handler: EventHandler

    init(handler: EventHandler) {
        self.handler = handler
    }
    
    func startListening(contextId: String) {
        subscription = NotificationCenter.Publisher(center: .default, name: .middlewareEvent, object: nil)
            .compactMap { $0.object as? Anytype_Event }
            .filter( {$0.contextID == contextId} )
            .sink { [weak self] event in
                guard let handler = self?.handler else { return }
                let event = PackOfEvents(contextId: contextId, events: event.messages, ourEvents: [])
                handler.handle(events: event)
        }
    }
}
