extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01

@onready var camera := $"../Camera3D"
@onready var body := $".."


#func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
#func _unhandled_input(event: InputEvent) -> void:
	#if	event is InputEventMouseMotion:
		#neck.rotate_y(-event.relative.x * SENSITIVITY )	
		#camera.rotate_x(-event.relative.y * SENSITIVITY )
		#camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60),deg_to_rad(90))
	
func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	
	# Convierte la posición del mouse a un rayo en el espacio 3D
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_direction = camera.project_ray_normal(mouse_position) * 1000.0
	
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * 1000  # proyecta el rayo hacia "adelante"

	# Calcula la intersección con un plano horizontal (ej: el suelo a y=0)
	var plane = Plane(Vector3.UP, global_transform.origin.y)  # plano en la altura actual del personaje

	var intersection = plane.intersects_ray(ray_origin, ray_direction)


	if intersection != null:
		look_at(Vector3(intersection.x, global_transform.origin.y, intersection.z), Vector3.UP)
	
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	
	var direction = (body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	camera.transform.origin.x = transform.origin.x
	camera.transform.origin.z = transform.origin.z
	
	move_and_slide()
