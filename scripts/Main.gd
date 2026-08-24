extends Spatial
# ============================================================
# Main.gd — 主场景控制器 v2.0
# 双角色 + IK贴合 + 姿势切换 + 动作驱动 + 模型加载
# 兼容 Godot 3.5.x
# ============================================================

const Character = preload("Character.gd")
const MotionEngine = preload("MotionEngine.gd")
const IKSystem = preload("IK.gd")
const PoseSystem = preload("PoseSystem.gd")

var character_a        # 男
var character_b        # 女
var motion_engine_a
var motion_engine_b

# IK 目标标记
var ik_target_l
var ik_target_r
var ik_pole_l
var ik_pole_r

# 控制参数
var speed = 0.5
var intensity = 0.5
var lean = 0.3
var ik_weight = 0.8
var current_pose = PoseSystem.Pose.MISSIONARY

# 相机
var cam
var cam_pivot

func _ready():
	_build_environment()
	_build_characters()
	_build_ik_system()
	_build_ui()
	
	# 初始姿势
	_apply_pose(current_pose)
	
	print("AdultGame3D v2.0 ready — ", PoseSystem.get_pose_name(current_pose))

func _process(delta):
	# 驱动角色动作
	var pose_data = PoseSystem.get_pose_data(current_pose)
	motion_engine_a.drive(character_a, speed, intensity, lean, pose_data)
	motion_engine_b.drive(character_b, speed, intensity * 0.7, -lean * 0.5, pose_data)
	
	# 运行IK贴合
	_run_ik(delta)
	
	# 更新相机跟随
	_update_camera()

# ============ 环境 ============
func _build_environment():
	# 地板
	var floor_mi = MeshInstance.new()
	var floor_mesh = PlaneMesh.new()
	floor_mesh.size = Vector2(6, 6)
	var floor_mat = SpatialMaterial.new()
	floor_mat.albedo_color = Color(0.3, 0.3, 0.35)
	floor_mat.roughness = 0.9
	floor_mesh.material = floor_mat
	floor_mi.mesh = floor_mesh
	floor_mi.rotation_degrees.x = -90
	floor_mi.translation.y = 0.0
	add_child(floor_mi)
	
	# 灯光
	var light = DirectionalLight.new()
	light.translation = Vector3(4, 6, 3)
	light.look_at(Vector3(0, 0.95, 0), Vector3(0, 1, 0))
	light.light_color = Color(1.0, 0.95, 0.9)
	light.light_energy = 1.2
	add_child(light)
	
	# 补光
	var fill = DirectionalLight.new()
	fill.translation = Vector3(-3, 4, -2)
	fill.look_at(Vector3(0, 0.95, 0), Vector3(0, 1, 0))
	fill.light_color = Color(0.7, 0.75, 0.9)
	fill.light_energy = 0.5
	add_child(fill)
	
	# 相机枢轴
	cam_pivot = Spatial.new()
	cam_pivot.translation = Vector3(0, 0.95, 0)
	add_child(cam_pivot)
	
	# 相机
	cam = Camera.new()
	cam.translation = Vector3(0, 0.5, 1.8)
	cam.look_at(Vector3(0, 0.95, 0), Vector3(0, 1, 0))
	cam_pivot.add_child(cam)

func _update_camera():
	# 相机跟随角色A
	if character_a and character_a.hips:
		var hips_pos = character_a.hips.global_transform.origin
		cam_pivot.global_transform.origin = cam_pivot.global_transform.origin.linear_interpolate(
			hips_pos, 0.05
		)

# ============ 角色构建 ============
func _build_characters():
	# 角色A (男)
	character_a = Character.new()
	character_a.set_female(false)
	character_a.translation = Vector3(0, 0, 0)
	add_child(character_a)
	
	# 角色B (女)
	character_b = Character.new()
	character_b.set_female(true)
	character_b.translation = Vector3(0, 0, -0.15)
	add_child(character_b)
	
	# 动作引擎
	motion_engine_a = MotionEngine.new()
	add_child(motion_engine_a)
	motion_engine_b = MotionEngine.new()
	add_child(motion_engine_b)

