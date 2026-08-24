extends Spatial
# ============================================================
# Character.gd — 角色骨骼系统 v2.0
# 17 块骨骼 + 程序化网格 + 附件挂载 + 外部模型加载
# 兼容 Godot 3.5.x
# ============================================================

# 骨骼引用
var hips           # 0 - 骨盆
var spine          # 1 - 脊柱
var chest          # 2 - 胸部
var neck           # 3 - 脖子
var head           # 4 - 头
var upper_arm_l    # 5 - 左上臂
var forearm_l      # 6 - 左前臂
var hand_l         # 7 - 左手
var upper_arm_r    # 8 - 右上臂
var forearm_r      # 9 - 右前臂
var hand_r         # 10 - 右手
var thigh_l        # 11 - 左大腿
var shin_l         # 12 - 左小腿
var foot_l         # 13 - 左脚
var thigh_r        # 14 - 右大腿
var shin_r         # 15 - 右小腿
var foot_r         # 16 - 右脚

var bone_list = [] # 索引访问

var face_system      # FaceSystem 引用
var breast_gen       # BreastGenerator 引用
var genital_gen      # GenitalGenerator 引用

var _is_female = true
var _use_external_model = false
var external_model_root

func _ready():
	if not _use_external_model:
		_build_skeleton()
		_build_meshes()
		_build_attachments()

# ============ 骨骼构建 ============
func _build_skeleton():
	hips = _make_bone("hips", Vector3(0, 0.95, 0))
	spine = _make_bone("spine", Vector3(0, 0.22, 0))
	chest = _make_bone("chest", Vector3(0, 0.18, 0))
	neck = _make_bone("neck", Vector3(0, 0.12, 0))
	head = _make_bone("head", Vector3(0, 0.08, 0))
	
	upper_arm_l = _make_bone("upper_arm_l", Vector3(-0.12, 0.05, 0))
	forearm_l = _make_bone("forearm_l", Vector3(0, -0.20, 0))
	hand_l = _make_bone("hand_l", Vector3(0, -0.18, 0))
	upper_arm_r = _make_bone("upper_arm_r", Vector3(0.12, 0.05, 0))
	forearm_r = _make_bone("forearm_r", Vector3(0, -0.20, 0))
	hand_r = _make_bone("hand_r", Vector3(0, -0.18, 0))
	
	thigh_l = _make_bone("thigh_l", Vector3(-0.07, -0.10, 0))
	shin_l = _make_bone("shin_l", Vector3(0, -0.35, 0))
	foot_l = _make_bone("foot_l", Vector3(0, -0.30, 0.02))
	thigh_r = _make_bone("thigh_r", Vector3(0.07, -0.10, 0))
	shin_r = _make_bone("shin_r", Vector3(0, -0.35, 0))
	foot_r = _make_bone("foot_r", Vector3(0, -0.30, 0.02))
	
	# 构建父子层级
	_add_child(hips, self)
	_add_child(spine, hips)
	_add_child(chest, spine)
	_add_child(neck, chest)
	_add_child(head, neck)
	
	_add_child(upper_arm_l, chest)
	_add_child(forearm_l, upper_arm_l)
	_add_child(hand_l, forearm_l)
	_add_child(upper_arm_r, chest)
	_add_child(forearm_r, upper_arm_r)
	_add_child(hand_r, forearm_r)
	
	_add_child(thigh_l, hips)
	_add_child(shin_l, thigh_l)
	_add_child(foot_l, shin_l)
	_add_child(thigh_r, hips)
	_add_child(shin_r, thigh_r)
	_add_child(foot_r, shin_r)
	
	bone_list = [hips, spine, chest, neck, head,
		upper_arm_l, forearm_l, hand_l,
		upper_arm_r, forearm_r, hand_r,
		thigh_l, shin_l, foot_l,
		thigh_r, shin_r, foot_r]

func _make_bone(name, pos):
	var bone = Spatial.new()
	bone.name = name
	bone.translation = pos
	return bone

func _add_child(child, parent):
	parent.add_child(child)
	child.set_owner(get_tree().get_edited_scene_root() if get_tree() and get_tree().get_edited_scene_root() else self)

