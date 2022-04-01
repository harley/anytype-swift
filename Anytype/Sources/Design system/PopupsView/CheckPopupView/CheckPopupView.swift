//
//  CheckPopupView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 01.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels

struct CheckPopupView<ViewModel: CheckPopuViewViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: "Preview layout".localized)
            mainSection
        }
        .background(Color.backgroundSecondary)
        .padding(.horizontal, 20)
    }

    private var mainSection: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.items) { item in
                mainSectionRow(item) {
                    viewModel.onTap(item: item)
                }
                .divider()
            }
        }
    }

    private func mainSectionRow(_ item: CheckPopupItem, onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                if let iconName = item.icon {
                    Image(iconName)
                    Spacer.fixedWidth(12)
                }

                VStack(spacing: 0) {
                    AnytypeText(item.title, style: .uxBodyRegular, color: .textPrimary)

                    if let subtitle = item.subtitle {
                        AnytypeText(subtitle, style: .caption1Regular, color: .textSecondary)
                    }
                }
                Spacer()

                if item.isSelected {
                    Image.optionChecked.frame(width: 24, height: 24).foregroundColor(.buttonSelected)
                }
            }
            .frame(height: 52)
        }
    }
}

struct ObjectPreviewPopupView_Previews: PreviewProvider {
    final class CheckPopupTestViewModel: CheckPopuViewViewModelProtocol {
        func onTap(item: CheckPopupItem) {
        }

        var items: [CheckPopupItem] = [
            .init(id: "1", icon: ImageName.ObjectPreview.text, title: "Some title", subtitle: "Long subtitle", isSelected: true),
            .init(id: "2", icon: ImageName.ObjectPreview.text, title: "Other title", subtitle: "Long subtitle", isSelected: false)
        ]
    }

    static var previews: some View {
        let viewModel = CheckPopupTestViewModel()
        CheckPopupView(viewModel: viewModel)
    }
}
