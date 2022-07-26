//
//  SettingScreenView.swift
//  Billboardoo
//
//  Created by yongbeomkwak on 2022/07/20.
//

import SwiftUI

struct SettingScreenView: View {
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = UserDefaults.standard.bool(forKey: "isDarkMode")

    
    var body: some View {
        
        
        VStack
        {
            //토글 및 체인지 이벤트 , isOn: Binding
            Toggle("Dark Mode", isOn: $isDarkMode).onChange(of: isDarkMode) { result in
                //result 값이 of인 isDarkMode에 저장됨
                UserDefaults.standard.set(result, forKey: "isDarkMode") //기본 값 저장
                changeMode(isDarkMode: result)
            }
            
        }
        
        
        
        
        
    }
}



struct SettingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SettingScreenView()
    }
}

