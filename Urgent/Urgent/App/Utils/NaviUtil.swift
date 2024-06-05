//
//  NaviUtil.swift
//  Urgent
//
//  Created by jang gukjin on 6/5/24.
//  Copyright © 2024 jang gukjin. All rights reserved.
//

import Foundation

struct NaviUtil {
    func openKakaoNavi(latitude: Double, longitude: Double, destinationName: String) {
        let urlScheme = "kakaonavi://navigate?coord_type=wgs84&pos=\(longitude),\(latitude)&name=\(destinationName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let kakaoNaviURL = URL(string: urlScheme), UIApplication.shared.canOpenURL(kakaoNaviURL) {
            UIApplication.shared.open(kakaoNaviURL, options: [:], completionHandler: nil)
        } else {
            App.ui.alert(title: "Error", message: "Kakao Navi app is not installed")
        }
    }
    
    func openTmap(latitude: Double, longitude: Double, destinationName: String) {
        let urlScheme = "tmap://route?goalx=\(longitude)&goaly=\(latitude)&goalname=\(destinationName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let tmapURL = URL(string: urlScheme), UIApplication.shared.canOpenURL(tmapURL) {
            UIApplication.shared.open(tmapURL, options: [:], completionHandler: nil)
        } else {
            App.ui.alert(title: "Error", message: "Tmap app is not installed")
        }
    }
}
