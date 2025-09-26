//
//  SettingViewModel.swift
//  ParkingFeeCalculatorLight
//
//  설정 뷰모델 - 알림 설정 관리
//

import Foundation
import SwiftUI
import Combine

class SettingViewModel: ObservableObject {
    @AppStorage("isParkingFeeAlertEnabled") var isParkingFeeAlertEnabled: Bool = false
    @AppStorage("parkingFeeAlertThreshold") var parkingFeeAlertThreshold: Int = 50000
}