//
//  ContentView.swift
//  Metro_Manhunt
//
//  Created by Zac Whales on 2/5/2023.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = WebRTCManager()
    @State private var showLobby = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Metro Manhunt")
                    .font(.largeTitle)
                    .padding()

                if showLobby {
                    LobbyView(roomKey: viewModel.roomKey ?? "")
                        .transition(.slide)
                        .environmentObject(viewModel)
                } else {
                    WelcomeView()
                        .transition(.slide)
                        .environmentObject(viewModel)
                }

                Spacer()
            }
            .navigationBarHidden(true)
            .onReceive(viewModel.$roomKey, perform: { roomKey in
                if roomKey != nil {
                    showLobby = true
                } else {
                    showLobby = false
                }
            })
        }
        .environmentObject(viewModel)
    }
}

struct WelcomeView: View {
    @State private var roomCode: String = ""
    @State private var showingAlert = false
    @State private var showingWaitingLobby = false
    @State private var showingHostLobby = false

    @EnvironmentObject private var viewModel: WebRTCManager

    var body: some View {
        VStack {
            Text("Welcome to Metro Manhunt!")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)

            TextField("Enter Room Code", text: $roomCode)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            Button(action: {
                // Join the room when the button is clicked.
                viewModel.joinRoom(roomKey: roomCode) { success in
                    if success {
                        showingHostLobby = false
                        showingWaitingLobby = true
                    } else {
                        showingHostLobby = false
                        showingWaitingLobby = false
                        showingAlert = true
                    }
                }
            }) {
                Text("Get Started")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Invalid Room Code"), message: Text("Please enter a valid room code."), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showingWaitingLobby) {
                WaitingLobbyView()
            }

            Button(action: {
                // Create a room when the button is clicked.
                viewModel.createRoom()
                showingWaitingLobby = false
                showingHostLobby = true
            }) {
                Text("Create Room")
                    .font(.title)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
            .sheet(isPresented: $showingHostLobby) {
                LobbyView(roomKey: viewModel.roomKey ?? "")
            }
        }
        .padding()
    }
}



struct LobbyView: View {
    let roomKey: String

    @EnvironmentObject private var viewModel: WebRTCManager

    var body: some View {
        VStack {
            Text("Room Key: \(roomKey)")
                .font(.title)
                .padding()

            Button(action: {
                // Start the game
                viewModel.startGame()
            }) {
                Text("Start Game")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)

            Button(action: {
                // Leave the room
                viewModel.closeRoom()
            }) {
                Text("Close Lobby")
                    .font(.title)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
    }
}

struct WaitingLobbyView: View {
    var body: some View {
        Text("Waiting for the host to start the game...")
            .font(.title)
            .padding()
            .multilineTextAlignment(.center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
