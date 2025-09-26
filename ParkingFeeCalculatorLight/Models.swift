//
//  Models.swift
//  ParkingFeeCalculatorLight
//
//  통합 데이터 모델
//

import Foundation

// MARK: - 주차장 기본값 상수
public struct ParkingLotDefaults {
    // 기본 요금 설정
    public static let initialFee = 2000
    public static let initialMinutes = 30
    public static let additionalFee = 500
    public static let additionalMinutes = 5
    public static let maxFee = 20000
    public static let freeMinutes = 0
    public static let dailyMaxFee = 20000

    // 야간 요금 설정
    public static let nightFlatFee = 0
    public static let nightStartHour = 22
    public static let nightEndHour = 7

    // 할인율 기본값
    public static let mildDiscountPercentage: Double = 80
    public static let severeDiscountPercentage: Double = 80
    public static let nationalMeritDiscountPercentage: Double = 80
    public static let exemplaryTaxpayerDiscountPercentage: Double = 100
    public static let multiChildDiscountPercentage: Double = 50
    public static let seniorDiscountPercentage: Double = 50

    // 차량 크기별 할인율
    public static let lightCarDiscountPercentage: Double = 50
    public static let normalCarDiscountPercentage: Double = 0
    public static let largeCarDiscountPercentage: Double = 100

    // 친환경 차량 할인율
    public static let electricDiscountPercentage: Double = 50
    public static let hydrogenDiscountPercentage: Double = 50
    public static let hybridDiscountPercentage: Double = 50
}

