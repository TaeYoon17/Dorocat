#  TimeFeature 기능 명세

## 앱의 상태들
1. active => 앱이 깨어있는 상태
2. inActive => 앱이 비활성화 되어있는 상태 => 예시) 멀티태스킹에 있음
3. background => 앱이 꺼져있는 상태 + 언제든지 suspend(앱이 꺼짐)가 될 수 있음

## Timer의 상태(State)들
1. standBy => 타이머 시작을 기다리는 상태
2. focus => 집중하고 있는 상태
3. pause => 타이머를 멈춘 상태, 2가지 존재함
    - focus를 멈춘 상태
    - breakTime를 멈춘 상태
4. breakTime => 하나의 focus가 끝난 후 쉬는 상태
5. completed => 모든 타이머가 끝난 후 유저의 액션을 기다리는 상태
-- 타이머를 사용하는 상태
+ focus
+ breakTime

## 기능 규칙
+ 타이머 세팅은 StandBy 상태만 가능하다.
+ 고양이와 Trigger 버튼의 동작은 동일하게 이루어진다.
### background로 전환시 PomoValue 내부 TimerStatus와 timeBackground Status
- PomoValue Status
+ PomoValue의 Status는 타이머를 사용하는 상태를 사용하지 않는다
    => focus, breakTime
+ PomoValue에서 background로 전환시 타이머 사용 상태가 아니면 그 상태를 그대로 저장한다.
- timerBackground Status
+ background로 전환시 그대로 저장한다.
