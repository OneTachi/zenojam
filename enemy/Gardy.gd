extends KinematicBody2D

onready var sprite = $Sprite
onready var walk_timer = $"WalkingHere!"
onready var player = $'../Player'
onready var raycast = $RayCast2D

enum {
	WALK,
	ATTACK
}

var state = WALK
var velocity = Vector2(0,0)

onready var walk_to = Vector2(rand_range(-200, 200), position.y)
var walk_dir



func _physics_process(delta):
	match state:
		
		WALK:
			#TODO: Possible addition of boundary detection
			if (self.position.distance_to(walk_to) < 5 && walk_timer.is_stopped()):
				walk_dir = Vector2(0, self.position.y)
				velocity = Vector2.ZERO
				sprite.play('idle')
				walk_timer.start(randi() % 3)
			if walk_timer.is_stopped():
				sprite.play('walk')
				change_sprite_dir()
				walk_dir = position.direction_to(walk_to)
				velocity = walk_dir * 100
			
			velocity.y += 10
			velocity.y = max(velocity.y, 100)
		
		ATTACK:
			pass
	
	move_and_slide(velocity)

func change_sprite_dir():
	if velocity.x > 0:
		sprite.flip_h = false
		raycast.cast_to = Vector2(0, 20)
	elif velocity.x < 0:
		sprite.flip_h = true
		raycast.cast_to = Vector2(0, -20)
	else:
		pass



func _on_WalkingHere_timeout():
	var new_position = rand_range(-200, 200)
	walk_to = Vector2(new_position, self.position.y)
	print(walk_to)
