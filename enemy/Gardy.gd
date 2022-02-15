extends KinematicBody2D

onready var sprite = $Sprite
onready var walk_timer = $"WalkingHere!"
onready var player = $'../Player'
onready var raycast = $RayCast2D
onready var anim_tree = $AnimationTree
onready var anim = anim_tree['parameters/playback']

enum {
	WALK,
	RUN,
	BASIC_ATTACK,
	DASH,
}

var state = WALK
var velocity = Vector2(0,0)

onready var walk_to = Vector2(rand_range(-200, 200), self.position.y)
var walk_dir

var outside = false
var attacking = false

func _physics_process(delta):
	randomize()
	#print(anim.get_current_node())
	#print(state)
	match state:
		
		WALK:
			#TODO: Possible addition of boundary detection
			if (self.position.distance_to(walk_to) < 5 && walk_timer.is_stopped()):
				walk_dir = Vector2(0, self.position.y)
				velocity = Vector2.ZERO
				anim.travel("idle")
				walk_timer.start(randi() % 3)
			if walk_timer.is_stopped():
				anim.travel("walk")
				change_sprite_dir()
				walk_dir = position.direction_to(walk_to)
				walk_dir.y = 0
				velocity = walk_dir * 100
			
			velocity.y += 10
			velocity.y = min(velocity.y, 100)
		
		RUN:
			walk_dir = position.direction_to(player.position)
			anim.travel('run')
			if anim.get_current_node() == 'run':
				sprite.offset = Vector2(0, 0)
			walk_dir.y = 0
			velocity = walk_dir * 200
			change_sprite_dir()
			var player_distance = self.position.distance_to(player.position)
			if rand_range(0, 1000) > 50 && player_distance > 50 && player_distance < 175:
				#YIELD TODO
				state = DASH
				
			if player_distance < 50:
				state = BASIC_ATTACK
		
		BASIC_ATTACK:
			anim.travel('attack1')
			velocity = Vector2.ZERO
			if anim.get_current_node() == 'attack1':
				make_attack()
		
		DASH: 
			var fDir = 1
			var sOffset = Vector2(0, -4)
			sprite.offset = sOffset
			if not sprite.flip_h:
				fDir = -fDir
			velocity.x = fDir * 350
			anim.travel('dash')
	
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

func make_attack():
	if not sprite.flip_h: 
		sprite.offset = Vector2(9.5, -8)
	elif sprite.flip_h:
		sprite.offset = Vector2(-9.5, -8)

func _on_WalkingHere_timeout():
	var new_position = rand_range(-150, 150)
	walk_to = Vector2(new_position, self.position.y)
func _on_Restriction_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	walk_to = Vector2(-walk_to.x, self.position.y)
func _on_EnemyDetection_body_entered(body):
	state = 1

func finish_dash():
	state = RUN
func finish_attack():
	if self.position.distance_to(player.position) > 50:
		state = RUN
