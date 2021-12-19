extends KinematicBody2D

var moveIncr = .2
var velocity = Vector2(0, 0)

var max_jump = -800
var reached_height_max
const jump_force = -650
var jumped

func _ready():
	pass

func _physics_process(delta):
	var xRaw = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if xRaw != 0:
		velocity.x = lerp(velocity.x, xRaw * 350, moveIncr)
	else:
		velocity.x = lerp(velocity.x, 0, .5)
	
	if is_on_floor() && Input.is_action_just_pressed("jump"): 
		velocity.y = jump_force
		jumped = true
	
	if jumped && Input.is_action_pressed("jump"):
		velocity.y -= 25
	
	if Input.is_action_just_released("jump") || velocity.y <= max_jump:
		jumped = false
	print(velocity.y)
	
	if is_on_floor():
		reached_height_max = false
	
	
	velocity.y = min(velocity.y + 50, 1000)
	
	move_and_slide(velocity, Vector2.UP)
