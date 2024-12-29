//
//  RestroomDataSource.swift
//  Urgent
//
//  Created by jang gukjin on 11/08/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import Foundation

struct RestroomDataSource {
    func getSwiftArrayFromPlist(name: String) -> Array<Dictionary<String,String>> {
        let path = Bundle.main.path(forResource: name, ofType: "plist")
        var arr: NSArray?
        arr = NSArray(contentsOfFile: path!)
        return (arr as? Array<Dictionary<String,String>>)!
    }
    
    func getDataForFata() -> Array<[String:String]> {
        let array = getSwiftArrayFromPlist(name: "toilet_20240719") + additionalData
        let filteredArray = array.filter { isCorrectData($0) }
        return filteredArray
    }
    
    private func isCorrectData(_ data: [String: String]) -> Bool {
        guard let lat = data["위도"]?.toDouble, let long = data["경도"]?.toDouble else { return false }
        
        if lat >= 33, lat <= 39, long >= 124, long <= 132 {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Property --------------------
    var additionalData: [[String: String]] = [
        // FIXME: 화장실 데이터가 수정되면 반드시 함께 수정되어야함
        ["개방시간": "", "개방시간상세": "", "경도": "127.4891091", "구분": "", "기저귀교환대유무": "", "기저귀교환대장소": "", "남성용-대변기수": "", "남성용-소변기수": "", "남성용-어린이용대변기수": "", "남성용-어린이용소변기수": "", "남성용-장애인용대변기수": "", "남성용-장애인용소변기수": "", "비상벨설치여부": "", "비상벨설치장소": "", "설치연월": "", "소재지도로명주소": "충북 청주시 상당구 중앙로 18 (시장 상가건물 내)", "소재지지번주소": "충청북도 청주시 상당구 북문로2가 92-2", "안전관리시설설치대상여부": "", "여성용-대변기수": "", "여성용-어린이용대변기수": "", "여성용-여성용-장애인용대변기수": "", "오물처리방식": "", "위도": "36.6388966", "전화번호": "", "화장실명": "중앙 아파트", "화장실소유구분": "", "화장실입구CCTV설치유무": "", "비데 유무": "없음", "비밀번호": "없음"]
    ]
}
