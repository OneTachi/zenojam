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
	WAIT,
}

var state = WALK setget set_state
var velocity = Vector2(0,0)

onready var walk_to = Vector2(rand_range(-200, 200), self.position.y)
var walk_dir

var outside = false
var attacking = false
var redirect = DASH
onready var predetermined_action = pick_next_move() 

func _physics_process(delta):
	randomize()
	#print(anim.get_current_node())
	#print(sprite.offset)
	#print(sprite.flip_h)
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
			change_sprite_dir()
			
			#Direction to run to
			walk_dir = position.direction_to(player.position)
			walk_dir.y = 0
			
			anim.travel('run')
			if anim.get_current_node() == 'run':
				sprite.offset = Vector2(0, 0)
			
			
			velocity = walk_dir * 200
			
			#Action to do when in distance
			var player_distance = self.position.distance_to(player.position)
			if player_distance > 50 && player_distance < 175:
				if predetermined_action != RUN:
					self.state = predetermined_action
			if player_distance < 50:
				self.state = BASIC_ATTACK
		
		BASIC_ATTACK:
			anim.travel('attack1')
			velocity = Vector2.ZERO
			if anim.get_current_node() == 'attack1':
				make_attack()
		
		DASH: 
			var fDir = 1
			if not sprite.flip_h:
				fDir = -fDir
			velocity.x = fDir * 150
			anim.travel('dash')
		
		WAIT:
			anim.travel('idle')
			velocity = Vector2.ZERO
			
			#Weird Buildup of speed using yield
			#yield(get_tree().create_timer(.4), "timeout")
			if $WaitTimer.is_stopped():
				$WaitTimer.start(.4)
			
	
	move_and_slide(velocity)

func change_sprite_dir():
	if velocity.x > 0:
		sprite.flip_h = false
		raycast.cast_to = Vector2(0, 20)
	elif velocity.x < 0:
		sprite.flip_h = true
		raycast.cast_to = Vector2(0, -20)

#Changing sprite direction when attacking
func make_attack():
	if not sprite.flip_h: 
		sprite.offset = Vector2(9.5, -8)
	elif sprite.flip_h:
		sprite.offset = Vector2(-9.5, -8)

func _on_WalkingHere_timeout():
	var new_position = rand_range(-150, 150)
	walk_to = Vector2(new_position, self.position.y)
func _on_EnemyDetection_body_entered(body):
	self.state = RUN

func set_state(new_state):
	if state != new_state:
		predetermined_action = pick_next_move()
	state = new_state


#Animations dictage changes to states
func finish_dash():
	redirect = RUN
	self.state = WAIT
func finish_attack():
	if self.position.distance_to(player.position) > 50:
		self.state = RUN


func pick_next_move():
	#Run will auto turn to basic attack
	var moves = [DASH, RUN, RUN]
	moves.shuffle()
	#print(moves)
	return moves.pop_front()


func _on_WaitTimer_timeout():
	self.state = redirect
