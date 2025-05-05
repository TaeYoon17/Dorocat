//
//  LiveActivityClient.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
import ActivityKit

actor PomoLiveActivityClient: DoroLiveActivityDependency {
    private var currentID:String = ""
    static let shared = PomoLiveActivityClient()
    private init(){}
    func updateActivity(type: TimerActivityType,item:SessionItem,cat:CatType,restCount:Int) async {
#if os(iOS)
        if let activity = Activity.activities.first(where: { (activity:Activity<PomoAttributes>) in
            activity.id == currentID
        }){
            print("업데이트가 진행된다.")
            Task{
                let endTime = activity.content.state.endTime
                let updateState = PomoAttributes.ContentState(timerStatus: type,catType: cat, timerSession: item,
                                                              count: restCount, endTime: endTime)
                let content = ActivityContent(state: updateState, staleDate: nil)
                await activity.update(content)
            }
        }else{
            print("아무런 정보가 없다")
        }
#endif
    }
    func addActivity(type:TimerActivityType,item:SessionItem,cat:CatType,restCount: Int,totalCount:Int)  async {
#if os(iOS)
        let pomoAttributes = PomoAttributes()
        let initialState = PomoAttributes.ContentState(timerStatus: type,catType: cat, timerSession: item, count: restCount, endTime: totalCount)
        let content = ActivityContent(state: initialState, staleDate: nil)
        do{
            let activity = try Activity<PomoAttributes>.request(attributes: pomoAttributes, content: content)
            self.currentID = activity.id
            print("[PomoLiveActivity] 추가 성공 \(activity.content.state.count)")
        }catch{
            print("추가 실패")
            print(error.localizedDescription)
        }
#endif
    }
    func createActivity(type: TimerActivityType,item:SessionItem,cat:CatType,restCount: Int,totalCount:Int) async{
#if os(iOS)
        ActivityIntentManager.setDefaults(type: type)
        if let activity = Activity.activities.first(where: { (activity:Activity<PomoAttributes>) in
            activity.id == currentID
        }){
            try? await Task.sleep(for: .nanoseconds(100))
            let updateState = PomoAttributes.ContentState(timerStatus:type,catType: cat,timerSession:item,count: restCount, endTime: totalCount)
            let content = ActivityContent(state: updateState, staleDate: nil)
            await activity.update(content)
        }else{
            await addActivity(type:type,item: item,cat: cat,restCount: restCount,totalCount: totalCount)
        }
#endif
    }
    func removeActivity() async {
#if os(iOS)
        ActivityIntentManager.setDefaults(type: .standBy)
        await self.removeActivity(dismissPolicy: .immediate)
#endif
    }
    func removeActivity(dismissPolicy: ActivityUIDismissalPolicy = .default) async {
#if os(iOS)
        for activity in Activity<PomoAttributes>.activities{
                await activity.end(activity.content,dismissalPolicy: dismissPolicy)
        }
#endif
    }
}
