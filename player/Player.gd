extends KinematicBody2D

onready var sprite = $Sprite

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
	
	if xRaw != 0 : 
		sprite.play('run')
		if xRaw > 0:
			sprite.flip_h = false
		elif xRaw < 0:
			sprite.flip_h = true
	else:
		sprite.play('idle')
	
	if is_on_floor() && Input.is_action_just_pressed("jump"): 
		velocity.y = jump_force
		jumped = true
	
	if jumped && Input.is_action_pressed("jump"):
		velocity.y -= 25
	
	if Input.is_action_just_released("jump") || velocity.y <= max_jump:
		jumped = false
	#print(velocity.y)
	
	if not is_on_floor() && velocity.y < 0:
		sprite.play('jump')
	elif not is_on_floor() && velocity.y >= 0:
		sprite.play('fall')
	
	
	velocity.y = min(velocity.y + 50, 1000)
	if is_on_floor():
		reached_height_max = false
		velocity.y = min(velocity.y, 50)
	
	move_and_slide(velocity, Vector2.UP)
