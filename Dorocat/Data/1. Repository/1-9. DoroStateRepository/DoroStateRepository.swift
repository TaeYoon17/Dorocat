//
//  DoroStateUserDefaultsClient.swift
//  Dorocat
//
//  Created by Greem on 11/9/24.
//

import Foundation


actor DoroStateRepository: DoroStateDependency {
    var cat: any CatDependency
    var timer: any TimerProtocol
    init(cat: any CatDependency, timer: any TimerProtocol) {
        self.cat = cat
        self.timer = timer
    }
}

extension DoroStateRepository {
    func setDoroStateEntity(_ entity: DoroStateEntity) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.cat.updateCatType(entity.catType)
            }
            group.addTask {
                await self.timer.setTimerSettingEntity(entity.settingEntity)
            }
            group.addTask {
                await self.timer.setTimerProgressEntity(entity.progressEntity)
            }
        }
    }
    
    
    /// Legacy 대응할 필요가 있다..!
    func getDoroStateEntity() async -> DoroStateEntity {
        async let timerSettingEntity = timer.getTimerSettingEntity()
        async let timerProgressEntity = timer.getTimerProgressEntity()
        async let catType =  cat.selectedCat
        return await DoroStateEntity(
            catType: catType,
            progressEntity: timerProgressEntity,
            settingEntity: timerSettingEntity
        )
    }
}