# ============ IK 系统 ============
func _build_ik_system():
	# IK 目标标记 (Spatial 节点)
	ik_target_l = Spatial.new()
	ik_target_l.name = "IK_Target_L"
	add_child(ik_target_l)
	
	ik_target_r = Spatial.new()
	ik_target_r.name = "IK_Target_R"
	add_child(ik_target_r)
	
	ik_pole_l = Spatial.new()
	ik_pole_l.name = "IK_Pole_L"
	add_child(ik_pole_l)
	
	ik_pole_r = Spatial.new()
	ik_pole_r.name = "IK_Pole_R"
	add_child(ik_pole_r)

func _run_ik(delta):
	if character_a == null or character_b == null:
		return
	
	var pose_data = PoseSystem.get_pose_data(current_pose)
	var spread = pose_data.get("ik_spread", 0.12)
	var forward = pose_data.get("ik_forward", 0.25)
	var leg_angle = pose_data.get("ik_leg_angle", 25)
	
	# 角色B腿部IK贴合到角色A
	# 角色B双脚目标: 在角色A臀部两侧
	var a_hips = character_a.hips
	if a_hips == null:
		return
	
	var a_hips_pos = a_hips.global_transform.origin
	
	# 左腿目标
	var target_l = a_hips_pos + Vector3(-spread, -0.15, forward)
	ik_target_l.global_transform.origin = ik_target_l.global_transform.origin.linear_interpolate(target_l, 0.1)
	
	# 右腿目标
	var target_r = a_hips_pos + Vector3(spread, -0.15, forward)
	ik_target_r.global_transform.origin = ik_target_r.global_transform.origin.linear_interpolate(target_r, 0.1)
	
	# 极点(膝盖方向)
	var pole_center = a_hips_pos + Vector3(0, -0.05, forward * 0.5 - 0.1)
	ik_pole_l.global_transform.origin = pole_center + Vector3(-0.2, 0, 0)
	ik_pole_r.global_transform.origin = pole_center + Vector3(0.2, 0, 0)
	
	# 执行IK (角色B的腿)
	if character_b.thigh_l and character_b.shin_l and character_b.foot_l:
		IKSystem.solve_chain(
			character_b.thigh_l, character_b.shin_l, character_b.foot_l,
			ik_target_l.global_transform.origin,
			ik_pole_l.global_transform.origin,
			ik_weight
		)
	
	if character_b.thigh_r and character_b.shin_r and character_b.foot_r:
		IKSystem.solve_chain(
			character_b.thigh_r, character_b.shin_r, character_b.foot_r,
			ik_target_r.global_transform.origin,
			ik_pole_r.global_transform.origin,
			ik_weight
		)

# ============ 姿势系统 ============
func _apply_pose(pose):
	current_pose = pose
	var data = PoseSystem.get_pose_data(pose)
	
	# 角色A位置
	character_a.translation = data["pos_a"]
	character_a.rotation_degrees = data["rot_a"]
	
	# 角色B位置(相对角色A)
	var pos_a = data["pos_a"]
	var rot_b = data["rot_b"]
	var pos_b_offset = data["pos_b"]
	character_b.translation = pos_a + pos_b_offset
	character_b.rotation_degrees = rot_b
	
	# 更新动作引擎姿势
	motion_engine_a.set_pose(pose)
	motion_engine_b.set_pose(pose)
	motion_engine_a.reset()
	motion_engine_b.reset()
	
	print("Pose: ", PoseSystem.get_pose_name(pose))

func set_pose(pose):
	_apply_pose(pose)

# ============ 外部模型加载 ============
func load_female_model(path):
	return character_b.load_external_model(path, true)

func load_male_model(path):
	return character_a.load_external_model(path, false)

# ============ UI 控制接口 ============
func set_speed(val):
	speed = clamp(val, 0.0, 1.0)

func set_intensity(val):
	intensity = clamp(val, 0.0, 1.0)

func set_lean(val):
	lean = clamp(val, 0.0, 1.0)

func set_ik_weight(val):
	ik_weight = clamp(val, 0.0, 1.0)

func set_posture(mode):
	motion_engine_a.set_mode(mode)
	motion_engine_b.set_mode(mode)

func set_emotion(emotion):
	character_b.set_emotion(emotion)

func set_breast_size(val):
	character_b.set_breast_size(val)

# ============ UI 构建 (委托给 UI.gd) ============
func _build_ui():
	var ui = preload("UI.gd").new()
	ui.main = self
	add_child(ui)