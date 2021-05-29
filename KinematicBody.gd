extends KinematicBody


# Declare member variables here. Examples:
var velocity = Vector3(0,0,0)
var direction = Vector3(0,0,0)
var mouse_axis := Vector2()
var mouse_sensitivity = 12.0
var acceleration = 4;
onready var head: Spatial = $Head
onready var cam: Camera = $Head/Camera

var speed = 0.03


# Called when the node enters the scene tree for the first time.
func _ready():

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	print(direction)
	pass
	
func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		mouse_axis = event.relative

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		
		
		if mouse_axis.length() > 0:
			var horizontal: float = -mouse_axis.x * (mouse_sensitivity / 100)
			var vertical: float = -mouse_axis.y * (mouse_sensitivity / 100)
			
			mouse_axis = Vector2(0,0)
			
			rotate_y(deg2rad(horizontal))
			$Head.rotate_z(deg2rad(vertical))
			
			# Clamp mouse rotation
			var temp_rot: Vector3 = $Head.rotation_degrees
			temp_rot.z = clamp(temp_rot.z, -90, 90)
			head.rotation_degrees = temp_rot
	
	var basis = get_global_transform().basis
	direction = Vector3(0,0,0)
	if Input.is_action_pressed("move_forward"):
		direction += basis.x;
	if Input.is_action_pressed("move_backward"):
		direction -= basis.x;
	if Input.is_action_pressed("move_left"):
		direction -= basis.z;
	if Input.is_action_pressed("move_right"):
		direction += basis.z;
	
	
	direction = direction.normalized() * speed
	
	
	var tempVel = velocity.y
	velocity = velocity.linear_interpolate(direction, acceleration * delta)
	velocity.y = tempVel
	
	#print(Vector3(0,1,0).angle_to(Vector3(0.5,0.5,0)))
	var col = move_and_collide(velocity, false, false)
	print(velocity)
	if col:
		velocity.y = sin(Vector3(0,1,0).angle_to(col.normal)) * ((1/(cos(Vector3(0,1,0).angle_to(col.normal))) * Vector3(velocity.x,0,velocity.z).length()))
		
