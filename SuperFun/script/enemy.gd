extends CharacterBody2D

const SPEED = 60.0
const ATTACK_DISTANCE = 20.0
const ATTACK_COOLDOWN = 0.7
# HitPoint
var hitpoint = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1
# Iframe for delay incoming dmg from player
var iframe = false
var attack_dmg = 10
var is_attacking = false
var player = null
var player_detected = false

@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var iframe_time = $Timer/iframe
@onready var attack_cooldown = $Timer/attack_cooldown
@onready var aoe_detect_time = $"Timer/DetectTime"
@onready var collision_shape_2d = $CollisionShape2D
@onready var player_detection_area = $PlayerDetectionArea
@onready var attack_aoe = $AttackAoe/CollisionShape2D

# Physics system
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	# Change sprite direction based on direction input
	if direction > 0:
		flip_area_2d(true)
	elif direction < 0:
		flip_area_2d(false)

	if not is_attacking and hitpoint > 0:
		if is_on_floor():
			if direction == 0:
				animated_sprite_2d.play("default")
			else:
				animated_sprite_2d.play("walk")
	
	move_and_slide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitpoint <= 0:
		return
	if player_detected and not is_attacking:
		chase_player(delta)
	else:
		if not is_attacking:
			patrol(delta)

func patrol(delta):
	if ray_cast_right.is_colliding():
		direction = -1
	if ray_cast_left.is_colliding():
		direction = 1
	if hitpoint > 0:
		position.x += direction * SPEED * delta

func chase_player(delta):
	if player:
		var direction_to_player = (player.position - position).normalized()
		position += direction_to_player * SPEED * delta
		# Update direction based on player's position
		if direction_to_player.x > 0:
			direction = 1
			flip_area_2d(true)
		elif direction_to_player.x < 0:
			direction = -1
			flip_area_2d(false)

		# Check if within attack distance and initiate attack
		if position.distance_to(player.position) <= ATTACK_DISTANCE and not is_attacking:
			attack_player()

func attack_player():
	is_attacking = true
	animated_sprite_2d.play("attack")
	aoe_detect_time.start(0.4)
	attack_cooldown.start(ATTACK_COOLDOWN)

func _on_attack_cooldown_timeout():
	is_attacking = false
	attack_aoe.disabled = true  # Disable the attack AOE after the attack is finished

func _on_attack_aoe_body_entered(body):
	if hitpoint > 0 and is_attacking and body.is_in_group("Player"):
		body.get_hit(attack_dmg)  # Assume the player has a get_hit function

func flip_area_2d(is_flipped):
	# Adjust the position of Area2D or its CollisionShape2D based on the flip state
	if is_flipped:
		animated_sprite_2d.flip_h = false
		attack_aoe.position.x = abs(attack_aoe.position.x)
	else:
		animated_sprite_2d.flip_h = true
		attack_aoe.position.x = -abs(attack_aoe.position.x)

# Take dmg and sub hitpoint and update hitpoint
func get_hit(dmg):
	if not iframe:
		hitpoint -= dmg
		is_attacking = true
		animated_sprite_2d.play("hurt")
		print("Ohh Hit Point", hitpoint)
		if hitpoint <= 0:
			animated_sprite_2d.play("death")
			# c layer 32 for dead entity
			collision_layer = 32
			iframe = true
		else:
			iframe = true
			iframe_time.start(0.5)

func _on_iframe_timeout():
	if hitpoint > 0:
		iframe = false
		is_attacking = false

func _on_player_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		player_detected = true

func _on_player_detection_area_body_exited(body):
	if body == player:
		player = null
		player_detected = false


func _on_detect_time_timeout():
	if is_attacking:
		attack_aoe.disabled = false  # Enable the attack AOE
