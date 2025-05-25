//
//  File.swift
//  
//
//  Created by Greem on 9/22/24.
//

import Foundation
import UserNotifications

public protocol DoroNotification {
    var center: UNUserNotificationCenter { get async }
    var notiTable: [NotificationType:String] { get async }
    
    var isEnable:Bool { get async }
    var isDenied: Bool { get async }
    var isDetermined:Bool { get async }
    func requestPermission() async throws -> Bool
    
    func setEnable(_ enable:Bool) async
    func sendNotification(message:PNType,restSeconds:Int) async throws
    func removeAllNotifications() async throws
}
