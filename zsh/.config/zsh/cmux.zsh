# pi-cmux notification settings
# https://github.com/javiermolinar/pi-cmux

# Notification level: all | medium | low | disabled
#   all      - Waiting, Task Complete, Error (모든 알림)
#   medium   - Task Complete, Error (작업 완료/에러만)
#   low      - Error only (에러만)
#   disabled - 알림 끄기
export PI_CMUX_NOTIFY_LEVEL=all

# 알림 표시 제목
export PI_CMUX_NOTIFY_TITLE=Pi

# Task Complete으로 간주할 최소 실행 시간 (ms, 기본 15000)
# 이 시간 이상 걸린 작업은 "Waiting" 대신 "Task Complete" 알림
export PI_CMUX_NOTIFY_THRESHOLD_MS=15000

# 중복 알림 debounce 간격 (ms, 기본 3000)
export PI_CMUX_NOTIFY_DEBOUNCE_MS=3000
