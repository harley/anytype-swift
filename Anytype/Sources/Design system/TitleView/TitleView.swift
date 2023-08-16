import SwiftUI

struct TitleView<RightContent, LeftContent>: View where RightContent: View, LeftContent: View  {
    
    let title: String?
    let leftButton: LeftContent?
    let rightButton: RightContent?
    
    init(title: String?, @ViewBuilder leftButton: () -> LeftContent, @ViewBuilder rightButton: () -> RightContent) {
        self.title = title
        self.leftButton = leftButton()
        self.rightButton = rightButton()
    }
    
    var body: some View {
        VStack {
            Spacer.fixedHeight(8)
            content
        }
        .frame(maxWidth: .infinity)
//        .overlay(alignment: .leading, content: {
//            leftButton
//        })
//        .overlay(alignment: .trailing, content: {
//            rightButton
//        })
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
    
    var leftView: some View {
        Group {
            if let leftButton {
                leftButton
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    var principalView: some View {
        if let title = title {
            AnytypeText(title, style: .navigationBarTitle, color: .Text.primary)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
        }
    }
    
    var rightView: some View {
        Group {
            if let rightButton {
                rightButton
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
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
