extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -240.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Hit Point 
var hitpoint = 100
var attack_dmg = 10
var is_attacking = false
var got_hit = false
var i_frame = false

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var attack_aoe = $AttackAOE/CollisionShape2D
@onready var attack_timer = $timer/AttackTimer
@onready var hurt = $timer/Hurt
@onready var iframe = $timer/Iframe
@onready var restart = $timer/restart

func _process(delta):
	if hitpoint <= 0:
		animated_sprite_2d.play("hurt")
		get_tree().reload_current_scene()

func _physics_process(delta):
	if hitpoint <= 0:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_L", "move_R")

	# Change sprite direction based on direction input
	if direction > 0:
		animated_sprite_2d.flip_h = false
		flip_area_2d(false)
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		flip_area_2d(true)

	# Check if the attack animation has finished
	if is_attacking and not animated_sprite_2d.is_playing():
		attack_aoe.disabled = true
		is_attacking = false

	# Handle player attacks
	if not is_attacking and not got_hit:
		handle_attacks()

	# Apply movement and play animations if not attacking or hit
	if not is_attacking and not got_hit:
		handle_movement_animations(direction)

	# Apply movement 
	if direction != 0 and not got_hit:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# Handle player attacks
func handle_attacks():
	if Input.is_action_just_pressed("attack_low"):
		animated_sprite_2d.play("low_attack")
		attack_dmg = 10
		attack_timer.start(0.2)
		is_attacking = true
	elif Input.is_action_just_pressed("attack_heavy"):
		animated_sprite_2d.play("heavy_attack")
		attack_dmg = 25
		attack_timer.start(0.2)
		is_attacking = true

# Handle movement animations
func handle_movement_animations(direction):
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("walk")

func flip_area_2d(is_flipped):
	 #Adjust the position of Area2D or its CollisionShape2D based on the flip state
	if is_flipped:
		attack_aoe.position.x = -abs(attack_aoe.position.x)
	else:
		attack_aoe.position.x = abs(attack_aoe.position.x)
		
func get_hit(dmg):
	if hitpoint <= 0:
		return
	if not i_frame:
		got_hit = true
		i_frame = true
		hitpoint = hitpoint - dmg
		animated_sprite_2d.play("hurt")
		hurt.start(0.5)
		iframe.start(1.0)
# animation delay
func _on_attack_timer_timeout():
	attack_aoe.disabled = false
	

func _on_attack_aoe_body_entered(body):
		if body.is_in_group("Enemy"):
			body.get_hit(attack_dmg)
	

func _on_hurt_timeout():
	got_hit = false


func _on_iframe_timeout():
	i_frame = false 


func _on_restart_timeout():
	print("dead")
