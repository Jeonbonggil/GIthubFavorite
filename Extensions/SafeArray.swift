//
//  SafeArray.swift
//  Sample
//
//  Created by africa on 2020/07/16.
//  Copyright © 2020 africa. All rights reserved.
//

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
    
    
    public subscript(safe bounds: Range<Int>) -> ArraySlice<Element> {
        if bounds.lowerBound > count { return [] }
        let lower = Swift.max(0, bounds.lowerBound)
        let upper = Swift.max(0, Swift.min(count, bounds.upperBound))
        return self[lower..<upper]
    }
    
    
    func json() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    // GA 이벤트라벨용 [text,text] -> text_text
    func toGALabel() -> String {
        guard self is [String] && self.count > 0 else { return "" }
        var gaLabel = ""
        for string in (self as? [String]) ?? [] {
            if string.count > 0 {
                gaLabel = gaLabel + (gaLabel.count > 0 ? "_" : "") + string
            }
        }
        return gaLabel
    }
}

extension Array {
    func maxCount(_ count: Int) -> Array {
        return self.enumerated().filter({ $0.offset < count }).map({ $0.element })
    }
}

extension Array where Element == SelectedOptionDataModel {
    
    typealias CartInfoListData = (cartInfoList: Array<[String: Any]>, ga: Array<[String: Any]>)
    
    func makeCartInfoList(withCartPopLayerRes res: CartPopLayerRes, withType type: CartInfoListType) -> [String: Any] {
        return [type.key(): cartInfoListData(withRes: res).cartInfoList]
    }
    
    func cartInfoListData(withRes res: CartPopLayerRes) -> CartInfoListData {
        var arrCartInfoList = Array<[String: Any]>()
        var arrGaCheckoutList = Array<[String: Any]>()
        
        for data in self {
            var dict = [String: Any]()
            if let prd = res.prd {
                dict["erpBrndCd"] = prd.erpBrndcCd
                dict["brndNo"] = prd.brndNo
                dict["dispShopNo"] = prd.dispShopNo // dispShopNo
                dict["mDispShopNo"] = prd.dispShopMdclNo // mDispShopNo
                dict["lDispShopNo"] = prd.dispShopLrclNo // lDispShopNo
            }

            dict["prdNo"] = data.prdNo
            dict["prdOptNo"] = data.prdOptNo
            dict["prdOptNm"] = data.prdOptNm
            dict["ordPrdKndCd"] = "01"
            dict["nrmCatNo"] = ""
            dict["ordQty"] = "\(data.ordQty)"
                                    
            arrCartInfoList.append(dict)
            arrGaCheckoutList = makeGaCheckoutList(dict, withData: data)
        }
        return (arrCartInfoList, arrGaCheckoutList)
    }
    
    func makeGaCheckoutList(_ dict: [String: Any], withData data: SelectedOptionDataModel) -> Array<[String: Any]> {
        var gaDict = dict
        gaDict["erpPrdNo"] = data.erpPrdNo
        gaDict["prdOptYn"] = data.prdOptYn
        return Array<[String: Any]>(arrayLiteral: gaDict)
    }
}
