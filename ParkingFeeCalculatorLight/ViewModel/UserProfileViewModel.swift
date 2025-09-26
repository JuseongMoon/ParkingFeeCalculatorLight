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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let dataManager = DataManager.shared

    // DataManager의 @Published 프로퍼티에 직접 접근
    var driverProfile: DriverProfile {
        get { dataManager.driverProfile }
        set { dataManager.driverProfile = newValue }
    }

    var vehicleProfile: VehicleProfile {
        get { dataManager.vehicleProfile }
        set { dataManager.vehicleProfile = newValue }
    }

    init() {
        setupDataManagerObservers()
    }

    // MARK: - DataManager Observer Setup
    private func setupDataManagerObservers() {
        // DataManager의 프로퍼티 변경을 관찰하여 UI 업데이트 트리거
        dataManager.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Profile Management
    func loadProfiles() {
        // DataManager에서 이미 초기화되므로 별도 로드 불필요
        isLoading = false
    }

    func saveProfiles() async {
        isLoading = true
        errorMessage = nil

        do {
            // 실제 저장 과정을 시뮬레이션하기 위한 지연
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 지연

            await MainActor.run {
                self.dataManager.saveDriverProfile(self.dataManager.driverProfile)
                self.dataManager.saveVehicleProfile(self.dataManager.vehicleProfile)
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
        dataManager.saveDriverProfile(profile)
    }

    func updateVehicleProfile(_ profile: VehicleProfile) {
        dataManager.saveVehicleProfile(profile)
    }

    // MARK: - Validation
    var isDriverProfileComplete: Bool {
        return dataManager.driverProfile.isProfileComplete
    }

    var isVehicleProfileComplete: Bool {
        return dataManager.vehicleProfile.isProfileComplete
    }

    var areProfilesComplete: Bool {
        return isDriverProfileComplete && isVehicleProfileComplete
    }

    // MARK: - Profile Actions
    func resetDriverProfile() {
        dataManager.saveDriverProfile(DriverProfile())
    }

    func resetVehicleProfile() {
        dataManager.saveVehicleProfile(VehicleProfile())
    }

    func resetAllProfiles() {
        resetDriverProfile()
        resetVehicleProfile()
    }

    // MARK: - Fee Calculation Helper
    func getCurrentDriverProfile() -> DriverProfile {
        return dataManager.driverProfile
    }

    func getCurrentVehicleProfile() -> VehicleProfile {
        return dataManager.vehicleProfile
    }
}