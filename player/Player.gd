extends KinematicBody2D

var moveIncr = .2
var xMove = 0
var yMove = 0

func _ready():
	pass

func _physics_process(delta):
	var xRaw = Input.get_action_strength("right") - Input.get_action_strength("left")
	var yRaw = Input.get_action_strength("jump")
	
	if xRaw != 0:
		xMove = lerp(xMove, xRaw * 350, moveIncr)
	else:
		xMove = lerp(xMove, 0, .5)
	
	yMove += 10
	
	var movement = Vector2(xMove, yMove)
	move_and_slide(movement)
