local ej = require "ejoy2d"
local ejoy2dx = require "ejoy2dx"
local fw = require "ejoy2d.framework"
local package = require "ejoy2dx.package"
local image = require "ejoy2dx.image"
local message = require "ejoy2dx.message"

local render = require "ejoy2dx.render"
render:fixed_adapter(1024, 768)

local shader = require "shader"
shader:init()

if OS == "WINDOWS" then
	local keymap = require "ejoy2dx.keymap"
	local windows_hotkey = require "ejoy2dx.windows_hotkey"
	windows_hotkey:init()
	windows_hotkey.handlers.up[keymap.VK_A] = function(char, is_repeat)
		print("KEY A up", is_repeat)
	end
end

package:path(fw.WorkDir..[[/asset/?]])

local logo = image:load_image("logo.png")
local pic = image:load_image("rock.png")
local pic_n = image:load_image("rock_n.png")

local sample_render = render:create(0, 'default')
local light_render = render:create_offscreen(1, 1024, 768, 'light', true, 0xFFFF0000)
light_render:show(logo, 0, render.center)
light_render:show(pic, 0, render.center)
logo:ps(0, -200)

local normal_render = render:create_offscreen(2, 1024, 768, 'normal', true, 0)
normal_render:show(pic_n, 0, render.center)
logo:ps(0, -200)

local screen_spr = image:texture_sprite("render_map", light_render.offscreen_id, light_render.w, light_render.h, true)
screen_spr.program = "SHADOW"
screen_spr.material:texture(normal_render.offscreen_id, 1)
screen_spr.material:light_position(0, 0, 1)
light_render.on_offscreen_draw = function()
	sample_render:show(screen_spr, 0, {x=512, y=384, scale=1})
end

local game = {}
local screencoord = { x = 496, y = 316, scale = 1 }

local function light_position(x, y)
	screen_spr.material:light_position(2*(x-512)/1024, -2*(y-384)*0.75/768, 1)
end

function game.update()
end

function game.drawframe()
	ej.clear(0)
	render:draw()
end

function game.touch(what, x, y)
	print(x, y)
	light_position(x, y)
end

function game.message(...)
	message.on_message(...)
end

function game.handle_error(type, msg)
	if error_render then return end
	ejoy2dx.game_stat:pause()
	
	local sprite = require("ejoy2d.sprite")
	render:clear()
	error_render = render:create(9999, "error")
	local width = render.design_width-20
	local loading_text = sprite.label({width=width, height=24,size=32,color=0xFFaaaaaa, edge=1, align='l'})
	loading_text:ps(2, 20)
	error_render:show(loading_text)

	loading_text.text = "#[red]游戏出现错误，重启试试#[stop]\n"..(msg or "")
end

function game.on_resume()
end

function game.on_pause()
end

function game.gesture()
end

ej.start(game)


