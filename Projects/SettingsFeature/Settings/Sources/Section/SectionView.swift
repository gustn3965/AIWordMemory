//
//  SectionView.swift
//  Settings
//
//  Created by 박현수 on 12/28/24.
//

import SwiftUI
import CommonUI


struct SectionView: View {
    
    var menuList: [SettingMenuList]
    
    var onItemTap: ((SettingMenuList) -> Void)?
    
    init(menuList: [SettingMenuList], onItemTap: ( (SettingMenuList) -> Void)? = nil) {
        self.menuList = menuList
        self.onItemTap = onItemTap
    }
    
    var body: some View {
        
        ZStack {
            BackgroundView()
            
            LazyVStack {
                ForEach(Array(menuList.enumerated()), id: \.element.id) { (index, item: SettingMenuList)in
                    VStack(alignment: .leading) {
                        
                        Button {
                            onItemTap?(item)
                            print("on Tap Cell \(item.name )")
                        } label: {
                            HStack {
                                Label {
                                    Text(LocalizedStringKey(item.name))
                                } icon: {
                                    Image(item.iconName, bundle: CommonUIResources.bundle)
                                }

                                Spacer() // 버튼으로바꾸거나해야겠다.
                                
                                Image(systemName: "chevron.right")
                            }
                        }
                        .padding()
                        if index != menuList.count - 1 {
                            Divider()
                        }
                    }
                    .onTapGesture {
                        //                            onItemTap?(item)
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    
    NavigationStack {
        SectionView(menuList: [.notice, .feedback])
    }
    .tint(Color.systemBlack)
}
