extends KinematicBody2D

onready var sprite = $Sprite
onready var hitbox_rot = $Position2D
onready var hitbox = $Position2D/AttackHitbox

var moveIncr = .2
var velocity = Vector2(0, 0)

var max_jump = -800
var reached_height_max
const jump_force = -650
var jumped

var attacked = false

const max_hp = 5
var hp = 5 setget set_hp
func set_hp(value):
	hp = value



func _ready():
	hitbox.monitoring = false

func _physics_process(delta):
	var xRaw = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if xRaw != 0 && not attacked:
		velocity.x = lerp(velocity.x, xRaw * 350, moveIncr)
	else:
		velocity.x = lerp(velocity.x, 0, .5)
	
	if xRaw != 0: 
		sprite_manager('run')
		if xRaw > 0:
			sprite.flip_h = false
			hitbox_rot.rotation_degrees = 0
		elif xRaw < 0:
			sprite.flip_h = true
			hitbox_rot.rotation_degrees = 180
	else:
		sprite_manager('idle')
	
	if is_on_floor() && Input.is_action_just_pressed("jump") and not attacked: 
		velocity.y = jump_force
		jumped = true
	
	if jumped && Input.is_action_pressed("jump"):
		velocity.y -= 25
	
	if Input.is_action_just_released("jump") || velocity.y <= max_jump:
		jumped = false
	#print(velocity.y)
	
	if not is_on_floor() && velocity.y < 0:
		sprite_manager('jump')
	elif not is_on_floor() && velocity.y >= 0:
		sprite_manager('fall')
	
	
	velocity.y = min(velocity.y + 50, 1000)
	if is_on_floor():
		reached_height_max = false
		velocity.y = min(velocity.y, 50)
	
	if Input.is_action_just_pressed('attack') && is_on_floor():
		hitbox.monitoring = true
		sprite_manager('attack')
		attacked = true
	
	move_and_slide(velocity, Vector2.UP)

func sprite_manager(anim):
	if not attacked:
		sprite.play(anim)

func _on_Sprite_animation_finished():
	attacked = false
