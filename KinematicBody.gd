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
var col
var col2
var relevant_collision
var impulse_velocity = Vector3(0,0,0)
var previous_floor_normal = Vector3(0,1,0)
# Called when the node enters the scene tree for the first time.
func _ready():

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
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
	
	# MAYBE USE PREVIOUS COLLISION TO SEE IF YOU SHOULD SNAP. SOMETHING LIKE IF JUMP KEY NOT PRESSED AND PREVIOUS COLLISION WAS ON FLOOR, THEN SNAP.
	
	if !col:
		col = move_and_collide(velocity*delta, false, false, true)
	
	
	if col:
		collision_normal = col.normal;
		if (rad2deg(Vector3(0,1,0).angle_to(col.normal)) <= max_slope_angle):
			
			relevant_collision = col
			#move_and_collide(velocity*delta, false, false)
			floor_normal = col.normal
			floor_direction = velocity
			on_floor = true;
			
			on_wall = false;
			
			#velocity.y = (-1/floor_normal.y) * ((velocity.x * floor_normal.x) + (velocity.z * floor_normal.z))
			
			
			
		else:
			
			on_wall = true;
			on_floor = false;
			if col2:
				
				if (rad2deg(Vector3(0,1,0).angle_to(col2.normal)) <= max_slope_angle):
					on_floor = true;
			
	
	
	get_node("../RayCast").translation = translation;
	#get_node("../RayCast").translation.y = get_node("../RayCast").translation.y - 1.5;
	get_node("../RayCast").cast_to = velocity.normalized()#-floor_normal*(Vector3(0,1,0).angle_to(floor_normal)/5+0.001)
	get_node("../RayCast2").translation = translation;
	#get_node("../RayCast").translation.y = get_node("../RayCast").translation.y - 1.5;
	get_node("../RayCast2").cast_to = -floor_normal
	
	
	
		
	
	var gt = get_global_transform();
	
	var snap = move_and_collide(-floor_normal*((Vector3(0,1,0).angle_to(floor_normal))*5+1), false, false, true)
	if (snap):
		if (rad2deg(Vector3(0,1,0).angle_to(snap.normal)) <= max_slope_angle):
			if(impulse_velocity == Vector3.ZERO):
				gt.origin += snap.travel;
				set_global_transform(gt);
				velocity.y = (-1/previous_floor_normal.y) * ((velocity.x * floor_normal.x) + (velocity.z * floor_normal.z))
				
				
	var floor_check = move_and_collide(-floor_normal*delta, false, false, true)
	if (floor_check):
		if (rad2deg(Vector3(0,1,0).angle_to(floor_check.normal)) <= max_slope_angle):
			impulse_velocity = Vector3(0,0,0)
			on_floor = true
			floor_normal = floor_check.normal
			
			if Input.is_action_just_pressed("jump"):
				if (on_wall):
					impulse_velocity = Vector3(0,1,0) + (collision_normal*12);
					velocity = Vector3(0,1,0) + (collision_normal*12);
				else: 
					impulse_velocity.y = 12
					velocity.y = 12
					floor_normal = Vector3(0,1,0)
	else:
		if col:
			if (rad2deg(Vector3(0,1,0).angle_to(col.normal)) <= max_slope_angle):
				
				on_floor = true
				floor_normal = col.normal
				
				#get_node("../Label").text = "on_floor"
		else:
			on_floor = false
			floor_normal = Vector3(0,1,0)
			velocity.y -= gravity * delta;
			#get_node("../Label").text = "on_floor"
	
	print(impulse_velocity)
	
	get_node("../RayCast2").cast_to = -floor_normal
	
	if (on_floor):
		if (on_wall):
			get_node("../Label").text = "on_wall"
		else:
			get_node("../Label").text = "on_floor"
	else:
		get_node("../Label").text = "in_air"
	#print(Vector3(velocity.x,0,velocity.z).length(), "  ", on_floor, "  " , velocity)
	#print(on_wall)
	
	col = null
	
	if (on_wall || !on_floor):
		velocity = move_and_slide(velocity)
		
	else:
		#velocity = move_and_slide_with_snap(velocity, -floor_normal/5)
		col = move_and_collide(velocity*delta, false, false)
	
	previous_floor_normal = floor_normal
