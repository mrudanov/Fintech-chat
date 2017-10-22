//
//  MultipeerCommunicator.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 21/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol Communicator {
    func sendMessage(string: String, to userID: String, completiionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
    weak var delegate: CommunicatorDelegate? {get set}
    var online: Bool {get set}
}

class MultipeerCommunicator: NSObject, Communicator {
    
    struct Message: Codable {
        let eventType: String
        let messageId: String
        let text: String
    }
    
    var delegate: CommunicatorDelegate?
    var online: Bool = false {
        didSet{
            if online {
                print("Did become online")
                browser.startBrowsingForPeers()
                advertiser.startAdvertisingPeer()
            } else {
                browser.stopBrowsingForPeers()
                advertiser.stopAdvertisingPeer()
            }
        }
    }
    let peer: MCPeerID
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    private var sessions: [MCPeerID: MCSession] = [:]
    private var foundPeers: [MCPeerID: String] = [:]
    
    init(visibleName: String?) {
        peer = MCPeerID(displayName: String(describing: UIDevice.current.identifierForVendor))
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: ["userName": visibleName ?? "Unknown"], serviceType: "tinkoff-chat")
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "tinkoff-chat")
        super.init()
        advertiser.delegate = self
        browser.delegate = self
    }
    
    deinit {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
    }
    
    func sendMessage(string: String, to userID: String, completiionHandler: ((Bool, Error?) -> ())?) {
        let messadeToSend = Message(eventType: "TextMessage", messageId: generateMessageID(), text: string)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(messadeToSend)
            
            for session in sessions {
                if session.key.displayName == userID {
                    try session.value.send(data, toPeers: [session.key], with: .unreliable)
                    completiionHandler?(true, nil)
                    return
                }
            }
        } catch {
            completiionHandler?(false, error)
        }
        completiionHandler?(false, nil)
    }
    
    private func generateMessageID() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
        return string!
    }
}

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Recieved invitation from peer: \(peerID.displayName)")
        let newSession = sessions[peerID] ?? MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .none)
        sessions[peerID] = newSession
        newSession.delegate = self
        invitationHandler(true, newSession)
    }
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer \(info?["userName"] ?? "NO USERNAME")")
        let newSession = sessions[peerID] ?? MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .none)
        sessions[peerID] = newSession
        newSession.delegate = self
        foundPeers[peerID] = info?["userName"]
        if newSession.connectedPeers.index(where: { $0 == peerID }) != nil {
            delegate?.didFoundUser(userID: peerID.displayName, userName: foundPeers[peerID])
        } else {
            browser.invitePeer(peerID, to: newSession, withContext: nil, timeout: 100)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
        sessions.removeValue(forKey: peerID)
        foundPeers.removeValue(forKey: peerID)
        delegate?.didLostUser(userID: peerID.displayName)
    }
}

extension MultipeerCommunicator: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case .connected:
            print("Connected with: \(peerID.displayName)")
            delegate?.didFoundUser(userID: peerID.displayName, userName: foundPeers[peerID])
        case .connecting:
            print("Connecting  with: \(peerID.displayName)")
        default:
            print("Did not connect to session with: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let decoder = JSONDecoder()
        let message = try? decoder.decode(Message.self, from: data)
        if let unwrapedMessage = message {
            delegate?.didRecieveMessage(text: unwrapedMessage.text, fromUser: peerID.displayName, toUser: peer.displayName)
        } else {
            print("Can`t decode recieved message")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
}