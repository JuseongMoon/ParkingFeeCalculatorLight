//
//  UserProfileViewModel.swift
//  ParkingFeeCalculatorLight
//
//  사용자 프로필 뷰모델 - DataManager와 연동하여 로컬 저장
//

import Foundation
import Combine

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var driverProfile: DriverProfile = DriverProfile()
    @Published var vehicleProfile: VehicleProfile = VehicleProfile()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let dataManager = DataManager.shared

    init() {
        loadProfiles()
    }

    // MARK: - Profile Management
    func loadProfiles() {
        isLoading = true

        driverProfile = dataManager.loadDriverProfile()
        vehicleProfile = dataManager.loadVehicleProfile()

        isLoading = false
    }

    func saveProfiles() async {
        isLoading = true
        errorMessage = nil

        do {
            // 실제 저장 과정을 시뮬레이션하기 위한 지연
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 지연

            await MainActor.run {
                self.dataManager.saveDriverProfile(self.driverProfile)
                self.dataManager.saveVehicleProfile(self.vehicleProfile)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "저장 중 오류가 발생했습니다: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    func updateDriverProfile(_ profile: DriverProfile) {
        driverProfile = profile
        dataManager.saveDriverProfile(profile)
    }

    func updateVehicleProfile(_ profile: VehicleProfile) {
        vehicleProfile = profile
        dataManager.saveVehicleProfile(profile)
    }

    // MARK: - Validation
    var isDriverProfileComplete: Bool {
        return driverProfile.isProfileComplete
    }

    var isVehicleProfileComplete: Bool {
        return vehicleProfile.isProfileComplete
    }

    var areProfilesComplete: Bool {
        return isDriverProfileComplete && isVehicleProfileComplete
    }

    // MARK: - Profile Actions
    func resetDriverProfile() {
        driverProfile = DriverProfile()
        dataManager.saveDriverProfile(driverProfile)
    }

    func resetVehicleProfile() {
        vehicleProfile = VehicleProfile()
        dataManager.saveVehicleProfile(vehicleProfile)
    }

    func resetAllProfiles() {
        resetDriverProfile()
        resetVehicleProfile()
    }

    // MARK: - Fee Calculation Helper
    func getCurrentDriverProfile() -> DriverProfile {
        return driverProfile
    }

    func getCurrentVehicleProfile() -> VehicleProfile {
        return vehicleProfile
    }
}