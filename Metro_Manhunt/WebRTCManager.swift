import Foundation
import WebRTC
import Starscream
import CoreLocation
import MapKit

final class WebRTCManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    @Published var isHost: Bool = false
    @Published var roomKey: String?
    
    private var locationManager: CLLocationManager?
    private var socket: WebSocket?
    
    override init() {
        super.init()
        configureLocationManager()
    }
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.requestWhenInUseAuthorization()
        } else {
            print("Location services disabled")
        }
    }

    @Published var connectedPlayers: [String] = []
    
    func createRoom() {
        isHost = true
        roomKey = UUID().uuidString
        
        // Create a WebSocket connection to the signaling server
        let serverURL = "ws://localhost:8080" // Replace with your signaling server URL
        socket = WebSocket(request: URLRequest(url: URL(string: serverURL)!))
        socket?.delegate = self
        socket?.connect()
        
        // Send a message to create a new room
        let message = "{\"action\": \"createRoom\", \"roomKey\": \"\(roomKey!)\"}"
        socket?.write(string: message)
    }
    
    func joinRoom(roomKey: String, completion: @escaping (Bool) -> Void) {
        isHost = false
        self.roomKey = roomKey
        
        // Create a WebSocket connection to the signaling server
        let serverURL = "ws://localhost:8080" // Replace with your signaling server URL
        socket = WebSocket(request: URLRequest(url: URL(string: serverURL)!))
        socket?.delegate = self
        socket?.connect()
        
        // Send a message to join the specified room
        let message = "{\"action\": \"joinRoom\", \"roomKey\": \"\(roomKey)\"}"
        socket?.write(string: message)
        
        socket?.onEvent = { (result) in
            switch result {
            case .text(let text):
                if let data = text.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let type = json["type"] as? String,
                   let error = json["error"] as? String {
                    if type == "error" && error == "Room does not exist" {
                        completion(false)
                        return
                    }
                }
                
                // If the response does not match the error case, consider it a success
                completion(true)
                
            default:
                break
            }
        }
    }
    
    func closeRoom() {
        // Send a message to the signaling server to close the room
        let message = "{\"action\": \"closeRoom\", \"roomKey\": \"\(roomKey!)\"}"
        socket?.write(string: message)
        
        // Disconnect and clean up
        socket?.disconnect()
        socket = nil
        isHost = false
        roomKey = nil
    }
    
    func startGame() {
        //code
    }
    
    func leaveRoom(completion: @escaping () -> Void)  {
        //code
    }
}


extension WebRTCManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(_):
            if isHost {
                socket?.write(string: "{\"action\": \"createRoom\", \"roomKey\": \"\(roomKey!)\"}")
            } else {
                socket?.write(string: "{\"action\": \"joinRoom\", \"roomKey\": \"\(roomKey!)\"}")
            }
        case .disconnected(let reason, let code):
            print("WebSocket disconnected: \(reason) with code: \(code)")
        case .text(let string):
            handleSignalingMessage(string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            break
        case .error(let error):
            print("WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    private func handleSignalingMessage(_ message: String) {
        // Parse the signaling message and handle it based on your signaling server protocol
        // Update the player count, handle player join/leave notifications, etc.
        // This is just a stub for demonstration purposes.
        
        guard let data = message.data(using: .utf8) else {
            print("Failed to parse signaling message")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            if let action = json?["action"] as? String {
                switch action {
                //case "playerJoin":
                  //  playerCount += 1
                //case "playerLeave":
                  //  playerCount -= 1
                default:
                    break
                }
            }
        } catch {
            print("Error parsing signaling message: \(error.localizedDescription)")
        }
    }
}
