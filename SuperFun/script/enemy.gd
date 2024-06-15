extends CharacterBody2D


const SPEED = 60.0
const JUMP_VELOCITY = -100.0
#HitPoint
var hitpoint = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1
# Iframe for delay income dmg from player
var iframe = false
var attack_dmg = 10
var is_attacking = false
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_down = $RayCastDown
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var iframe_time = $Timer/iframe

# Physics system
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	# Change sprite direction base on direction input 
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
	
	if not is_attacking:
		if is_on_floor():
			if direction == 0:
				animated_sprite_2d.play("default")
			else:
				animated_sprite_2d.play("walk")

	move_and_slide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
	if ray_cast_left.is_colliding():
		direction = 1
		
	position.x += direction * SPEED * delta 

# Take dmg and sub hitpoint and update hitpoint
func get_hit(dmg):
	if not iframe:
		hitpoint = hitpoint - dmg
		is_attacking = true
		animated_sprite_2d.play("hurt")
		iframe = true
		iframe_time.start(0.5)


func _on_iframe_timeout():
	iframe = false
	is_attacking = false
