extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -240.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Hit Point 
var hitpoint = 100
var attack_dmg = 10
var is_attacking = false

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var attack_aoe = $AnimatedSprite2D/AttackAOE/CollisionShape2D
@onready var attack_timer = $timer/AttackTimer


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_L", "move_R")
	
	# Change sprite direction base on direction input 
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
	
	# Apply movement and play animations if not attacking
	if not is_attacking:
		if Input.is_action_just_pressed("attack_low"):
			animated_sprite_2d.play("low_attack")
			attack_dmg = 10
			attack_timer.start(0.2)
			is_attacking = true
			return

		if Input.is_action_just_pressed("attack_heavy"):
			animated_sprite_2d.play("heavy_attack")
			attack_dmg = 25
			attack_timer.start(0.2)
			is_attacking = true
			return

		if is_on_floor():
			if direction == 0:
				animated_sprite_2d.play("idle")
			else:
				animated_sprite_2d.play("walk")
		
	# Apply movement 
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func flip_area_2d(is_flipped):
	# Adjust the position of Area2D or its CollisionShape2D based on the flip state
	if is_flipped:
		attack_aoe.position.x = -abs(attack_aoe.position.x)
	else:
		attack_aoe.position.x = abs(attack_aoe.position.x)


# animation delay
func _on_attack_timer_timeout():
	attack_aoe.disabled = false
	

func _on_attack_aoe_body_entered(body):
		if body.is_in_group("Hit"):
			body.get_hit(attack_dmg)
		


