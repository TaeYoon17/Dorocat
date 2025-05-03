//
//  DoroStateUserDefaultsClient.swift
//  Dorocat
//
//  Created by Greem on 11/9/24.
//

import Foundation

extension DoroDefaultsClient {
    fileprivate enum Label {
        static let catType = "SelectedCatType"
        static let isPromode = "IsPromode"
        static let timerSettingEntity = "TimerSettingEntity"
        static let timerProgressEntity = "TimerProgressEntity"
    }
}

actor DoroDefaultsClient: DoroDefaults {
    let st = UserDefaults.standard
    func setCatType(_ type: CatType) async {
        st.setValue(try? JSONEncoder().encode(type), forKey: Label.catType)
    }
    
    func getCatType() async -> CatType {
        guard let data = st.data(forKey: Label.catType) else {
            return CatType.doro
        }
        return (try? JSONDecoder().decode(CatType.self, from: data)) ?? CatType.doro
    }
}

extension DoroDefaultsClient {
    func setIsPromode(_ isPromode: Bool) async {
        st.setValue(isPromode, forKey: Label.isPromode)
    }
    
    func getIsPromode() async -> Bool {
        st.bool(forKey: Label.isPromode)
    }
}


extension DoroDefaultsClient {
    func setTimerSettingEntity(_ entity: TimerSettingEntity) async {
        let data = try? JSONEncoder().encode(entity)
        st.set(data, forKey: Label.timerSettingEntity)
    }
    
    func getTimerSettingEntity() async -> TimerSettingEntity {
        guard let data = st.data(forKey: Label.timerSettingEntity) else {
            return TimerSettingEntity()
        }
        return (try? JSONDecoder().decode(TimerSettingEntity.self, from: data)) ?? TimerSettingEntity()
    }
}

extension DoroDefaultsClient {
    func setTimerProgressEntity(_ entity: TimerProgressEntity) async {
        let data = try? JSONEncoder().encode(entity)
        st.set(data, forKey: Label.timerProgressEntity)
    }
    
    func getTimerProgressEntity() async -> TimerProgressEntity {
        guard let data = st.data(forKey: Label.timerProgressEntity) else {
            return TimerProgressEntity()
        }
        return (try? JSONDecoder().decode(TimerProgressEntity.self, from: data)) ?? TimerProgressEntity()
    }
}


extension DoroDefaultsClient {
    func setDoroStateEntity(_ entity: DoroStateEntity) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.setTimerSettingEntity(entity.settingEntity) }
            group.addTask { await self.setTimerProgressEntity(entity.progressEntity) }
            group.addTask { await self.setCatType(entity.catType) }
            group.addTask { await self.setIsPromode(entity.isProMode) }
        }
    }
    
    func getDoroStateEntity() async -> DoroStateEntity {
        async let timerSettingEntity = getTimerSettingEntity()
        async let timerProgressEntity = getTimerProgressEntity()
        async let catType = getCatType()
        async let isPromode = getIsPromode()
        return await DoroStateEntity(catType: catType,
                                     isProMode: isPromode,
                                     progressEntity: timerProgressEntity,
                                     settingEntity: timerSettingEntity)
    }
}
