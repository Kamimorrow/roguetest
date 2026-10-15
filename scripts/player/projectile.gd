class_name PlayerProjectile
extends Area2D

@export var speed: float = 650.0
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT
var _remaining_lifetime: float = 0.0


func _ready() -> void:
	_remaining_lifetime = lifetime
	body_entered.connect(_on_body_entered)
	queue_redraw()


func launch(firing_direction: Vector2) -> void:
	direction = firing_direction.normalized()
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

	_remaining_lifetime -= delta

	if _remaining_lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	#print("Hit node: ", body.name)
	#print("Node type: ", body.get_class())
	#print("Node script: ", body.get_script())

	if body.has_method("take_damage"):
		body.take_damage(10)

	queue_free()


func _draw() -> void:
	# Temporary visual until we create projectile sprites.
	draw_circle(Vector2.ZERO, 3.0, Color("#FFF1B8"))
