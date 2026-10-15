extends CharacterBody2D

# Notify other systems when the player dies.
signal died

@export var move_speed: float = 180.0
@export_range(0.1, 20.0, 0.1) var shots_per_second: float = 5.0
@export var projectile_scene: PackedScene

@onready var aim_pivot: Node2D = $AimPivot
@onready var muzzle: Marker2D = $AimPivot/Muzzle
# Reference the player's health component.
@onready var health_component: HealthComponent = $HealthComponent

var _shot_cooldown: float = 0.0
# Tracks whether the player has died.
var is_dead: bool = false

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	#Listen for the health component's death signal.
	health_component.died.connect(_on_player_died)

func _physics_process(delta: float) -> void:
	
	# Stop processing gameplay after death.
	if is_dead:
		velocity = Vector2.ZERO
		return
		
	# Move using WASD.
	var input_direction: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
        "move_down"
	)

	velocity = input_direction * move_speed
	move_and_slide()

	# Aim independently of movement.
	aim_pivot.look_at(get_global_mouse_position())

	# Reduce the time remaining before another shot.
	_shot_cooldown = maxf(_shot_cooldown - delta, 0.0)

	# Hold the left mouse button to fire continuously.
	if Input.is_action_pressed("shoot") and _shot_cooldown <= 0.0:
		_shoot()


func _shoot() -> void:
	# Prevent shooting after death.
	if is_dead:
		return
	if projectile_scene == null:
		push_warning(
            "Assign a projectile scene to the Player in the Inspector."
		)
		return

	var projectile := projectile_scene.instantiate() as PlayerProjectile

	if projectile == null:
		push_error(
            "The assigned projectile scene must use the PlayerProjectile script."
		)
		return

	var direction: Vector2 = (
		get_global_mouse_position() - muzzle.global_position
	).normalized()

	if direction.is_zero_approx():
		return

	# Add the projectile as a sibling so it can move independently.
	get_parent().add_child(projectile)
	projectile.global_position = muzzle.global_position
	projectile.launch(direction)

	_shot_cooldown = 1.0 / shots_per_second

# Allows other nodes, such as enemies, to damage the player.
func take_player_damage(amount: int) -> void:
	if is_dead:
		return

	health_component.take_damage(amount)


# Handles the player's death.
func _on_player_died() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	print("Player died.")
	
	# Notify the game-over UI.
	died.emit()
