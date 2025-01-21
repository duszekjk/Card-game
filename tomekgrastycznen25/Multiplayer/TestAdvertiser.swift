////
////  TestAdvertiser.swift
////  tomekgrastycznen25
////
////  Created by Jacek Kałużny on 21/01/2025.
////
//
//import os
//import MultipeerConnectivity
//
//class TestAdvertiser: NSObject, MCNearbyServiceAdvertiserDelegate {
//    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        print("invitation")
//    }
//    
//    private let advertiser: MCNearbyServiceAdvertiser
//    private let peerID: MCPeerID
//
//    override init() {
//        peerID = MCPeerID(displayName: "Test Device")
//        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "tomekgra")
//        super.init()
//        advertiser.delegate = self
//        os_log("Attempting to start advertising with service type: %{public}@", log: OSLog.default, type: .info, "tomekgra")
//        advertiser.startAdvertisingPeer()
//        os_log("Advertising started", log: OSLog.default, type: .info)
//    }
//    func startAdvertising() {
//        os_log("Attempting to start advertising with service type: %{public}@", log: OSLog.default, type: .info, "tomekgra")
//        advertiser.startAdvertisingPeer()
//        os_log("Advertising started", log: OSLog.default, type: .info)
//    }
//    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
//        print("Failed to start advertising: \(error.localizedDescription)")
//    }
//}
