#  TimeFeature 기능 명세

## 앱의 상태들
1. active => 앱이 깨어있는 상태
2. inActive => 앱이 비활성화 되어있는 상태 => 예시) 멀티태스킹에 있음
3. background => 앱이 꺼져있는 상태 + 언제든지 suspend(앱이 꺼짐)가 될 수 있음

## Timer의 상태(State)들
1. standBy => 타이머 시작을 기다리는 상태
2. focus => 집중하고 있는 상태
3. pause => 타이머를 멈춘 상태, 3가지 존재함
    - focus를 멈춘 상태
    - shortBreak를 멈춘 상태
    - longBreak를 멈춘 상태
4. completed => 모든 타이머가 끝난 후 유저의 액션을 기다리는 상태
5. shorbreak => 하나의 focus가 끝난 후 중간 쉬는 상태
6. longbreak => focus 사이클이 끝난 후 마지막 쉬는 상태 
7. sleep => 앱이 background로 가있는 상태
-- 타이머를 사용하는 상태
+ focus
+ shortbreak
+ longbreak

## 기능 규칙
+ 타이머 세팅은 StandBy만 가능하다.
