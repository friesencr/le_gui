require "Scripts/hooks"
require("Scripts/constants/keycodes")
require("Scripts/constants/engine_const")

--Register abstract path
RegisterAbstractPath("")

--Set graphics mode
if Graphics(1024,768)==0 then
	Notify("Failed to set graphics mode.",1)
	return
end

--Create framewerk object and set it to a global object so other scripts can access it
framework=CreateFramework()
if framework==nil then
	Notify("Failed to initialize engine.",1)
	return
end
SetGlobalObject("framewerk",framework)

package.loadlib("timer.dll", "luaopen_timer")()
require("lib/le_gui/src/le_gui")

Gui.setup()

dofile("lib/le_gui/main_menu.lua")
demo_region = Gui.Element({ name = 'demo_region'})
dofile("lib/le_gui/font_awesome.lua")

while AppTerminate()==0 do
	if KeyHit(KEY_ESCAPE)==1 then break end
	update_timer()
	delta_timer = get_delta_time_in_ms()
	UpdateFramework()
	RenderFramework()
	Flip(0)
end
