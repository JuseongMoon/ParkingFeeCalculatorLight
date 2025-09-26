//
//  TimerCellView.swift
//  ParkingFeeCalculatorLight
//
//  주차 타이머 UI (위젯 기능 제거됨)
//

import SwiftUI

struct TimerCellView: View {
    @Binding var isParkingActive: Bool
    @Binding var activeParkingSession: ParkingSession?
    @State private var currentTime = Date()
    @State private var displayTimer: Timer?
    @State private var showingStopConfirmation = false
    @State private var additionalFreeMinutes: Int = 0

    var body: some View {
        VStack(spacing: 16) {
            if let session = activeParkingSession {
                // 주차 중일 때 - 실시간 정보 표시
                VStack(spacing: 16) {
                    // 주차장 정보 헤더
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.parkingLot.name)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text(session.parkingLot.address)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // 주차 상태 표시
                        HStack(spacing: 8) {
                            Circle()
                                .fill(isParkingActive ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)

                            Text(isParkingActive ? "주차중" : "대기중")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("시작 시간")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatKoreanDateTime(session.startTime))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("경과 시간")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(elapsedTimeString(from: session.startTime))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                        }

                        Divider()

                        // 실시간 주차비 표시
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("현재 주차비")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                let feeResult = session.calculateCurrentFee()
                                Text("\(feeResult.finalFee)원")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            // 주차비 계산 상세 정보
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("기본요금: \(session.parkingLot.parkingFeeCalculator.initialFee)원")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("추가요금: \(session.parkingLot.parkingFeeCalculator.additionalFee)원/\(session.parkingLot.parkingFeeCalculator.additionalMinutes)분")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                // 할인 정보 표시
                                let discountResult = session.calculateCurrentFee()
                                if let appliedDiscount = discountResult.appliedDiscount {
                                    Text("할인: \(appliedDiscount.name) (-\(Int(appliedDiscount.percentage))%)")
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                }
                            }
                        }

                        Divider()

