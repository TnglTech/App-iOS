//
//  DeviceBrowserView.swift
//  MoonLamp
//

import Foundation

import SwiftUI

struct DeviceBroswerView: View {
    @ObservedObject var deviceManager = DeviceManager()

    var body: some View {
        if deviceManager.isScanning {
            BLEScannerView()
        } else {
            NavigationView {
                List {
                    ForEach(Array(deviceManager.foundDevices.keys), id: \.self) { type in
                        Section(header: Text(type)) {
                            ForEach(deviceManager.foundDevices[type] ?? [], id: \.peripheralName) { device in
                                if (device is MoonLamp) {
                                    MoonLampBrowserRow(device as! MoonLamp)
                                } else {
//                                    NavigationLink(destination: LampiView(lamp: device as! Lampi)) {
//                                        LampiRow(device: device as! Lampi)
//                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Nearby Devices")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            deviceManager.scanForDevices()
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
                .onAppear(perform: deviceManager.refresh)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    deviceManager.refresh()
                }
            }
        }
    }
}

/*struct DeviceBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceBroswerView()

        LampiRow(device: Lampi(name: "Test Lampi"))
            .previewLayout(.sizeThatFits)
        
        DoorbellRow(device: Doorbell(name: "Test Doorbell"))
            .previewLayout(.sizeThatFits)
    }
}*/

private struct BLEScannerView: View {
    @State private var showOuterWave = false
    @State private var showMiddleWave = false
    @State private var showInnerWave = false

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Circle() // Outer Wave
                    .stroke()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
                    .scaleEffect(showOuterWave ? 3 : 1)
                    .opacity(showOuterWave ? 0.0 : 1)
                    .animation(Animation.easeInOut(duration: 1)
                                .delay(1)
                                .repeatForever(autoreverses: false)
                                .delay(2))
                    .onAppear() {
                        showOuterWave.toggle()
                    }

                Circle() // Middle Wave
                    .stroke()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
                    .scaleEffect(showMiddleWave ? 2.75 : 1)
                    .opacity(showMiddleWave ? 0.0 : 1)
                    .animation(Animation.easeInOut(duration: 1)
                                .delay(1)
                                .repeatForever(autoreverses: false)
                                .delay(2.2))
                    .onAppear() {
                        showMiddleWave.toggle()
                    }

                Circle() // Inner Wave
                    .stroke()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
                    .scaleEffect(showInnerWave ? 2.5 : 1)
                    .opacity(showInnerWave ? 0.0 : 1)
                    .animation(Animation.easeInOut(duration: 1)
                                .delay(1)
                                .repeatForever(autoreverses: false)
                                .delay(2.4))
                    .onAppear() {
                        showInnerWave.toggle()
                    }

                Circle()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
                    .overlay(
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .foregroundColor(.white)
                    )
            }
            Spacer()
            Text("Scanning for Devices")
                .foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: .infinity)
                                .fill(Color(white: 0.25, opacity: 0.5)))
                .padding()
        }
    }
}
