//
//  DataManager.swift
//  ParkingFeeCalculatorLight
//
//  간단한 UserDefaults 기반 데이터 관리
//

import Foundation
import Combine
import SwiftUI

class DataManager: ObservableObject {
    @Published var parkingLots: [ParkingLotProfile] = []
    static let shared = DataManager()

    private let userDefaults = UserDefaults.standard

    // UserDefaults 키들
    private enum Keys {
        static let parkingLots = "parkingLots"
        static let activeParkingSession = "activeParkingSession"
        static let userProfile = "userProfile"
        static let vehicleProfile = "vehicleProfile"
    }

    private init() {
        parkingLots = loadParkingLots()
    }

    // MARK: - 주차장 관리

    func saveParkingLots(_ lots: [ParkingLotProfile]) {
        do {
            let data = try JSONEncoder().encode(lots)
            userDefaults.set(data, forKey: Keys.parkingLots)
            DispatchQueue.main.async {
                self.parkingLots = lots
            }
        } catch {
            print("주차장 목록 저장 실패: \(error)")
        }
    }

    func loadParkingLots() -> [ParkingLotProfile] {
        guard let data = userDefaults.data(forKey: Keys.parkingLots) else {
            return []
        }

        do {
            return try JSONDecoder().decode([ParkingLotProfile].self, from: data)
        } catch {
            print("주차장 목록 로드 실패: \(error)")
            return []
        }
    }

    func addParkingLot(_ parkingLot: ParkingLotProfile) {
        var lots = parkingLots
        lots.append(parkingLot)
        saveParkingLots(lots)
    }

    func updateParkingLot(_ updatedParkingLot: ParkingLotProfile) {
        var lots = parkingLots
        if let index = lots.firstIndex(where: { $0.id == updatedParkingLot.id }) {
            lots[index] = updatedParkingLot
            saveParkingLots(lots)
        }
    }

    func deleteParkingLot(withId id: UUID) {
        var lots = parkingLots
        lots.removeAll { $0.id == id }
        saveParkingLots(lots)
    }

    func deleteParkingLots(at indexSet: IndexSet) {
        var lots = parkingLots
        lots.remove(atOffsets: indexSet)
        saveParkingLots(lots)
    }

    // MARK: - 주차 세션 관리

    func saveActiveParkingSession(_ session: ParkingSession?) {
        if let session = session {
            do {
                let data = try JSONEncoder().encode(session)
                userDefaults.set(data, forKey: Keys.activeParkingSession)
            } catch {
                print("활성 주차 세션 저장 실패: \(error)")
            }
        } else {
            userDefaults.removeObject(forKey: Keys.activeParkingSession)
        }
    }

    func loadActiveParkingSession() -> ParkingSession? {
        guard let data = userDefaults.data(forKey: Keys.activeParkingSession) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(ParkingSession.self, from: data)
        } catch {
            print("활성 주차 세션 로드 실패: \(error)")
            return nil
        }
    }

    func clearActiveParkingSession() {
        saveActiveParkingSession(nil)
    }

    // MARK: - 사용자 프로필 관리

    func saveDriverProfile(_ profile: DriverProfile) {
        do {
            let data = try JSONEncoder().encode(profile)
            userDefaults.set(data, forKey: Keys.userProfile)
        } catch {
            print("사용자 프로필 저장 실패: \(error)")
        }
    }

    func loadDriverProfile() -> DriverProfile {
        guard let data = userDefaults.data(forKey: Keys.userProfile) else {
            return DriverProfile() // 기본 프로필 반환
        }

        do {
            return try JSONDecoder().decode(DriverProfile.self, from: data)
        } catch {
            print("사용자 프로필 로드 실패: \(error)")
            return DriverProfile() // 기본 프로필 반환
        }
    }

    func saveVehicleProfile(_ profile: VehicleProfile) {
        do {
            let data = try JSONEncoder().encode(profile)
            userDefaults.set(data, forKey: Keys.vehicleProfile)
        } catch {
            print("차량 프로필 저장 실패: \(error)")
        }
    }

    func loadVehicleProfile() -> VehicleProfile {
        guard let data = userDefaults.data(forKey: Keys.vehicleProfile) else {
            return VehicleProfile() // 기본 프로필 반환
        }

        do {
            return try JSONDecoder().decode(VehicleProfile.self, from: data)
        } catch {
            print("차량 프로필 로드 실패: \(error)")
            return VehicleProfile() // 기본 프로필 반환
        }
    }

    // MARK: - 편의 메서드들

    func hasActiveParkingSession() -> Bool {
        return loadActiveParkingSession() != nil
    }

    func startParkingSession(
        parkingLot: ParkingLotProfile,
        vehicle: VehicleProfile? = nil,
        driver: DriverProfile? = nil,
        additionalFreeMinutes: Int = 0
    ) -> ParkingSession {
        let vehicleProfile = vehicle ?? loadVehicleProfile()
        let driverProfile = driver ?? loadDriverProfile()

        let session = ParkingSession(
            startTime: Date(),
            parkingLot: parkingLot,
            vehicle: vehicleProfile,
            driver: driverProfile,
            additionalFreeMinutes: additionalFreeMinutes
        )

        saveActiveParkingSession(session)
        return session
    }

    func endParkingSession() {
        clearActiveParkingSession()
    }
}