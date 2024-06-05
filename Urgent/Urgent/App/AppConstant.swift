//
//  AppConstant.swift
//  Urgent
//
//  Created by jang gukjin on 6/5/24.
//  Copyright © 2024 jang gukjin. All rights reserved.
//

import Foundation

struct AppConstant {
    let adminMail: String = "kinersvi@naver.com"
    let mailSubject: String = "[급해App 문의]"
    let mailBody: String = """
                         화장실을 제보하시는 경우 아래 내용을 작성해 주세요.
                         
                         ================================
                         1. 주소:
                         2. 남녀화장실 분리 여부:
                         3. 비밀번호:
                         4. 비데 유무:
                         ===============================
                         """
    let mailFailMessageTitle: String = "기본 메일앱에 로그인 해주세요."
    let mailFailMessageBody: String = "혹은 kinersvi@naver.com으로 문의사항을 보내주세요."
}
