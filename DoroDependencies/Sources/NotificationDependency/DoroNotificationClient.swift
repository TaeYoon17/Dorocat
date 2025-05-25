//
//  File.swift
//
//
//  Created by Greem on 9/22/24.
//

import Foundation
import UserNotifications


class MockUserNotificationCenter: UNUserNotificationCenter {
    
    var requestAuthorizationCalled = false
    var grantedAuthorization = false
    
    override func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        requestAuthorizationCalled = true
        completionHandler(grantedAuthorization, nil)
    }
    
    var addRequestCalled = false
    
    override func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)? = nil) {
        addRequestCalled = true
        completionHandler?(nil)
    }
}


public actor DoroNotificationClient: NSObject, DoroNotification {
    
    public let center = UNUserNotificationCenter.current()
    
    public var notiTable:[NotificationType : String] = [:]
    //    let storage = DoroStorage.get("notification")
    public var isEnable:Bool{
        get{ UserDefaults.standard.bool(forKey: "Enableds") }
        //        get{storage.get(Bool.Type)}
        //        set{storeage.setValue(newValue,Bool.Type)}
        set{ UserDefaults.standard.setValue(newValue, forKey: "Enableds") }
    }
    public var isDenied: Bool{
        get async{
            let settings = await center.notificationSettings()
            switch settings.authorizationStatus{
            case .denied:return true
            default: return false
            }
        }
    }
    
    public var isDetermined: Bool{
        get async{
            let settings = await center.notificationSettings()
            switch settings.authorizationStatus{
            case .notDetermined:return false
            default: return true
            }
        }
    }
    
    public override init() {
        super.init()
        center.delegate = self
        
    }
    
    public func requestPermission() async throws -> Bool{
        let granted = try await center.requestAuthorization(options:[.alert,.badge,.sound])
        if granted{
            self.isEnable = true
        }
        return granted
    }
    public func setEnable(_ enable: Bool) async {
        self.isEnable = enable
        if !enable{
            do{
                try await removeAllNotifications()
            }catch{
                print(error)
            }
        }
    }
    public func sendNotification(message:PNType,restSeconds:Int) async throws {
        if restSeconds < 0 || !isEnable {
            print("권한 허가 취소됨!!")
            return
        } // 일단 죽인다...
        print(#function,message,restSeconds)
        let content = message.notiContent
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(restSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: message.id, content: content, trigger: trigger)
        try await center.add(request)
    }
    public func removeAllNotifications() async throws{
        center.removeAllPendingNotificationRequests()
    }
    
}
extension DoroNotificationClient:UNUserNotificationCenterDelegate{
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions { .init(arrayLiteral: [.banner,.list,.sound])
    }
}
