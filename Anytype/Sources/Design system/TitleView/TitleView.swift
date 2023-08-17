import SwiftUI

struct TitleView<RightContent, LeftContent>: View where RightContent: View, LeftContent: View  {
    
    let title: String?
    let leftButton: LeftContent?
    let rightButton: RightContent?
    
    @State private var maxWidth: CGFloat = .zero
    private let titlePadding: CGFloat = 8
    
    init(title: String?, @ViewBuilder leftButton: () -> LeftContent, @ViewBuilder rightButton: () -> RightContent) {
        self.title = title
        self.leftButton = leftButton()
        self.rightButton = rightButton()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(8)
            content
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .border(.orange, width: 1)
    }
    
    var content: some View {
        HStack(spacing: 0) {
            leftView
            
            principalView
            
            rightView
        }
    }
    
    @ViewBuilder
    var principalView: some View {
        if let title = title {
            AnytypeText(title, style: .navigationBarTitle, color: .Text.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .lineLimit(1)
        }
    }
    
    var leftView: some View {
        HStack(spacing: 0) {
            leftButton
            Spacer.fixedWidth(titlePadding)
        }
        .readSize {
            maxWidth = max(maxWidth, $0.width)
        }
        .frame(width: maxWidth + titlePadding * 2, alignment: .leading)
    }
    
    var rightView: some View {
        HStack(spacing: 0) {
            Spacer.fixedWidth(titlePadding)
            rightButton
        }
        .readSize {
            maxWidth = max(maxWidth, $0.width)
        }
        .frame(width: maxWidth + titlePadding * 2, alignment: .trailing)
    }
}

extension TitleView where RightContent == EmptyView, LeftContent == EmptyView {
    init(title: String?) {
        self.title = title
        self.leftButton = EmptyView()
        self.rightButton = EmptyView()
    }
}

extension TitleView where RightContent == EmptyView {
    init(title: String?, @ViewBuilder leftButton: () -> LeftContent) {
        self.title = title
        self.leftButton = leftButton()
        self.rightButton = EmptyView()
    }
}

extension TitleView where LeftContent == EmptyView {
    init(title: String?, @ViewBuilder rightButton: () -> RightContent) {
        self.title = title
        self.leftButton = EmptyView()
        self.rightButton = rightButton()
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(title: "title")
    }
}