// MARK: - VehicleProfile
public struct VehicleProfile: Codable, Identifiable, Equatable, Hashable {
    public var id: UUID = UUID()
    public var vehicleSize: VehicleSize
    public var isElectric: Bool
    public var isHydrogen: Bool
    public var isHybrid: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        vehicleSize: VehicleSize = .normal,
        isElectric: Bool = false,
        isHydrogen: Bool = false,
        isHybrid: Bool = false
    ) {
        self.vehicleSize = vehicleSize
        self.isElectric = isElectric
        self.isHydrogen = isHydrogen
        self.isHybrid = isHybrid
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

public enum VehicleSize: String, CaseIterable, Codable {
    case light = "light"
    case normal = "normal"
    case large = "large"

    public var displayName: String {
        switch self {
        case .light:
            return "경차"
        case .normal:
            return "일반"
        case .large:
            return "대형"
        }
    }
}

// MARK: - VehicleProfile Extensions
public extension VehicleProfile {
    var displayName: String {
        return vehicleSize.displayName
    }

    var isEcoFriendly: Bool {
        return isElectric || isHydrogen || isHybrid
    }

    var ecoFriendlyType: String {
        var types: [String] = []
        if isElectric { types.append("전기차") }
        if isHydrogen { types.append("수소차") }
        if isHybrid { types.append("하이브리드") }
        return types.isEmpty ? "일반" : types.joined(separator: ", ")
    }

    var isProfileComplete: Bool {
        return true // 차량 크기만 있으면 완성된 것으로 간주
    }
}

// MARK: - DriverProfile
public struct DriverProfile: Codable, Identifiable, Equatable, Hashable {
    public var id: UUID = UUID()
    public var isDisabled: Bool
    public var disabilityLevel: DisabilityLevel?
    public var isNationalMerit: Bool
    public var isExemplaryTaxpayer: Bool
    public var isMultiChild: Bool
    public var isSenior: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        isDisabled: Bool = false,
        disabilityLevel: DisabilityLevel? = nil,
        isNationalMerit: Bool = false,
        isExemplaryTaxpayer: Bool = false,
        isMultiChild: Bool = false,
        isSenior: Bool = false
    ) {
        self.isDisabled = isDisabled
        self.disabilityLevel = disabilityLevel
        self.isNationalMerit = isNationalMerit
        self.isExemplaryTaxpayer = isExemplaryTaxpayer
        self.isMultiChild = isMultiChild
        self.isSenior = isSenior
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

public enum DisabilityLevel: String, CaseIterable, Codable {
    case mild = "mild"
    case severe = "severe"

    public var displayName: String {
        switch self {
        case .mild:
            return "경증"
        case .severe:
            return "중증"
        }
    }

    public var discountPercentage: Double {
        switch self {
        case .mild:
            return 20.0 // 경증 20% 할인
        case .severe:
            return 50.0 // 중증 50% 할인
        }
    }
}

// MARK: - DriverProfile Extensions
public extension DriverProfile {
    var isProfileComplete: Bool {
        return true // 특별 조건만 있으면 완성된 것으로 간주
    }

    var displayName: String {
        var descriptions: [String] = []

        if isDisabled {
            if let level = disabilityLevel {
                descriptions.append("\(level.displayName) 장애인")
            } else {
                descriptions.append("장애인")
            }
        }

        if isNationalMerit {
            descriptions.append("국가유공자")
        }

        if isExemplaryTaxpayer {
            descriptions.append("모범납세자")
        }

        if isMultiChild {
            descriptions.append("다자녀")
        }

        if isSenior {
            descriptions.append("고령자")
        }

        if descriptions.isEmpty {
            return "일반 운전자"
        } else {
            return descriptions.joined(separator: ", ") + " 운전자"
        }
    }

    var disabilityDiscountPercentage: Double {
        guard isDisabled, let level = disabilityLevel else { return 0.0 }
        return level.discountPercentage
    }

    var hasAnySpecialCondition: Bool {
        return isDisabled || isNationalMerit || isExemplaryTaxpayer || isMultiChild || isSenior
    }

    var specialConditionsCount: Int {
        var count = 0
        if isDisabled { count += 1 }
        if isNationalMerit { count += 1 }
        if isExemplaryTaxpayer { count += 1 }
        if isMultiChild { count += 1 }
        if isSenior { count += 1 }
        return count
    }
}

// MARK: - Special Condition Discounts
public struct SpecialConditionDiscounts: Codable, Equatable, Hashable {
    public var mildDiscountPercentage: Double?
    public var severeDiscountPercentage: Double?
    public var nationalMeritDiscountPercentage: Double?
    public var exemplaryTaxpayerDiscountPercentage: Double?
    public var multiChildDiscountPercentage: Double?
    public var seniorDiscountPercentage: Double?

    // 차량 관련 할인
    public var lightCarDiscountPercentage: Double?
    public var normalCarDiscountPercentage: Double?
    public var largeCarDiscountPercentage: Double?

    public var electricDiscountPercentage: Double?
    public var hydrogenDiscountPercentage: Double?
    public var hybridDiscountPercentage: Double?

    public init(
        mildDiscountPercentage: Double? = nil,
        severeDiscountPercentage: Double? = nil,
        nationalMeritDiscountPercentage: Double? = nil,
        exemplaryTaxpayerDiscountPercentage: Double? = nil,
        multiChildDiscountPercentage: Double? = nil,
        seniorDiscountPercentage: Double? = nil,
        lightCarDiscountPercentage: Double? = nil,
        normalCarDiscountPercentage: Double? = nil,
        largeCarDiscountPercentage: Double? = nil,
        electricDiscountPercentage: Double? = nil,
        hydrogenDiscountPercentage: Double? = nil,
        hybridDiscountPercentage: Double? = nil
    ) {
        self.mildDiscountPercentage = mildDiscountPercentage
        self.severeDiscountPercentage = severeDiscountPercentage
        self.nationalMeritDiscountPercentage = nationalMeritDiscountPercentage
        self.exemplaryTaxpayerDiscountPercentage = exemplaryTaxpayerDiscountPercentage
        self.multiChildDiscountPercentage = multiChildDiscountPercentage
        self.seniorDiscountPercentage = seniorDiscountPercentage
        self.lightCarDiscountPercentage = lightCarDiscountPercentage
        self.normalCarDiscountPercentage = normalCarDiscountPercentage
        self.largeCarDiscountPercentage = largeCarDiscountPercentage
        self.electricDiscountPercentage = electricDiscountPercentage
        self.hydrogenDiscountPercentage = hydrogenDiscountPercentage
        self.hybridDiscountPercentage = hybridDiscountPercentage
    }
}

// MARK: - SpecialConditionDiscounts Extensions
public extension SpecialConditionDiscounts {
    /// 설정된 할인이 하나라도 있는지 확인합니다
    var hasAnyDiscount: Bool {
        return mildDiscountPercentage != nil ||
               severeDiscountPercentage != nil ||
               nationalMeritDiscountPercentage != nil ||
               exemplaryTaxpayerDiscountPercentage != nil ||
               multiChildDiscountPercentage != nil ||
               seniorDiscountPercentage != nil ||
               lightCarDiscountPercentage != nil ||
               normalCarDiscountPercentage != nil ||
               largeCarDiscountPercentage != nil ||
               electricDiscountPercentage != nil ||
               hydrogenDiscountPercentage != nil ||
               hybridDiscountPercentage != nil
    }

    /// 운전자 관련 할인이 있는지 확인합니다
    var hasDriverDiscounts: Bool {
        return mildDiscountPercentage != nil ||
               severeDiscountPercentage != nil ||
               nationalMeritDiscountPercentage != nil ||
               exemplaryTaxpayerDiscountPercentage != nil ||
               multiChildDiscountPercentage != nil ||
               seniorDiscountPercentage != nil
    }

    /// 차량 관련 할인이 있는지 확인합니다
    var hasVehicleDiscounts: Bool {
        return lightCarDiscountPercentage != nil ||
               normalCarDiscountPercentage != nil ||
               largeCarDiscountPercentage != nil ||
               electricDiscountPercentage != nil ||
               hydrogenDiscountPercentage != nil ||
               hybridDiscountPercentage != nil
    }

    /// 설정된 할인들의 표시 설명을 반환합니다
    var displayDescription: String {
        var descriptions: [String] = []

        // 운전자 관련 할인
        if let percentage = mildDiscountPercentage {
            descriptions.append("경증 장애인 \(Int(percentage))%")
        }
        if let percentage = severeDiscountPercentage {
            descriptions.append("중증 장애인 \(Int(percentage))%")
        }
        if let percentage = nationalMeritDiscountPercentage {
            descriptions.append("국가유공자 \(Int(percentage))%")
        }
        if let percentage = exemplaryTaxpayerDiscountPercentage {
            descriptions.append("모범납세자 \(Int(percentage))%")
        }
        if let percentage = multiChildDiscountPercentage {
            descriptions.append("다자녀 \(Int(percentage))%")
        }
        if let percentage = seniorDiscountPercentage {
            descriptions.append("고령자 \(Int(percentage))%")
        }

        // 차량 크기별 할인
        if let percentage = lightCarDiscountPercentage {
            descriptions.append("경차 \(Int(percentage))%")
        }
        if let percentage = normalCarDiscountPercentage {
            descriptions.append("일반차 \(Int(percentage))%")
        }
        if let percentage = largeCarDiscountPercentage {
            descriptions.append("대형차 \(Int(percentage))%")
        }

        // 친환경 차량 할인
        if let percentage = electricDiscountPercentage {
            descriptions.append("전기차 \(Int(percentage))%")
        }
        if let percentage = hydrogenDiscountPercentage {
            descriptions.append("수소차 \(Int(percentage))%")
        }
        if let percentage = hybridDiscountPercentage {
            descriptions.append("하이브리드 \(Int(percentage))%")
        }

        return descriptions.isEmpty ? "할인 없음" : descriptions.joined(separator: ", ")
    }
}

// MARK: - 야간 요금 타입 enum
public enum NightRateType: String, Codable, CaseIterable {
    case flat = "flat"           // 정액 요금
    case percentage = "percentage" // 퍼센트 할인

    public var displayName: String {
        switch self {
        case .flat:
            return "정액 요금"
        case .percentage:
            return "할인율 적용"
        }
    }
}

// MARK: - 시간 구간별 차등 요금 구조체
public struct TimeBasedPricingTier: Codable, Identifiable, Equatable, Hashable {
    public var id: UUID = UUID()
    public var thresholdMinutes: Int  // 기준 시간 (분)
    public var feePerUnit: Int        // 단위당 요금
    public var unitMinutes: Int       // 단위 시간 (분)

    public init(thresholdMinutes: Int, feePerUnit: Int, unitMinutes: Int) {
        self.thresholdMinutes = thresholdMinutes
        self.feePerUnit = feePerUnit
        self.unitMinutes = unitMinutes
    }
}

// MARK: - ParkingFeeCalculator
public struct ParkingFeeCalculator: Codable, Identifiable, Equatable, Hashable {
    public var id: UUID = UUID()
    public var initialFee: Int
    public var initialMinutes: Int
    public var additionalFee: Int
    public var additionalMinutes: Int
    public var maxFee: Int?
    public var freeMinutes: Int
    public var dailyMaxFee: Int?
    public var nightFlatFee: Int?
    public var nightStartHour: Int?
    public var nightEndHour: Int?
    public var nightRateType: NightRateType
    public var nightDiscountPercentage: Double?
    public var useTimeBasedPricing: Bool
    public var pricingTiers: [TimeBasedPricingTier]
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        initialFee: Int = ParkingLotDefaults.initialFee,
        initialMinutes: Int = ParkingLotDefaults.initialMinutes,
        additionalFee: Int = ParkingLotDefaults.additionalFee,
        additionalMinutes: Int = ParkingLotDefaults.additionalMinutes,
        maxFee: Int? = nil,
        freeMinutes: Int = ParkingLotDefaults.freeMinutes,
        dailyMaxFee: Int? = nil,
        nightFlatFee: Int? = nil,
        nightStartHour: Int? = nil,
        nightEndHour: Int? = nil,
        nightRateType: NightRateType = .flat,
        nightDiscountPercentage: Double? = nil,
        useTimeBasedPricing: Bool = false,
        pricingTiers: [TimeBasedPricingTier] = []
    ) {
        self.initialFee = initialFee
        self.initialMinutes = initialMinutes
        self.additionalFee = additionalFee
        self.additionalMinutes = additionalMinutes
        self.maxFee = maxFee
        self.freeMinutes = freeMinutes
        self.dailyMaxFee = dailyMaxFee
        self.nightFlatFee = nightFlatFee
        self.nightStartHour = nightStartHour
        self.nightEndHour = nightEndHour
        self.nightRateType = nightRateType
        self.nightDiscountPercentage = nightDiscountPercentage
        self.useTimeBasedPricing = useTimeBasedPricing
        self.pricingTiers = pricingTiers
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - ParkingFeeCalculator Extensions
public extension ParkingFeeCalculator {
    var isProfileComplete: Bool {
        return initialFee > 0 && initialMinutes > 0 && additionalFee > 0 && additionalMinutes > 0
    }

    var hasNightRate: Bool {
        return nightFlatFee != nil && nightStartHour != nil && nightEndHour != nil
    }

    var hasDailyMax: Bool {
        return dailyMaxFee != nil
    }

    var hasMaxFee: Bool {
        return maxFee != nil
    }

    func isNightTime() -> Bool {
        guard let startHour = nightStartHour, let endHour = nightEndHour else { return false }

        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)

        if startHour <= endHour {
            return currentHour >= startHour && currentHour < endHour
        } else {
            // 자정을 넘어가는 경우 (예: 22시~06시)
            return currentHour >= startHour || currentHour < endHour
        }
    }

    /// 주차비를 계산합니다. 할인을 적용하여 최종 요금을 반환합니다.
    func calculateFee(
        duration: TimeInterval,
        vehicleProfile: VehicleProfile,
        driverProfile: DriverProfile,
        specialConditionDiscounts: SpecialConditionDiscounts,
        startTime: Date = Date(),
        additionalFreeMinutes: Int = 0
    ) -> ParkingFeeResult {
        // 기본 주차비 계산 (추가 무료시간 반영)
        let baseFee = calculateBaseFee(duration: duration, additionalFreeMinutes: additionalFreeMinutes)

        var totalFee = baseFee

        // 최대 요금 제한 (할인 적용 전)
        if let maxFee = self.maxFee {
            totalFee = min(totalFee, maxFee)
        }

        // 적용 가능한 할인 찾기
        let applicableDiscounts = findApplicableDiscounts(
            vehicleProfile: vehicleProfile,
            driverProfile: driverProfile,
            specialConditionDiscounts: specialConditionDiscounts
        )

        // 가장 높은 할인율 찾기
        let bestDiscount = findBestDiscount(from: applicableDiscounts)

        // 할인 적용
        var finalFee = totalFee
        var appliedDiscount: DiscountInfo?

        if let discount = bestDiscount {
            // 부동소수점 정밀도 문제를 해결하기 위해 반올림 사용
            let discountedAmount = Double(totalFee) * (1.0 - discount.percentage / 100.0)
            finalFee = Int(round(discountedAmount))
            appliedDiscount = discount
        }

        // 일일 최대 요금 제한
        if let dailyMaxFee = self.dailyMaxFee {
            finalFee = min(finalFee, dailyMaxFee)
        }

        return ParkingFeeResult(
            baseFee: baseFee,
            totalFeeBeforeDiscount: totalFee,
            appliedDiscount: appliedDiscount,
            finalFee: finalFee,
            applicableDiscounts: applicableDiscounts
        )
    }

    /// 기본 주차비를 계산합니다 (차량 크기 배수와 할인 제외)
    private func calculateBaseFee(duration: TimeInterval, additionalFreeMinutes: Int = 0) -> Int {
        // 총 무료 시간 계산
        let totalFreeMinutes = freeMinutes + additionalFreeMinutes

        // 무료 시간 체크
        if duration <= TimeInterval(totalFreeMinutes * 60) {
            return 0
        }

        // 기본 시간 이후 계산
        let chargeableDuration = duration - TimeInterval(totalFreeMinutes * 60)
        let chargeableMinutes = Int(ceil(chargeableDuration / 60))

        // 야간 요금 체크
        if isNightTime() {
            return calculateNightRateFee(chargeableMinutes: chargeableMinutes)
        }

        // 시간 구간별 요금 계산
        if useTimeBasedPricing && !pricingTiers.isEmpty {
            return calculateTimeBasedFee(chargeableMinutes: chargeableMinutes)
        }

        // 기존 단일 요금 체계 계산
        return calculateSimpleFee(chargeableMinutes: chargeableMinutes)
    }

    /// 시간 구간별 차등 요금 계산
    private func calculateTimeBasedFee(chargeableMinutes: Int) -> Int {
        var totalFee = 0
        var remainingMinutes = chargeableMinutes

        // 초기 요금 처리
        if remainingMinutes > 0 {
            let initialUnits = min(remainingMinutes, initialMinutes)
            if initialUnits > 0 {
                totalFee = initialFee
                remainingMinutes -= initialMinutes
            }
        }

        if remainingMinutes <= 0 {
            return totalFee
        }

        // 구간별로 정렬된 pricing tiers 적용
        let sortedTiers = pricingTiers.sorted { $0.thresholdMinutes < $1.thresholdMinutes }
        var currentThreshold = initialMinutes

        for tier in sortedTiers {
            if remainingMinutes <= 0 { break }

            // 현재 구간에서 처리할 시간 계산
            if currentThreshold < tier.thresholdMinutes {
                // 현재 threshold부터 다음 tier threshold까지는 기본 추가요금으로 계산
                let minutesToProcess = min(remainingMinutes, tier.thresholdMinutes - currentThreshold)
                if minutesToProcess > 0 {
                    let units = Int(ceil(Double(minutesToProcess) / Double(additionalMinutes)))
                    totalFee += units * additionalFee
                    remainingMinutes -= minutesToProcess
                }
                currentThreshold = tier.thresholdMinutes
            }

            // tier threshold 이후는 해당 tier의 요금으로 계산
            if remainingMinutes > 0 {
                // 다음 tier가 있다면 그 threshold까지, 없다면 모든 남은 시간
                let nextThreshold = sortedTiers.first(where: { $0.thresholdMinutes > tier.thresholdMinutes })?.thresholdMinutes ?? Int.max
                let tierMinutes = min(remainingMinutes, nextThreshold - tier.thresholdMinutes)

                if tierMinutes > 0 {
                    let units = Int(ceil(Double(tierMinutes) / Double(tier.unitMinutes)))
                    totalFee += units * tier.feePerUnit
                    remainingMinutes -= tierMinutes
                    currentThreshold = tier.thresholdMinutes + tierMinutes
                }
            }
        }

        // 마지막 tier 이후 남은 시간이 있다면 마지막 tier 요금으로 계산
        if remainingMinutes > 0, let lastTier = sortedTiers.last {
            let units = Int(ceil(Double(remainingMinutes) / Double(lastTier.unitMinutes)))
            totalFee += units * lastTier.feePerUnit
        }

        return totalFee
    }

    /// 기존 단일 요금 체계 계산
    private func calculateSimpleFee(chargeableMinutes: Int) -> Int {
        if chargeableMinutes <= initialMinutes {
            return initialFee
        }

        // 추가 시간 계산
        let extraMinutes = chargeableMinutes - initialMinutes
        let additionalUnits = Int(ceil(Double(extraMinutes) / Double(self.additionalMinutes)))
        let extraFee = additionalUnits * self.additionalFee

        return initialFee + extraFee
    }

    /// 야간 요금을 계산합니다
    private func calculateNightRateFee(chargeableMinutes: Int) -> Int {
        switch nightRateType {
        case .flat:
            // 정액 요금 적용
            guard let flatFee = nightFlatFee else {
                // 야간 정액 요금이 설정되지 않은 경우 일반 요금으로 계산
                return useTimeBasedPricing && !pricingTiers.isEmpty ?
                    calculateTimeBasedFee(chargeableMinutes: chargeableMinutes) :
                    calculateSimpleFee(chargeableMinutes: chargeableMinutes)
            }
            return flatFee

        case .percentage:
            // 할인율 적용
            guard let discountPercentage = nightDiscountPercentage else {
                // 할인율이 설정되지 않은 경우 일반 요금으로 계산
                return useTimeBasedPricing && !pricingTiers.isEmpty ?
                    calculateTimeBasedFee(chargeableMinutes: chargeableMinutes) :
                    calculateSimpleFee(chargeableMinutes: chargeableMinutes)
            }

            // 일반 요금 계산 후 할인 적용
            let normalFee = useTimeBasedPricing && !pricingTiers.isEmpty ?
                calculateTimeBasedFee(chargeableMinutes: chargeableMinutes) :
                calculateSimpleFee(chargeableMinutes: chargeableMinutes)

            let discountedAmount = Double(normalFee) * (1.0 - discountPercentage / 100.0)
            return Int(round(discountedAmount))
        }
    }

    /// 적용 가능한 할인들을 찾습니다
    private func findApplicableDiscounts(
        vehicleProfile: VehicleProfile,
        driverProfile: DriverProfile,
        specialConditionDiscounts: SpecialConditionDiscounts
    ) -> [DiscountInfo] {
        var applicableDiscounts: [DiscountInfo] = []

        // 운전자 관련 할인 확인
        if driverProfile.isDisabled, let level = driverProfile.disabilityLevel {
            switch level {
            case .mild:
                if let discountPercentage = specialConditionDiscounts.mildDiscountPercentage {
                    applicableDiscounts.append(DiscountInfo(
                        name: "경증 장애인",
                        percentage: discountPercentage,
                        type: .driver
                    ))
                }
            case .severe:
                if let discountPercentage = specialConditionDiscounts.severeDiscountPercentage {
                    applicableDiscounts.append(DiscountInfo(
                        name: "중증 장애인",
                        percentage: discountPercentage,
                        type: .driver
                    ))
                }
            }
        }

        if driverProfile.isNationalMerit {
            if let discountPercentage = specialConditionDiscounts.nationalMeritDiscountPercentage {
                applicableDiscounts.append(DiscountInfo(
                    name: "국가유공자",
                    percentage: discountPercentage,
                    type: .driver
                ))
            }
        }

        if driverProfile.isExemplaryTaxpayer {
            if let discountPercentage = specialConditionDiscounts.exemplaryTaxpayerDiscountPercentage {
                applicableDiscounts.append(DiscountInfo(
                    name: "모범납세자",
                    percentage: discountPercentage,
                    type: .driver
                ))
            }
        }

        if driverProfile.isMultiChild {
            if let discountPercentage = specialConditionDiscounts.multiChildDiscountPercentage {
                applicableDiscounts.append(DiscountInfo(
                    name: "다자녀",
                    percentage: discountPercentage,
                    type: .driver
                ))
            }
        }

        if driverProfile.isSenior {
            if let discountPercentage = specialConditionDiscounts.seniorDiscountPercentage {
                applicableDiscounts.append(DiscountInfo(
                    name: "고령자",
                    percentage: discountPercentage,
                    type: .driver
                ))
            }
        }

        // 차량 관련 할인 확인
        switch vehicleProfile.vehicleSize {
        case .light:
            if let discountPercentage = specialConditionDiscounts.lightCarDiscountPercentage {
                applicableDiscounts.append(DiscountInfo(
                    name: "경차",
                    percentage: discountPercentage,
                    type: .vehicle
                ))
            }
        case .normal:
            if let discountPercentage = specialConditionDiscounts.normalCarDiscountPercentage {
                applicableDiscounts.append(DiscountInfo(
                    name: "일반",
                    percentage: discountPercentage,
                    type: .vehicle
                ))
            }
        case .large:
            if let discountPercentage = specialConditionDiscounts.largeCarDiscountPercentage {
                applicableDiscounts.append(DiscountInfo(
                    name: "대형",
                    percentage: discountPercentage,
                    type: .vehicle
                ))
            }
        }

        // 친환경 차량 할인 확인
        if vehicleProfile.isElectric {
            if let discountPercentage = specialConditionDiscounts.electricDiscountPercentage {
                applicableDiscounts.append(DiscountInfo(
                    name: "전기차",
                    percentage: discountPercentage,
                    type: .environmental
                ))
            }
        }

        if vehicleProfile.isHydrogen {
            if let discountPercentage = specialConditionDiscounts.hydrogenDiscountPercentage {
                applicableDiscounts.append(DiscountInfo(
                    name: "수소차",
                    percentage: discountPercentage,
                    type: .environmental
                ))
            }
        }

        if vehicleProfile.isHybrid {
            if let discountPercentage = specialConditionDiscounts.hybridDiscountPercentage {
                applicableDiscounts.append(DiscountInfo(
                    name: "하이브리드",
                    percentage: discountPercentage,
                    type: .environmental
                ))
            }
        }

        return applicableDiscounts
    }

    /// 가장 높은 할인율을 가진 할인을 찾습니다
    private func findBestDiscount(from discounts: [DiscountInfo]) -> DiscountInfo? {
        guard !discounts.isEmpty else { return nil }

        return discounts.max { discount1, discount2 in
            discount1.percentage < discount2.percentage
        }
    }
}

// MARK: - ParkingLotProfile
public struct ParkingLotProfile: Codable, Identifiable, Equatable, Hashable {
    public var id: UUID
    public var name: String
    public var address: String
    public var parkingFeeCalculator: ParkingFeeCalculator
    public var specialConditionDiscounts: SpecialConditionDiscounts
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        name: String = "",
        address: String = "",
        parkingFeeCalculator: ParkingFeeCalculator = ParkingFeeCalculator(),
        specialConditionDiscounts: SpecialConditionDiscounts = SpecialConditionDiscounts()
    ) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.parkingFeeCalculator = parkingFeeCalculator
        self.specialConditionDiscounts = specialConditionDiscounts
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // 기존 ID와 생성일을 유지하면서 업데이트하기 위한 초기화 메서드
    public init(
        id: UUID,
        name: String,
        address: String,
        parkingFeeCalculator: ParkingFeeCalculator,
        specialConditionDiscounts: SpecialConditionDiscounts,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.parkingFeeCalculator = parkingFeeCalculator
        self.specialConditionDiscounts = specialConditionDiscounts
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - ParkingLotProfile Extensions
public extension ParkingLotProfile {
    var displayName: String {
        return name.isEmpty ? "미등록 주차장" : name
    }

    var isProfileComplete: Bool {
        return !name.isEmpty && !address.isEmpty
    }
}

// MARK: - 결과 타입들
public struct ParkingFeeResult {
    public let baseFee: Int
    public let totalFeeBeforeDiscount: Int
    public let appliedDiscount: DiscountInfo?
    public let finalFee: Int
    public let applicableDiscounts: [DiscountInfo]

    public init(baseFee: Int, totalFeeBeforeDiscount: Int, appliedDiscount: DiscountInfo?, finalFee: Int, applicableDiscounts: [DiscountInfo]) {
        self.baseFee = baseFee
        self.totalFeeBeforeDiscount = totalFeeBeforeDiscount
        self.appliedDiscount = appliedDiscount
        self.finalFee = finalFee
        self.applicableDiscounts = applicableDiscounts
    }

    public var discountAmount: Int {
        return totalFeeBeforeDiscount - finalFee
    }

    public var discountPercentage: Double {
        guard totalFeeBeforeDiscount > 0 else { return 0.0 }
        return Double(discountAmount) / Double(totalFeeBeforeDiscount) * 100.0
    }

    public var appliedDiscountDescription: String {
        guard let discount = appliedDiscount else { return "할인 없음" }
        return "\(discount.name) (-\(Int(discount.percentage))%)"
    }

    public var applicableDiscountsDescription: String {
        guard !applicableDiscounts.isEmpty else { return "적용 가능한 할인 없음" }

        let descriptions = applicableDiscounts.map { discount in
            "\(discount.name) \(Int(discount.percentage))%"
        }

        return descriptions.joined(separator: ", ")
    }

    public var discountInfo: String? {
        if applicableDiscounts.isEmpty {
            return nil
        } else if applicableDiscounts.count == 1 {
            return "적용된 할인: \(applicableDiscounts[0].name) \(Int(applicableDiscounts[0].percentage))%"
        } else {
            return "적용 가능: \(applicableDiscounts.map { "\($0.name) \(Int($0.percentage))%" }.joined(separator: ", "))"
        }
    }
}

public struct DiscountInfo {
    public let name: String
    public let percentage: Double
    public let type: DiscountType

    public init(name: String, percentage: Double, type: DiscountType) {
        self.name = name
        self.percentage = percentage
        self.type = type
    }

    public enum DiscountType {
        case driver
        case vehicle
        case environmental
    }
}

// MARK: - ParkingSession
/// 주차 세션의 상태
public enum ParkingSessionStatus: String, Codable, CaseIterable {
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"

    public var displayName: String {
        switch self {
        case .active:
            return "진행중"
        case .completed:
            return "완료"
        case .cancelled:
            return "취소"
        }
    }
}

/// 주차 세션 정보
public struct ParkingSession: Codable, Equatable, Hashable {
    public let sessionId: String
    public let startTime: Date
    public let parkingLot: ParkingLotProfile
    public let vehicle: VehicleProfile
    public let driver: DriverProfile
    public let additionalFreeMinutes: Int

    // 현재 경과 시간 (초)
    public var elapsedTime: TimeInterval {
        Date().timeIntervalSince(startTime)
    }

    // 현재 경과 시간 (분)
    public var elapsedMinutes: Int {
        Int(elapsedTime / 60)
    }

    public init(
        sessionId: String? = nil, // 옵셔널로 하여 자동 생성 지원
        startTime: Date,
        parkingLot: ParkingLotProfile,
        vehicle: VehicleProfile,
        driver: DriverProfile,
        additionalFreeMinutes: Int = 0
    ) {
        // sessionId가 제공되지 않으면 UUID로 자동 생성
        self.sessionId = sessionId ?? UUID().uuidString
        self.startTime = startTime
        self.parkingLot = parkingLot
        self.vehicle = vehicle
        self.driver = driver
        self.additionalFreeMinutes = additionalFreeMinutes
    }

    // 현재 주차비 계산
    public func calculateCurrentFee() -> ParkingFeeResult {
        return parkingLot.parkingFeeCalculator.calculateFee(
            duration: elapsedTime,
            vehicleProfile: vehicle,
            driverProfile: driver,
            specialConditionDiscounts: parkingLot.specialConditionDiscounts,
            additionalFreeMinutes: additionalFreeMinutes
        )
    }
}

// MARK: - UserDefaults 저장/불러오기를 위한 확장
public extension ParkingSession {
    /// UserDefaults에 저장 가능한 딕셔너리로 변환
    func toDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970

        let data = try encoder.encode(self)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        return json ?? [:]
    }

    /// UserDefaults 딕셔너리에서 복원
    static func fromDictionary(_ dict: [String: Any]) throws -> ParkingSession {
        let data = try JSONSerialization.data(withJSONObject: dict)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        return try decoder.decode(ParkingSession.self, from: data)
    }
}