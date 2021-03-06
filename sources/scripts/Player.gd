extends KinematicBody2D

export(NodePath) var walking_snd

var walk_spd = 150.0
var smooth_moves = 0.2
var move_vec = Vector2(0.0, 0.0)
var target_pos = Vector2(0.0, 0.0)
var gfx
var sz
var ani

var last_pos

var side
var front
var back

var newt
export var newt_mode = false
export var gravity = false

func _ready():
	Game.start_level()
	ani = get_node("AnimationPlayer")
	side = get_node("Side")
	front = get_node("Front")
	back = get_node("Back")
	
	newt = get_node("Newt")
	
	ani.play("Standing")
	sz = get_global_scale()
	target_pos = get_global_position()
	last_pos = get_global_position()
	
	walking_snd = get_node(walking_snd)
	walking_snd._set_playing(false)

func _process(delta):
	
	if(newt_mode):
		front.set_visible(false)
		back.set_visible(false)
		side.set_visible(false)
		newt.set_visible(true)
		get_node("Hotspot").enabled = false
		get_node("Hotspot newt").enabled = true
	else:
		newt.set_visible(false)
		get_node("Hotspot").enabled = true
		get_node("Hotspot newt").enabled = false
	
	
	facing()
	
	if(Game.paused || Game.talking):
		return	
	
	if(gravity):
		
		target_pos.y = get_global_position().y
		walking(delta)
		if(!is_on_wall()):
			move_and_slide(Vector2(0.0, 300.0))
#			target_pos = get_global_position()
	else:
		walking(delta)

func facing():
	if(newt_mode):
		return
	
	var pos = get_global_position()
	
	
	# Is moving
	if(pos != last_pos):
		if(ani.get_current_animation() != "Walking"):
			ani.play("Walking")
			walking_snd._set_playing(true)
		
		# Flip X scale
		if(pos.x > last_pos.x):
			front.set_scale(Vector2(1.0, 1.0))
			side.set_scale(Vector2(1.0, 1.0))
#			back.set_scale(Vector2(1.0, 1.0))
		else:
			front.set_scale(Vector2(-1.0, 1.0))
			side.set_scale(Vector2(-1.0, 1.0))
#			back.set_scale(Vector2(-1.0, 1.0))
		
		# Horizontal
		if(abs(pos.x - last_pos.x) > abs(pos.y - last_pos.y)):
			front.set_visible(false)
			back.set_visible(false)
			side.set_visible(true)
		
		# Vertical
		else:
			side.set_visible(false)
			
			# Down
			if(pos.y > last_pos.y):
				front.set_visible(true)
				back.set_visible(false)
			# Up
			else:
				front.set_visible(false)
				back.set_visible(true)
	else:
		if(ani.get_current_animation() != "Standing"):
			ani.play("Standing")
			walking_snd._set_playing(false)
	
	last_pos = get_global_position()

func walking(delta):
	
	if(Game.event_running):
		move_vec = target_pos - get_global_position()
		if(move_vec.length() > 10.0):
			move_and_slide(move_vec.normalized() * walk_spd)
	else:
		if(Input.is_mouse_button_pressed(BUTTON_LEFT) && Game.cursor.tool_mode == 0 && Game.wait_for_release == false):
			target_pos = get_global_mouse_position() #get_local_mouse_position() + get_global_position()
		else:
			move_vec = target_pos - get_global_position()
			if(move_vec.length() > 10.0):
				move_and_slide(move_vec.normalized() * walk_spd)
