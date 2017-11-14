//
//  MultipeerCommunicator.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 21/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol Communicator: class {
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
    weak var delegate: CommunicatorDelegate? {get set}
    var online: Bool {get set}
}

protocol CommunicatorDelegate: class {
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
}

class MultipeerCommunicator: NSObject, Communicator {
    
    private let serviceType = "tinkoff-chat"
    private let userNameKey = "userName"
    private var displayName : String
    private var userName : String
    private var peersSessions : [String : MCSession] = [:]
    private var peersDiscoveryInfos : [String : [String : String]] = [:]
    
    init(userId: String, name: String?) {
        displayName = userId
        userName = name ?? "Unknown"
    }
    
    deinit {
        self._advertiser?.stopAdvertisingPeer()
        self._browser?.stopBrowsingForPeers()
        self.peersSessions.forEach { (key : String , value: MCSession) in
            value.disconnect()
        }
    }
    
    private var discoveryInfo: [String : String]? {
        get {
            return [userNameKey : userName]
        }
    }
    
    private var _peerID: MCPeerID?
    private var peerID: MCPeerID? {
        get {
            if _peerID == nil {
                _peerID = MCPeerID(displayName: displayName)
            }
            
            return _peerID
        }
    }
    
    private var _advertiser: MCNearbyServiceAdvertiser?
    private var advertiser: MCNearbyServiceAdvertiser? {
        get {
            if _advertiser == nil {
                guard let currentPeer = peerID else {
                    print("Empty PeerID!")
                    return nil
                }
                
                _advertiser = MCNearbyServiceAdvertiser(peer: currentPeer, discoveryInfo: discoveryInfo, serviceType: serviceType)
                _advertiser?.delegate = self
            }
            
            return _advertiser
        }
    }
    
    private var _online: Bool = false
    public var online: Bool {
        get {
            return _online
        }
        set {
            _online = newValue
            if _online == true {
                self.advertiser?.startAdvertisingPeer()
                self.browser?.startBrowsingForPeers()
            }
            else {
                self.advertiser?.stopAdvertisingPeer()
                self.browser?.stopBrowsingForPeers()
            }
        }
    }
    
    private var _browser: MCNearbyServiceBrowser?
    private var browser: MCNearbyServiceBrowser? {
        get {
            if _browser == nil {
                guard let currentPeer = peerID else {
                    print("Empty PeerID!")
                    return nil
                }
                
                _browser = MCNearbyServiceBrowser(peer: currentPeer, serviceType: serviceType)
                _browser?.delegate = self
            }
            
            return _browser
        }
    }
    
    //MARK: - Communicator
    public weak var delegate: CommunicatorDelegate?
    
    func sendMessage(string: String, to userID: String, completionHandler : ((_ success:Bool,_ error : Error?) -> Swift.Void)?) {
        guard let session = self.peersSessions[userID] else {
            print("No session for userId: \(userID)")
            completionHandler?(false, nil)
            return
        }
        
        for peer in session.connectedPeers {
            if peer.displayName == userID {
                guard let data = string.data(using: .utf8) else {
                    print("Could not create data from message string: \(string)")
                    assert(false)
                    return
                }
                
                do {
                    try session.send(data, toPeers: [peer], with: MCSessionSendDataMode.reliable)
                    completionHandler?(true, nil)
                } catch {
                    print("Error sending test data: \(error)")
                    completionHandler?(false, error)
                }
            }
        }
    }
    
    //MARK: - Helpers
    private func setDiscoveryInfo(discoveryInfo : [String : String]?, peer: MCPeerID) {
        self.peersDiscoveryInfos[peer.displayName] = discoveryInfo
    }
    
    private func setSession(session : MCSession?, peer: MCPeerID){
        self.peersSessions[peer.displayName] = session
    }
    
    private func prepareSession(peer: MCPeerID) -> MCSession?{
        var session = self.peersSessions[peer.displayName]
        
        if session == nil {
            guard let myPeer = self.peerID else {
                print("My peerID is empty!")
                return nil
            }
            session = MCSession(peer: myPeer, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
            session?.delegate = self
            self.setSession(session: session, peer: peer)
        }
        
        return session
    }
}

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Swift.Void) {
        if let session = self.prepareSession(peer: peerID) {
            let accept = !session.connectedPeers.contains(peerID)
            invitationHandler(accept, session)
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        self.delegate?.failedToStartAdvertising(error: error)
    }
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.setDiscoveryInfo(discoveryInfo: info, peer: peerID)
        if let session = self.prepareSession(peer: peerID) {
            if session.connectedPeers.contains(peerID) == false {
                browser.invitePeer(peerID, to:session, withContext: nil, timeout: 30)
            } else {
                let userId = peerID.displayName
                let userDiscoveryInfo = peersDiscoveryInfos[userId]
                delegate?.didFoundUser(userID: userId, userName: userDiscoveryInfo?[userNameKey])
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        let userId = peerID.displayName
        print("Did lost user \(userId)")
        self.delegate?.didLostUser(userID: userId)
        self.setSession(session: nil, peer: peerID)
        self.setDiscoveryInfo(discoveryInfo: nil, peer: peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        self.delegate?.failedToStartBrowsingForUsers(error: error)
    }
}

extension MultipeerCommunicator: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let userId = peerID.displayName
        
        switch state {
        case .connected:
            let userDiscoveryInfo = peersDiscoveryInfos[userId]
            
            print("Did found user \(userId)")
            self.delegate?.didFoundUser(userID: userId , userName: userDiscoveryInfo?[userNameKey])
            break
        case .connecting:
            break
        default:
            print("Did lost user \(userId)")
            self.delegate?.didLostUser(userID: userId)
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Did receive data from user \(peerID):\n \(data)")
        guard let message = String(data: data, encoding: .utf8) else {
            print("Error converting string from data!")
            assert(false)
            return
        }
        
        self.delegate?.didReceiveMessage(text: message, fromUser: peerID.displayName, toUser: session.myPeerID.displayName)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
}
