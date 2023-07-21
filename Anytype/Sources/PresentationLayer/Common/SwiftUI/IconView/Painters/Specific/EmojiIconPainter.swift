import SwiftUI

final class EmojiIconPainter: IconPainter {
    
    // MARK: - Private
    
    private struct Config {
        let side: CGFloat
        let cornerRadius: CGFloat?
        
        static let zero = Config(side: 0, cornerRadius: nil)
    }
    
    private static let configs = [
        Config(side: 16, cornerRadius: nil),
        Config(side: 18, cornerRadius: nil),
        Config(side: 40, cornerRadius: 8),
        Config(side: 48, cornerRadius: 10),
        Config(side: 64, cornerRadius: 14),
        Config(side: 80, cornerRadius: 18)
    ].sorted(by: { $0.side > $1.side }) // Order by DESK side for simple search
    
    private let charPainter: IconPainter
    
    init(text: String) {
        self.charPainter = CharIconPainter(text: text)
    }
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        charPainter.drawPlaceholder(bounds: bounds, context: context, iconContext: iconContext)
    }
    
    func prepare(bounds: CGRect) async {
        await charPainter.prepare(bounds: bounds)
    }
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        let side = min(bounds.size.width, bounds.size.height)
        let config = EmojiIconPainter.configs.first(where: { $0.side <= side }) ?? EmojiIconPainter.configs.last ?? .zero
        
        context.saveGState()
        
        if let radius = config.cornerRadius {
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
            context.addPath(path)
            context.clip()
            
            context.setFillColor(UIColor.Stroke.secondary.cgColor)
            context.fill(bounds)

        }
        
        charPainter.draw(bounds: bounds, context: context, iconContext: iconContext)
        
        context.restoreGState()
    }
}
