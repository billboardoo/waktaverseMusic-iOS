//
//  Extensions.swift
//  Billboardoo
//
//  Created by yongbeomkwak on 2022/08/05.
//

import Foundation
import SwiftUI

extension Color {
    
    init(hexcode:String)
    {
        let scanner = Scanner(string: hexcode)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = (rgbValue & 0xff0000) >> 16
        let green = (rgbValue & 0xff00) >> 8
        let blue = rgbValue & 0xff
        
        self.init(red:Double(red)/0xff,green: Double(green)/0xff,blue: Double(blue)/0xff)
    }
}

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

extension UIImage {
    //평균 색깔 구역
    var averageColor: UIColor? {
        
        //UIImage를 CIImage로 변환
        guard let inputImage = CIImage(image: self) else{ return nil }
        
        // extent vector 생성 ( width와 height은 input 이미지 그대로)
        let extentVector = CIVector (x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        
        //CIAreaAverage 이름이란 필터 만듬 , image에서 평균 색깔을 뽑아낼 것
        guard let filter = CIFilter(name: "CIAreaAverage",parameters:[kCIInputImageKey:inputImage, kCIInputExtentKey: extentVector]) else { return nil}
        
        //필터로 부터 뽑아낸 이미지
        guard let outputImage = filter.outputImage else { return nil}
        
        // bitmap (r,g,b,a)
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        
        // output 이미지를 1대1로 bitmap에 r g b a값을 뽑아내어 bitmap 배열 채워 랜더시킨다
        
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        
        //bitmap image를 rgba UIColor로 변환
        return UIColor(red: CGFloat(bitmap[0])*0.6/255, green: CGFloat(bitmap[1])*0.6/255, blue: CGFloat(bitmap[2])*0.6/255, alpha: CGFloat(bitmap[3])/255)
        
    }
}


extension View {
    func border(width: CGFloat, edges: [Edge], color: SwiftUI.Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
