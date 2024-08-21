@tool
extends CSGBox3D

@export var apply: bool:
	set(value):
		if value:
			on_apply()

var terrain: Terrain3D


func _init(terrain_3d: Terrain3D = null) -> void:
	if terrain_3d == null: # Removes the node if the scene is reloaded
		queue_free()
		return

	terrain = terrain_3d
	var root = terrain.get_tree().edited_scene_root

	name = "TerrainFromMeshesConfig"
	flip_faces = true
	size = Vector3.ONE * 50

	root.add_child(self)
	owner = root

	EditorInterface.edit_node(self)


func on_apply() -> void:
	# TODO: Prompt user with a confirm or cancel dialog for this action
	#var dialog = ConfirmationDialog.new() 
	#dialog.confirmed.connect(run_apply)

	run_apply()


func run_apply() -> void:
	var root: Node = get_tree().edited_scene_root

	var raycast = RayCast3D.new()
	raycast.collide_with_bodies = true
	raycast.collide_with_areas = true
	root.add_child(raycast)
	raycast.owner = root

	var aabb: AABB = get_aabb()
	print(aabb)

	for x in range(aabb.size.x):
		for z in range(aabb.size.z):
			var pos_x = aabb.position.x + x
			var pos_z = aabb.position.z + z

			raycast.position = Vector3(pos_x, aabb.end.y, pos_z) + position
			raycast.target_position = Vector3.DOWN * aabb.end.y
			raycast.force_raycast_update()

			var hit_position = raycast.get_collision_point()
			if hit_position.y != 0:
				terrain.storage.set_height(hit_position, hit_position.y)

	terrain.storage.save()
	terrain.storage.force_update_maps()
