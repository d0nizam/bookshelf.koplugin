--[[
Persistent Bookshelf launcher button for the reader view.

Registered with ReaderView via view:registerViewModule (the same mechanism the
Bookends overlay uses), so its paintTo runs as part of every ReaderView paint
pass -- it's drawn INTO the reader frame and survives page turns / refreshes,
rather than floating on the window stack where an e-ink refresh would ghost or
erase it. main.lua registers a touch zone over the button rect that opens the
start menu.

A small bordered box in a bottom corner: white fill + thin border so the
hamburger reads over page text, sized like the home-screen footer button.
]]
local Blitbuffer = require("ffi/blitbuffer")
local Device     = require("device")
local Geom       = require("ui/geometry")
local Widget     = require("ui/widget/widget")
local Screen     = Device.screen

local ReaderButtons = Widget:extend{
    side = "left",  -- "left" | "right" bottom corner
}

-- Screen rect of the button, derived fresh so it tracks rotation / resize. Kept
-- in sync with the touch zone registered in main.lua (which uses the same
-- ratios). Bottom corner, inset by a margin and lifted clear of the very edge.
function ReaderButtons.geom(side)
    local size   = Screen:scaleBySize(40)
    local margin = Screen:scaleBySize(8)
    local sw, sh = Screen:getWidth(), Screen:getHeight()
    local x = (side == "right") and (sw - size - margin) or margin
    local y = sh - size - margin
    return Geom:new{ x = x, y = y, w = size, h = size }
end

function ReaderButtons:paintTo(bb, _x, _y)
    local g = ReaderButtons.geom(self.side)
    self.dimen = g
    local radius = Screen:scaleBySize(4)
    local border = math.max(1, Screen:scaleBySize(1))
    -- White card so the glyph reads over text, with a thin border.
    bb:paintRoundedRect(g.x, g.y, g.w, g.h, Blitbuffer.COLOR_WHITE, radius)
    bb:paintBorder(g.x, g.y, g.w, g.h, border, Blitbuffer.COLOR_BLACK, radius)
    -- Hamburger: three centred bars (matches the footer's start-menu icon).
    local bar_w = math.floor(g.w * 0.5)
    local bar_t = math.max(1, Screen:scaleBySize(2))
    local gap   = math.max(1, math.floor((g.h * 0.4 - 3 * bar_t) / 2))
    local span  = 3 * bar_t + 2 * gap
    local top   = g.y + math.floor((g.h - span) / 2)
    local left  = g.x + math.floor((g.w - bar_w) / 2)
    for i = 0, 2 do
        bb:paintRect(left, top + i * (bar_t + gap), bar_w, bar_t, Blitbuffer.COLOR_BLACK)
    end
end

return ReaderButtons
