extends KinematicBody


# Declare member variables here. Examples:
var velocity = Vector3(0,0,0)
var direction = Vector3(0,0,0)
var mouse_axis := Vector2()
var mouse_sensitivity = 12.0
var acceleration = 5;
var gravity = 0.2;
var max_slope_angle = 89;
var collision_normal = Vector3(0,1,0);
onready var head: Spatial = $Head
onready var cam: Camera = $Head/Camera

var speed = 0.1


# Called when the node enters the scene tree for the first time.
func _ready():

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	print(direction)
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		#get_tree().quit() # Quits the game
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("mouse_input"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
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
	#if (Vector3(velocity.x,0,velocity.z).length() > direction.length())
	#	velocity.x
	velocity.y = tempVel
	
	#print(Vector3(0,1,0).angle_to(Vector3(0.5,0.5,0)))
	var col = move_and_collide(velocity, false, false)
	print(Vector3(velocity.x,0,velocity.z).length(), "  ", velocity)
	
	if col:
		if (rad2deg(Vector3(0,1,0).angle_to(col.normal)) <= max_slope_angle):
			collision_normal = col.normal
		
		
	var col2 = move_and_collide(Vector3.DOWN*3, false, false, true)
	if col2:
		
		if (rad2deg(Vector3(0,1,0).angle_to(col2.normal)) <= max_slope_angle):
			collision_normal = col2.normal
			velocity.y = (-1/collision_normal.y) * ((velocity.x * collision_normal.x)+(velocity.z * collision_normal.z))
		
	else:
		
		velocity.y -= gravity * delta;
