extends KinematicBody


# Declare member variables here. Examples:
var velocity = Vector3(0,0,0)
var direction = Vector3(0,0,0)
var mouse_axis := Vector2()
var mouse_sensitivity = 12.0
var acceleration = 5;
var gravity = 30;
var max_slope_angle = 89;
var on_floor = false;
var on_wall = false;
var floor_normal = Vector3(0,1,0);
var collision_normal = Vector3(0,1,0);
onready var head: Spatial = $Head
onready var cam: Camera = $Head/Camera
var floor_direction = Vector3(0,0,0)
var use_slide = false;
var speed = 15


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
	if (on_floor):
		velocity = velocity.linear_interpolate(direction, acceleration * delta)
	else:
		velocity = velocity.linear_interpolate(direction, (1) * delta)
	velocity.y = tempVel
	
	#move_and_collide(velocity*delta, false, false)
	# SNAP CODE on floor?
	var col2 = move_and_collide(-floor_normal*delta, false, false, true) #must scale movement vector strange bug.
	var col = move_and_collide(velocity.normalized()*delta, false, false, true)
	
	if col2:
		#print(rad2deg(Vector3(0,1,0).angle_to(col2.normal)))
		if (rad2deg(Vector3(0,1,0).angle_to(col2.normal)) <= max_slope_angle):
			
			floor_direction = velocity
			floor_normal = col2.normal
			on_floor = true;
			velocity.y = (-1/floor_normal.y) * ((velocity.x * floor_normal.x) + (velocity.z * floor_normal.z))
			
			get_node("../Label").text = "on_floor"
			on_wall = false;
		else:
			
			on_floor = false;
			get_node("../Label").text = "on_wall"
			on_wall = true;
			
		collision_normal = col2.normal;
	else:
		
		on_floor = false;
		get_node("../Label").text = "in_air"
		on_wall = false;
	if col:
		collision_normal = col.normal;
		if (rad2deg(Vector3(0,1,0).angle_to(col.normal)) <= max_slope_angle):
			#move_and_collide(velocity*delta, false, false)
			floor_normal = col.normal
			floor_direction = velocity
			on_floor = true;
			get_node("../Label").text = "on_floor"
			on_wall = false;
			velocity.y = (-1/floor_normal.y) * ((velocity.x * floor_normal.x) + (velocity.z * floor_normal.z))
			
		else:
			get_node("../Label").text = "on_wall"
			on_wall = true;
			on_floor = false;
			if col2:
				print(rad2deg(Vector3(0,1,0).angle_to(col2.normal)))
				if (rad2deg(Vector3(0,1,0).angle_to(col2.normal)) <= max_slope_angle):
					on_floor = true;
			
	get_node("../RayCast").translation = translation;
	#get_node("../RayCast").translation.y = get_node("../RayCast").translation.y - 1.5;
	get_node("../RayCast").cast_to = velocity.normalized()#-floor_normal*(Vector3(0,1,0).angle_to(floor_normal)/5+0.001)
	get_node("../RayCast2").translation = translation;
	#get_node("../RayCast").translation.y = get_node("../RayCast").translation.y - 1.5;
	get_node("../RayCast2").cast_to = -floor_normal
	
	
	if (!on_floor):
		#get_node("../Label").text = "not_on_floor"
		if (on_wall): 
			if Input.is_action_just_pressed("jump"):
				velocity = Vector3(0,1,0) + (collision_normal*12);
		
		velocity.y -= gravity * delta;
		floor_direction = Vector3(0,0,0)
		floor_normal = Vector3(0,1,0)
		
	else:
		#get_node("../Label").text = "on_floor"
		if Input.is_action_just_pressed("jump"):
			velocity.y = 12
			floor_normal = Vector3(0,1,0)
	
		
	
	#print(Vector3(velocity.x,0,velocity.z).length(), "  ", on_floor, "  " , velocity)
	#print(on_wall)
	
	if (on_wall):
		velocity = move_and_slide(velocity)
		
	else:
		#velocity = move_and_slide_with_snap(velocity, -floor_normal/5)
		move_and_collide(velocity*delta, false, false)
