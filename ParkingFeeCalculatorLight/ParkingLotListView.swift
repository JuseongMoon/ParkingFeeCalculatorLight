//
//  ParkingLotListView.swift
//  ParkingFeeCalculatorLight
//
//  주차장 목록 화면
//

import SwiftUI

struct ParkingLotListView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var isPresentingForm: Bool = false
    @State private var isParkingActive: Bool = false
    @State private var activeParkingSession: ParkingSession?

    var body: some View {
        NavigationStack {
            Group {
                if dataManager.parkingLots.isEmpty {
                    List {
                        // 타이머 셀 (항상 표시)
                        Section {
                            TimerCellView(
                                isParkingActive: $isParkingActive,
                                activeParkingSession: $activeParkingSession
                            )
                            .padding(.top, 20)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }

                        // 빈 상태 메시지
                        Section {
                            ContentUnavailableView(
                                "주차장이 없습니다",
                                systemImage: "building.2.badge.exclamationmark",
                                description: Text("오른쪽 위 + 버튼으로 주차장을 추가하세요")
                            )
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.insetGrouped)
                } else {
                    List {
                        // 타이머 셀 (항상 표시)
                        Section {
                            TimerCellView(
                                isParkingActive: $isParkingActive,
                                activeParkingSession: $activeParkingSession
                            )
                            .padding(.top, 20)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }

                        // 주차장 리스트
                        Section {
                            ForEach(dataManager.parkingLots) { parkingLot in
                                NavigationLink(destination: ParkingLotInfoView(
                                    parkingLotProfile: parkingLot,
                                    isParkingActive: $isParkingActive,
                                    onUpdate: { updatedProfile in
                                        updateParkingLot(updatedProfile)
                                    },
                                    onParkingStart: { parkingLot in
                                        startParking(at: parkingLot)
                                    }
                                )) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "parkingsign.circle")
                                            .foregroundStyle(.tint)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(parkingLot.displayName)
                                                .font(.headline)
                                            Text("\(parkingLot.parkingFeeCalculator.additionalFee)원/\(parkingLot.parkingFeeCalculator.additionalMinutes)분")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .onDelete(perform: deleteParkingLots)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("주차장 목록")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("주차장 추가")
                }
            }
            .sheet(isPresented: $isPresentingForm) {
                ParkingLotEditView { newParkingLot in
                    addParkingLot(newParkingLot)
                }
            }
            .onChange(of: isParkingActive) { _, newValue in
                if !newValue {
                    endParking()
                }
            }
            .onAppear {
                loadData()
            }
        }
    }

    // MARK: - 데이터 관리 메서드들

    private func loadData() {
        activeParkingSession = dataManager.loadActiveParkingSession()
        isParkingActive = activeParkingSession != nil
    }

    private func addParkingLot(_ parkingLot: ParkingLotProfile) {
        dataManager.addParkingLot(parkingLot)
    }

    private func updateParkingLot(_ updatedProfile: ParkingLotProfile) {
        dataManager.updateParkingLot(updatedProfile)

        // 현재 주차 중인 주차장이 업데이트된 경우 세션도 업데이트
        if let session = activeParkingSession, session.parkingLot.id == updatedProfile.id {
            let updatedSession = ParkingSession(
                sessionId: session.sessionId,
                startTime: session.startTime,
                parkingLot: updatedProfile,
                vehicle: session.vehicle,
                driver: session.driver,
                additionalFreeMinutes: session.additionalFreeMinutes
            )
            dataManager.saveActiveParkingSession(updatedSession)
            activeParkingSession = updatedSession
        }
    }

    private func deleteParkingLots(at indexSet: IndexSet) {
        dataManager.deleteParkingLots(at: indexSet)
    }

    private func startParking(at parkingLot: ParkingLotProfile) {
        let session = dataManager.startParkingSession(parkingLot: parkingLot)
        activeParkingSession = session
        isParkingActive = true
    }

    private func endParking() {
        dataManager.endParkingSession()
        activeParkingSession = nil
    }
}

#Preview {
    ParkingLotListView()
}