//
//  ContentView.swift
//  ParkingFeeCalculatorLight
//
//  Created by 문주성 on 9/26/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"

    var colorScheme: ColorScheme? {
        switch appColorScheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        TabView {
            NavigationStack {
                ParkingLotListView()
            }
            .tabItem {
                Label("주차장", systemImage: "parkingsign.circle")
            }

            NavigationStack {
                SettingView()
            }
            .tabItem {
                Label("설정", systemImage: "gearshape")
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    ContentView()
}