# ============ 程序化网格 ============
func _build_meshes():
	var skin_mat = SpatialMaterial.new()
	skin_mat.albedo_color = Color(1.0, 0.85, 0.72)
	skin_mat.roughness = 0.55
	skin_mat.metallic = 0.0
	
	# 躯干胶囊体
	_add_capsule(hips, 0.14, 0.12, skin_mat)
	_add_capsule(spine, 0.12, 0.10, skin_mat)
	_add_capsule(chest, 0.10, 0.11, skin_mat)
	
	# 头
	var head_mat = SpatialMaterial.new()
	head_mat.albedo_color = Color(1.0, 0.82, 0.70)
	head_mat.roughness = 0.4
	_add_sphere(head, 0.075, head_mat)
	
	# 四肢 (手臂)
	_add_capsule(upper_arm_l, 0.05, 0.20, skin_mat)
	_add_capsule(forearm_l, 0.04, 0.18, skin_mat)
	_add_capsule(upper_arm_r, 0.05, 0.20, skin_mat)
	_add_capsule(forearm_r, 0.04, 0.18, skin_mat)
	
	# 四肢 (腿)
	var leg_mat = SpatialMaterial.new()
	leg_mat.albedo_color = Color(1.0, 0.85, 0.72)
	leg_mat.roughness = 0.6
	_add_capsule(thigh_l, 0.07, 0.35, leg_mat)
	_add_capsule(shin_l, 0.055, 0.30, leg_mat)
	_add_capsule(thigh_r, 0.07, 0.35, leg_mat)
	_add_capsule(shin_r, 0.055, 0.30, leg_mat)
	
	# 脚
	var foot_mat = SpatialMaterial.new()
	foot_mat.albedo_color = Color(0.9, 0.75, 0.65)
	foot_mat.roughness = 0.8
	_add_capsule(foot_l, 0.03, 0.05, foot_mat)
	_add_capsule(foot_r, 0.03, 0.05, foot_mat)

func _add_capsule(parent, radius, mid_height, mat):
	var mi = MeshInstance.new()
	var cap = CapsuleMesh.new()
	cap.radius = radius
	cap.mid_height = mid_height
	cap.radial_segments = 10
	cap.rings = 6
	cap.material = mat
	mi.mesh = cap
	mi.translation = Vector3(0, -mid_height * 0.5 - radius, 0)
	parent.add_child(mi)

func _add_sphere(parent, radius, mat):
	var mi = MeshInstance.new()
	var sph = SphereMesh.new()
	sph.radius = radius
	sph.height = radius * 2
	sph.radial_segments = 14
	sph.rings = 10
	sph.material = mat
	mi.mesh = sph
	parent.add_child(mi)

# ============ 附件系统 ============
func _build_attachments():
	# 面部 - 挂在 head 下
	face_system = preload("FaceSystem.gd").new()
	head.add_child(face_system)
	face_system.translation = Vector3(0, 0.04, 0.08)
	
	if _is_female:
		# 胸部 - 挂在 chest 前侧
		breast_gen = preload("BreastGenerator.gd").new()
		chest.add_child(breast_gen)
		breast_gen.translation = Vector3(0, 0.01, 0.06)
	else:
		# 男性生殖器 - 挂在 hips 前侧
		genital_gen = preload("GenitalGenerator.gd").new()
		hips.add_child(genital_gen)

# ============ 外部模型加载 ============
func load_external_model(path, is_female := true):
	_is_female = is_female
	_use_external_model = true
	
	var scene = ResourceLoader.load(path)
	if scene == null:
		print("Failed to load model: ", path)
		_use_external_model = false
		_ready()
		return false
	
	external_model_root = scene.instance()
	add_child(external_model_root)
	
	# 尝试自动绑定骨骼引用
	_bind_external_skeleton(external_model_root)
	
	# 仍然附加面部/胸部等程序化附件
	_build_attachments()
	
	return true

