//
//  NaviUtil.swift
//  Urgent
//
//  Created by jang gukjin on 6/5/24.
//  Copyright © 2024 jang gukjin. All rights reserved.
//

import Foundation
import KakaoSDKNavi

struct NaviUtil {
    func openNavi(latitude: Double, longitude: Double, destinationName: String) {
        let tmapUrlScheme = "tmap://route?goalx=\(longitude)&goaly=\(latitude)&goalname=\(destinationName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let destination: NaviLocation = .init(name: destinationName, x: "\(longitude)", y: "\(latitude)")
        
        guard let kakaoNavigateUrl = NaviApi.shared.navigateUrl(destination: destination, option: .init(coordType: .WGS84)) else {
            return
        }
        
        if let tmapURL = URL(string: tmapUrlScheme), UIApplication.shared.canOpenURL(tmapURL) {
            UIApplication.shared.open(tmapURL, options: [:], completionHandler: nil)
        } else if UIApplication.shared.canOpenURL(kakaoNavigateUrl) {
            UIApplication.shared.open(kakaoNavigateUrl, options: [:], completionHandler: nil)
        } else {
            App.ui.alert(title: "내비게이션앱 없음", message: "T맵 혹은 카카오내비를 설치해주세요.", actionTitle: "설치", isCancellable: true) { _ in
                if let url = URL(string: "itms-apps://itunes.apple.com/search?term=내비게이션"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}
