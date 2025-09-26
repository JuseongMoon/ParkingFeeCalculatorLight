//
//  UserProfileView.swift
//  ParkingFeeCalculatorLight
//
//  사용자 프로필 관리 화면 - 기존 ParkingFeeCalculator 앱의 완전한 프로필 UI
//

import SwiftUI

struct UserProfileView: View {
    @StateObject private var userProfileVM = UserProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingVehicleForm = false
    @State private var showingDriverForm = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 프로필 헤더
                    profileHeader

                    // 운전자 정보 섹션
                    driverSection

                    // 차량 정보 섹션
                    vehicleSection
                }
                .padding()
            }
            .navigationTitle("프로필")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingDriverForm) {
                DriverFormView(driverProfile: $userProfileVM.driverProfile, onSave: { profile in
                    userProfileVM.updateDriverProfile(profile)
                })
            }
            .sheet(isPresented: $showingVehicleForm) {
                VehicleFormView(vehicleProfile: $userProfileVM.vehicleProfile, onSave: { profile in
                    userProfileVM.updateVehicleProfile(profile)
                })
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            VStack(spacing: 4) {
                Text(userProfileVM.driverProfile.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(userProfileVM.vehicleProfile.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 20) {
                ProfileCompletionIndicator(
                    title: "운전자",
                    isComplete: userProfileVM.isDriverProfileComplete,
                    completion: userProfileVM.isDriverProfileComplete ? 1.0 : 0.3
                )

                ProfileCompletionIndicator(
                    title: "차량",
                    isComplete: userProfileVM.isVehicleProfileComplete,
                    completion: userProfileVM.isVehicleProfileComplete ? 1.0 : 0.3
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Driver Section
    private var driverSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("운전자 정보")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button("편집") {
                    showingDriverForm = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }

            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.blue)
                        .frame(width: 20)

                    Text("특별 조건")
                        .foregroundColor(.secondary)

                    Spacer()

                    HStack(spacing: 8) {
                        if userProfileVM.driverProfile.isDisabled {
                            if let level = userProfileVM.driverProfile.disabilityLevel {
                                Text("\(level.displayName) 장애인")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            } else {
                                Text("장애인")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }

                        if userProfileVM.driverProfile.isNationalMerit {
                            Text("국가유공자")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(4)
                        }

                        if userProfileVM.driverProfile.isExemplaryTaxpayer {
                            Text("모범납세자")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .cornerRadius(4)
                        }

                        if userProfileVM.driverProfile.isMultiChild {
                            Text("다자녀")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }

                        if userProfileVM.driverProfile.isSenior {
                            Text("고령자")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.purple)
                                .cornerRadius(4)
                        }

                        if !userProfileVM.driverProfile.hasAnySpecialCondition {
                            Text("일반")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Vehicle Section
    private var vehicleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("차량 정보")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button("편집") {
                    showingVehicleForm = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }

            VStack(spacing: 8) {
                // 차량 크기 정보
                ProfileInfoRow(
                    icon: "car",
                    title: "차량 크기",
                    value: userProfileVM.vehicleProfile.vehicleSize.displayName
                )

                // 친환경 차량 정보
                if userProfileVM.vehicleProfile.isEcoFriendly {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                            .frame(width: 20)

                        Text("친환경 차량")
                            .foregroundColor(.green)
                            .fontWeight(.medium)

                        Spacer()
                        HStack(spacing: 8) {
                            if userProfileVM.vehicleProfile.isElectric {
                                Text("전기차")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }

                            if userProfileVM.vehicleProfile.isHydrogen {
                                Text("수소차")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.cyan.opacity(0.1))
                                    .foregroundColor(.cyan)
                                    .cornerRadius(4)
                            }

                            if userProfileVM.vehicleProfile.isHybrid {
                                Text("하이브리드")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.1))
                                    .foregroundColor(.orange)
                                    .cornerRadius(4)
                            }
                        }
                    }
                } else {
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)

                        Text("일반 차량")
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

}

// MARK: - Supporting Views
struct ProfileCompletionIndicator: View {
    let title: String
    let isComplete: Bool
    let completion: Double

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 40, height: 40)

                Circle()
                    .trim(from: 0, to: completion)
                    .stroke(
                        isComplete ? Color.green : Color.orange,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))

                Image(systemName: isComplete ? "checkmark" : "exclamationmark")
                    .font(.caption)
                    .foregroundColor(isComplete ? .green : .orange)
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)

            Text(title)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Driver Form View
struct DriverFormView: View {
    @Binding var driverProfile: DriverProfile
    @Environment(\.dismiss) private var dismiss
    @State private var tempProfile: DriverProfile
    let onSave: (DriverProfile) -> Void

    init(driverProfile: Binding<DriverProfile>, onSave: @escaping (DriverProfile) -> Void) {
        self._driverProfile = driverProfile
        self._tempProfile = State(initialValue: driverProfile.wrappedValue)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section("특별 조건") {
                    Toggle("장애인", isOn: $tempProfile.isDisabled)

                    if tempProfile.isDisabled {
                        Picker("장애 정도", selection: $tempProfile.disabilityLevel) {
                            Text("선택하세요").tag(nil as DisabilityLevel?)
                            ForEach(DisabilityLevel.allCases, id: \.self) { level in
                                Text(level.displayName).tag(level as DisabilityLevel?)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }

                    Toggle("국가유공자", isOn: $tempProfile.isNationalMerit)
                    Toggle("모범납세자", isOn: $tempProfile.isExemplaryTaxpayer)
                    Toggle("다자녀(다둥이)", isOn: $tempProfile.isMultiChild)
                    Toggle("65세 이상 고령자", isOn: $tempProfile.isSenior)
                }
            }
            .navigationTitle("운전자 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        driverProfile = tempProfile
                        onSave(tempProfile)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Vehicle Form View
struct VehicleFormView: View {
    @Binding var vehicleProfile: VehicleProfile
    @Environment(\.dismiss) private var dismiss
    @State private var tempProfile: VehicleProfile
    let onSave: (VehicleProfile) -> Void

    init(vehicleProfile: Binding<VehicleProfile>, onSave: @escaping (VehicleProfile) -> Void) {
        self._vehicleProfile = vehicleProfile
        self._tempProfile = State(initialValue: vehicleProfile.wrappedValue)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section("차량 크기") {
                    Picker("차량 크기", selection: $tempProfile.vehicleSize) {
                        ForEach(VehicleSize.allCases, id: \.self) { size in
                            Text(size.displayName).tag(size)
                        }
                    }
                }

                Section("친환경 여부") {
                    Toggle("전기차", isOn: $tempProfile.isElectric)
                    Toggle("수소차", isOn: $tempProfile.isHydrogen)
                    Toggle("하이브리드", isOn: $tempProfile.isHybrid)
                }
            }
            .navigationTitle("차량 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        vehicleProfile = tempProfile
                        onSave(tempProfile)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    UserProfileView()
}