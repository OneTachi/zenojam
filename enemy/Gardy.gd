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

onready var walk_to = Vector2(rand_range(-200, 200), self.position.y)
var walk_dir

var outside = false


func _physics_process(delta):
	randomize()
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
				walk_dir.y = 0
				velocity = walk_dir * 100
			
			velocity.y += 10
			velocity.y = min(velocity.y, 100)
		
		ATTACK:
			walk_dir = position.direction_to(player.position)
			walk_dir.y = 0
			velocity = walk_dir * 200
			sprite.play('walk')
			change_sprite_dir()
	
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
	var new_position = rand_range(-150, 150)
	walk_to = Vector2(new_position, self.position.y)


func _on_Restriction_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	walk_to = Vector2(-walk_to.x, self.position.y)


func _on_EnemyDetection_body_entered(body):
	state = 1
