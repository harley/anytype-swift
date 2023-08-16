import SwiftUI

struct EditButtonStyled: View {
    
    var body: some View {
        EditButton()
            .font(AnytypeFontBuilder.font(anytypeFont: .uxTitle2Regular))
            .foregroundColor(Color.Button.active)
    }
    
}

struct EditButtonStyled_Previews: PreviewProvider {
    static var previews: some View {
        EditButtonStyled()
    }
}
