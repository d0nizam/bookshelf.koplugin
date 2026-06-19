--[[
Persistent Bookshelf launcher button for the reader view.

Registered with ReaderView via view:registerViewModule (the Bookends overlay
mechanism), so its paintTo runs as part of every ReaderView paint pass -- drawn
INTO the reader frame, surviving page turns / refreshes rather than floating on
the window stack where an e-ink refresh would ghost it. main.lua registers a
touch zone over the button that opens the start menu.

Position + bar design come from lib/bookshelf_footer_geom, the single source the
home-screen footer button also uses -- so the launcher is pixel-identical and
tracks any change to the footer button. When the bookshelf has been shown this
session, footer_geom hands back the REAL painted rect; otherwise a computed
fallback.
]]
local Blitbuffer = require("ffi/blitbuffer")
local Device     = require("device")
local FooterGeom = require("lib/bookshelf_footer_geom")
local Geom       = require("ui/geometry")
local Widget     = require("ui/widget/widget")
local Screen     = Device.screen

local ReaderButtons = Widget:extend{
    side = "left",  -- "left" | "right" (from start_menu_position)
}

function ReaderButtons:paintTo(_bb, _x, _y)
    local sw, sh = Screen:getWidth(), Screen:getHeight()
    local cx, top = FooterGeom.launcherBarsAnchor(sw, sh, self.side)
    local m = FooterGeom.barMetrics()
    local left = cx - math.floor(m.bar_w / 2)
    for i = 0, 2 do
        _bb:paintRect(left, top + i * (m.bar_t + m.gap), m.bar_w, m.bar_t,
            Blitbuffer.COLOR_BLACK)
    end
    self.dimen = Geom:new{ x = left, y = top, w = m.bar_w, h = m.span }
end

-- Touch target: a comfortable box around the bars (NOT the full footer button
-- width -- in the reader that would swallow the bottom corner's page-turn taps).
function ReaderButtons.tapRect(side)
    local sw, sh = Screen:getWidth(), Screen:getHeight()
    local cx, top = FooterGeom.launcherBarsAnchor(sw, sh, side)
    local m = FooterGeom.barMetrics()
    local pad = Screen:scaleBySize(10)
    local w = m.bar_w + 2 * pad
    local h = m.span + 2 * pad
    return Geom:new{ x = math.max(0, cx - math.floor(w / 2)),
                     y = math.max(0, top - pad), w = w, h = h }
end

return ReaderButtons
