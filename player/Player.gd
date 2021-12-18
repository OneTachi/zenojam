extends KinematicBody2D

var moveIncr = .2
var xMove = 0
var yMove = 0
var jumped = false
var jump_position

func _ready():
	pass

func _physics_process(delta):
	var xRaw = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if xRaw != 0:
		xMove = lerp(xMove, xRaw * 350, moveIncr)
	else:
		xMove = lerp(xMove, 0, .5)
	
	if !jumped && Input.is_action_pressed("jump"): 
		if !yMove <= 0:
			jump_position = self.position.y
		yMove = -1000
	
	if !is_on_floor() && yMove < 0 && self.position.y - jump_position < -200:
		jumped = true
	elif is_on_floor():
		jumped = false
	
	if jump_position != null:
		print(self.position.y - jump_position )
	yMove = min(yMove + 50, 1000)
	if jumped && yMove > 0 && yMove < 1000: 
		yMove = yMove * (1 + .05) 
	
	var movement = Vector2(xMove, yMove)
	move_and_slide(movement, Vector2.UP)