func _bind_external_skeleton(root):
	var name_map = {
		"hips": "hips", "pelvis": "hips", "hip": "hips",
		"spine": "spine", "spine01": "spine", "spine1": "spine",
		"spine02": "chest", "spine2": "chest", "chest": "chest",
		"neck": "neck", "neck01": "neck", "neck1": "neck",
		"head": "head",
		"upperarm_l": "upper_arm_l", "upperarmleft": "upper_arm_l", "upper_arm_l": "upper_arm_l",
		"lowerarm_l": "forearm_l", "lowerarmleft": "forearm_l", "forearm_l": "forearm_l",
		"hand_l": "hand_l", "handleft": "hand_l",
		"upperarm_r": "upper_arm_r", "upperarmright": "upper_arm_r", "upper_arm_r": "upper_arm_r",
		"lowerarm_r": "forearm_r", "lowerarmright": "forearm_r", "forearm_r": "forearm_r",
		"hand_r": "hand_r", "handright": "hand_r",
		"thigh_l": "thigh_l", "thighleft": "thigh_l", "upleg_l": "thigh_l", "uplegleft": "thigh_l",
		"shin_l": "shin_l", "shinleft": "shin_l", "leg_l": "shin_l", "lowleg_l": "shin_l",
		"foot_l": "foot_l", "footleft": "foot_l",
		"thigh_r": "thigh_r", "thighright": "thigh_r", "upleg_r": "thigh_r",
		"shin_r": "shin_r", "shinright": "shin_r", "leg_r": "shin_r",
		"foot_r": "foot_r", "footright": "foot_r"
	}
	
	var all_bones = _find_all_spatials(root)
	hips = all_bones.get("hips")
	spine = all_bones.get("spine")
	chest = all_bones.get("chest")
	neck = all_bones.get("neck")
	head = all_bones.get("head")
	upper_arm_l = all_bones.get("upper_arm_l")
	forearm_l = all_bones.get("forearm_l")
	hand_l = all_bones.get("hand_l")
	upper_arm_r = all_bones.get("upper_arm_r")
	forearm_r = all_bones.get("forearm_r")
	hand_r = all_bones.get("hand_r")
	thigh_l = all_bones.get("thigh_l")
	shin_l = all_bones.get("shin_l")
	foot_l = all_bones.get("foot_l")
	thigh_r = all_bones.get("thigh_r")
	shin_r = all_bones.get("shin_r")
	foot_r = all_bones.get("foot_r")
	
	bone_list = [hips, spine, chest, neck, head,
		upper_arm_l, forearm_l, hand_l,
		upper_arm_r, forearm_r, hand_r,
		thigh_l, shin_l, foot_l,
		thigh_r, shin_r, foot_r]

func _find_all_spatials(node, map = {}):
	var name_lower = node.name.to_lower()
	for key in map_keys:
		if name_lower.find(key) >= 0:
			map[map_keys[key]] = node
			break
	for child in node.get_children():
		_find_all_spatials(child, map)
	return map

var map_keys = {
	"hips": "hips", "pelvis": "hips", "hip": "hips",
	"spine01": "spine", "spine1": "spine", "spine": "spine",
	"spine02": "chest", "spine2": "chest", "chest": "chest",
	"neck": "neck", "neck01": "neck",
	"head": "head",
	"upperarm_l": "upper_arm_l", "upperarmleft": "upper_arm_l", "upper_arm_l": "upper_arm_l",
	"lowerarm_l": "forearm_l", "lowerarmleft": "forearm_l", "forearm_l": "forearm_l",
	"hand_l": "hand_l", "handleft": "hand_l",
	"upperarm_r": "upper_arm_r", "upperarmright": "upper_arm_r", "upper_arm_r": "upper_arm_r",
	"lowerarm_r": "forearm_r", "lowerarmright": "forearm_r", "forearm_r": "forearm_r",
	"hand_r": "hand_r", "handright": "hand_r",
	"thigh_l": "thigh_l", "thighleft": "thigh_l", "upleg_l": "thigh_l",
	"shin_l": "shin_l", "shinleft": "shin_l", "leg_l": "shin_l",
	"foot_l": "foot_l", "footleft": "foot_l",
	"thigh_r": "thigh_r", "thighright": "thigh_r",
	"shin_r": "shin_r", "shinright": "shin_r",
	"foot_r": "foot_r", "footright": "foot_r"
}

func set_female(val):
	_is_female = val

func set_breast_size(val):
	if breast_gen and breast_gen.has_method("set_size"):
		breast_gen.set_size(val)

func set_emotion(emotion):
	if face_system and face_system.has_method("set_emotion"):
		face_system.set_emotion(emotion)

# 获取脚部世界位置(用于IK)
func get_foot_position(side):
	if side == 0: # 左
		return foot_l.global_transform.origin
	else:
		return foot_r.global_transform.origin

func get_hand_position(side):
	if side == 0:
		return hand_l.global_transform.origin
	else:
		return hand_r.global_transform.origin