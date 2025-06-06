//
//  DoroStateEntity.swift
//  Dorocat
//
//  Created by Greem on 10/28/24.
//

import Foundation

struct DoroStateEntity: Equatable {
    var catType: CatType = .doro
    var progressEntity = TimerProgressEntity()
    var settingEntity = TimerSettingEntity()
}
