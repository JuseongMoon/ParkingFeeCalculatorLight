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
        }
        .onDisappear {
            stopTimer()
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