                        // 추가 무료시간 Stepper
                        VStack(spacing: 8) {
                            HStack {
                                Text("추가 무료시간")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .fontWeight(.medium)

                                Spacer()

                                Text(formatAdditionalFreeTime(additionalFreeMinutes))
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)

                                Stepper(
                                    value: $additionalFreeMinutes,
                                    in: 0...300,
                                    step: 30
                                ) {
                                    EmptyView()
                                }
                                .onChange(of: additionalFreeMinutes) { _, newValue in
                                    updateSessionWithAdditionalFreeMinutes(newValue)
                                }
                            }
                        }

                        Divider()
                    }
                    .padding(.horizontal, 16)

                    // 시간별 예상 요금 표시
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("예상 주차 요금")
                                .font(.headline)
                                .fontWeight(.semibold)

                            Spacer()

                            Text("현재 시간 기준")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach([1, 2, 3, 4, 6, 8, 10, 12], id: \.self) { hours in
                                VStack(spacing: 6) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                            .font(.caption2)
                                            .foregroundColor(.blue)

                                        Text("+\(hours)시간")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }

                                    Text(formatCurrency(calculateFutureFee(hours: hours)))
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.6)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray5), lineWidth: 0.5)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // 주차 종료 버튼
                    HStack(spacing: 12) {
                        Button(action: { showingStopConfirmation = true }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("주차 종료")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .allowsHitTesting(true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            } else {
                // 주차장이 선택되지 않은 경우 - 안내 메시지 표시
                VStack(spacing: 20) {
                    Image(systemName: "building.2")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)

                    VStack(spacing: 8) {
                        Text("주차장을 선택해주세요")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("주차장 목록에서 주차장을 선택하거나\n새로운 주차장을 추가해주세요")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical, 40)
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .onAppear {
            startTimer()
            // 초기 additionalFreeMinutes 설정
            if let session = activeParkingSession {
                additionalFreeMinutes = session.additionalFreeMinutes
            }
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: activeParkingSession) { _, newSession in
            // 세션이 변경되면 additionalFreeMinutes도 동기화
            if let session = newSession {
                additionalFreeMinutes = session.additionalFreeMinutes
            } else {
                additionalFreeMinutes = 0
            }
        }
        .alert("주차 종료", isPresented: $showingStopConfirmation) {
            Button("취소", role: .cancel) { }
            Button("주차 종료", role: .destructive) {
                stopParking()
            }
        } message: {
            if let session = activeParkingSession {
                let currentFee = session.calculateCurrentFee().finalFee
                Text("정말로 주차를 종료하시겠습니까?\n현재 주차비는 \(currentFee)원입니다.")
            }
        }
    }

    // MARK: - Helper Methods

    private func elapsedTimeString(from startTime: Date) -> String {
        let elapsed = currentTime.timeIntervalSince(startTime)
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        let seconds = Int(elapsed) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func formatKoreanDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일 a h:mm"
        return formatter.string(from: date)
    }

    private func formatAdditionalFreeTime(_ minutes: Int) -> String {
        if minutes == 0 {
            return "0분"
        }

        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours == 0 {
            return "\(remainingMinutes)분"
        } else if remainingMinutes == 0 {
            return "\(hours)시간"
        } else {
            return "\(hours)시간 \(remainingMinutes)분"
        }
    }

    private func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3

        if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
            return "\(formattedAmount)원"
        }
        return "\(amount)원"
    }

    // MARK: - Actions

    private func stopParking() {
        isParkingActive = false
        activeParkingSession = nil
        stopTimer()
    }

    private func startTimer() {
        // 경과 시간 표시용 타이머 (1초마다)
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime = Date()
        }
    }

    private func stopTimer() {
        displayTimer?.invalidate()
        displayTimer = nil
    }

    // MARK: - 추가 무료시간 업데이트
    private func updateSessionWithAdditionalFreeMinutes(_ newValue: Int) {
        guard let currentSession = activeParkingSession else { return }

        // 새로운 ParkingSession 생성 (additionalFreeMinutes 업데이트)
        let updatedSession = ParkingSession(
            sessionId: currentSession.sessionId,
            startTime: currentSession.startTime,
            parkingLot: currentSession.parkingLot,
            vehicle: currentSession.vehicle,
            driver: currentSession.driver,
            additionalFreeMinutes: newValue
        )

        // 세션 업데이트
        activeParkingSession = updatedSession

        // DataManager에도 업데이트 반영
        DataManager.shared.saveActiveParkingSession(updatedSession)
    }

    // MARK: - 미래 시간 요금 계산
    private func calculateFutureFee(hours: Int) -> Int {
        guard let session = activeParkingSession else { return 0 }

        // 주차 시작부터 N시간 경과 시점 (N시간 - 1초, 즉 N시간 59분 59초)
        let targetElapsedTime = TimeInterval(hours * 3600 - 1)

        // 업데이트된 세션으로 미래 시점 요금 계산 (현재 UI 상태의 추가 무료시간 반영)
        let updatedSession = ParkingSession(
            sessionId: session.sessionId,
            startTime: session.startTime,
            parkingLot: session.parkingLot,
            vehicle: session.vehicle,
            driver: session.driver,
            additionalFreeMinutes: additionalFreeMinutes
        )

        // 절대 시간 기준 요금 계산 (주차 시작부터 N시간 경과 시점)
        let feeResult = session.parkingLot.parkingFeeCalculator.calculateFee(
            duration: targetElapsedTime,
            vehicleProfile: updatedSession.vehicle,
            driverProfile: updatedSession.driver,
            specialConditionDiscounts: session.parkingLot.specialConditionDiscounts,
            additionalFreeMinutes: updatedSession.additionalFreeMinutes
        )

        return feeResult.finalFee
    }
}

#Preview {
    TimerCellView(
        isParkingActive: .constant(true),
        activeParkingSession: .constant(
            ParkingSession(
                startTime: Date().addingTimeInterval(-3600), // 1시간 전
                parkingLot: ParkingLotProfile(name: "테스트 주차장", address: "서울시 강남구"),
                vehicle: VehicleProfile(),
                driver: DriverProfile()
            )
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}