extends CharacterBody2D

signal died

@export var max_health: int = 30
# Configure damage dealt when the player touches this enemy.
@export var contact_damage: int = 10
@export_range(0.1, 10.0, 0.1) var contact_damage_interval: float = 1.0

# Reference the area used to detect the player.
@onready var contact_area: Area2D = $ContactArea

# Track the player and time until the next contact hit.
var player_in_contact: Node2D = null
var contact_cooldown: float = 0.0

var current_health: int


func _ready() -> void:
	current_health = max_health
	#print("Enemy ready. Health: ", current_health)
	
	# Detect when a physics body enters or leaves contact range.
	contact_area.body_entered.connect(_on_contact_area_body_entered)
	contact_area.body_exited.connect(_on_contact_area_body_exited)

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return

	current_health -= amount
	print("Enemy health: ", current_health)

	if current_health <= 0:
		died.emit()
		queue_free()

# Apply repeated contact damage while the player remains in range.
func _physics_process(delta: float) -> void:
	if player_in_contact == null:
		return

	contact_cooldown -= delta

	if contact_cooldown <= 0.0:
		if player_in_contact.has_method("take_player_damage"):
			player_in_contact.take_player_damage(contact_damage)

		contact_cooldown = contact_damage_interval


# Damage the player immediately when they enter contact range.
func _on_contact_area_body_entered(body: Node2D) -> void:
	if not body.has_method("take_player_damage"):
		return

	player_in_contact = body
	player_in_contact.take_player_damage(contact_damage)
	contact_cooldown = contact_damage_interval


# Stop applying contact damage when the player leaves the area.
func _on_contact_area_body_exited(body: Node2D) -> void:
	if body == player_in_contact:
		player_in_contact = null
		contact_cooldown = 0.0
