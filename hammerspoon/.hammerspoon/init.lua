-- ─────────────────────────────────────────────
-- Hammerspoon 설정
-- ─────────────────────────────────────────────

-- ─────────────────────────────────────────────
-- 핫키: Cmd + Option + V
-- 클립보드 이미지를 temp 디렉토리에 저장하고 절대경로 복사
-- ─────────────────────────────────────────────
hs.hotkey.bind({"cmd", "alt"}, "v", function()
  local img = hs.pasteboard.readImage()
  if not img then
    hs.alert.show("⚠️ 클립보드에 이미지가 없습니다")
    return
  end

  -- 파일명 생성: clipboard-YYYYMMDD-HHMMSS.png
  local filename = os.date("clipboard-%Y%m%d-%H%M%S") .. ".png"

  -- ~/Downloads 에 저장 (Pi analyze_image 호환)
  local clipDir = os.getenv("HOME") .. "/Downloads/pi-clipboard"
  os.execute("mkdir -p " .. clipDir)
  local path = clipDir .. "/" .. filename
  img:saveToFile(path)

  -- 클립보드에 절대 경로 복사
  hs.pasteboard.setContents(path)

  hs.alert.show("✅ " .. path)
end)

-- ─────────────────────────────────────────────
-- 로딩 완료 알림
-- ─────────────────────────────────────────────
hs.alert.show("🍯 Hammerspoon loaded!\nCmd+Option+V → 이미지 붙여넣기")
