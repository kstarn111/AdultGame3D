extends Spatial
class_name FaceSystem
# ============================================================
# FaceSystem.gd — 程序化面部 + 表情系统 v1.0
# 代码生成眼睛/眉毛/嘴, 通过参数驱动表情
# 表情: 中性/开心/难过/兴奋/痛苦 (0~4)
# 兼容 Godot 3.5.x
# ============================================================

enum Emotion { NEUTRAL, HAPPY, SAD, EXCITED, PAIN }

# 五官节点
var eye_l_white
var eye_r_white
var eye_l_pupil
var eye_r_pupil
var brow_l
var brow_r
var mouth

# 表情参数 (0~1)
var open_eyes = 1.0    # 1=全睁 0=闭眼
var mouth_open = 0.0   # 0=闭嘴 1=张大
var brow_frown = 0.0   # 皱眉程度
var brow_raise = 0.0   # 扬眉程度

var _target_emotion = 0

func _ready():
    _build_face()

func _build_face():
    eye_l_white = _eye_mesh(Color(1, 1, 1), Vector3(-0.045, 0.02, 0.09), 0.02)
    eye_r_white = _eye_mesh(Color(1, 1, 1), Vector3(0.045, 0.02, 0.09), 0.02)
    eye_l_pupil = _pupil_mesh(Vector3(-0.045, 0.02, 0.11))
    eye_r_pupil = _pupil_mesh(Vector3(0.045, 0.02, 0.11))
    brow_l = _brow_mesh(Vector3(-0.05, 0.055, 0.095))
    brow_r = _brow_mesh(Vector3(0.05, 0.055, 0.095))
    # 先 add_child 再设置旋转 (Godot 3.5 需要在树内才能安全设 rotation)
    add_child(eye_l_white); add_child(eye_r_white)
    add_child(eye_l_pupil); add_child(eye_r_pupil)
    add_child(brow_l); add_child(brow_r)
    brow_l.rotation_degrees.z = 6.0
    brow_r.rotation_degrees.z = -6.0
    mouth = _mouth_mesh(Vector3(0, -0.045, 0.095))
    add_child(mouth)

func set_emotion(emotion):
    _target_emotion = emotion
    match emotion:
        Emotion.NEUTRAL:
            open_eyes = 1.0
            mouth_open = 0.05
            brow_raise = 0.0
            brow_frown = 0.0
        Emotion.HAPPY:
            open_eyes = 0.9
            mouth_open = 0.35
            brow_raise = 0.4
            brow_frown = 0.0
            brow_l.rotation_degrees.z = -4.0
            brow_r.rotation_degrees.z = 4.0
        Emotion.SAD:
            open_eyes = 0.7
            mouth_open = 0.1
            brow_raise = 0.2
            brow_frown = 0.6
            brow_l.rotation_degrees.z = 14.0
            brow_r.rotation_degrees.z = -14.0
        Emotion.EXCITED:
            open_eyes = 1.0
            mouth_open = 0.55
            brow_raise = 0.8
            brow_frown = 0.0
        Emotion.PAIN:
            open_eyes = 0.6
            mouth_open = 0.75
            brow_raise = 0.1
            brow_frown = 0.9
            brow_l.rotation_degrees.z = 18.0
            brow_r.rotation_degrees.z = -18.0
    _apply()

func _apply():
    eye_l_white.scale.y = max(open_eyes, 0.1)
    eye_r_white.scale.y = max(open_eyes, 0.1)
    eye_l_pupil.scale.y = max(open_eyes * 0.9, 0.08)
    eye_r_pupil.scale.y = max(open_eyes * 0.9, 0.08)
    mouth.scale.y = 0.4 + mouth_open * 1.2
    mouth.translation.y = -0.045 - mouth_open * 0.015
    brow_l.translation.y = 0.055 + brow_raise * 0.01
    brow_r.translation.y = 0.055 + brow_raise * 0.01

func blink():
    open_eyes = 0.1
    _apply()

func _eye_mesh(color, pos, radius):
    var mi = MeshInstance.new()
    var sph = SphereMesh.new()
    sph.radius = radius
    sph.height = radius * 2
    sph.radial_segments = 12
    sph.rings = 8
    var mat = SpatialMaterial.new()
    mat.albedo_color = color
    mat.roughness = 0.2
    sph.material = mat
    mi.mesh = sph
    mi.translation = pos
    return mi

func _pupil_mesh(pos):
    var mi = MeshInstance.new()
    var sph = SphereMesh.new()
    sph.radius = 0.009
    sph.height = 0.018
    sph.radial_segments = 8
    sph.rings = 6
    var mat = SpatialMaterial.new()
    mat.albedo_color = Color(0.05, 0.05, 0.08)
    mat.roughness = 0.1
    sph.material = mat
    mi.mesh = sph
    mi.translation = pos
    return mi

func _brow_mesh(pos):
    var mi = MeshInstance.new()
    var cyl = CylinderMesh.new()
    cyl.top_radius = 0.004
    cyl.bottom_radius = 0.004
    cyl.height = 0.03
    cyl.radial_segments = 6
    var mat = SpatialMaterial.new()
    mat.albedo_color = Color(0.15, 0.1, 0.08)
    mat.roughness = 0.8
    cyl.material = mat
    mi.mesh = cyl
    mi.translation = pos
    return mi

func _mouth_mesh(pos):
    var mi = MeshInstance.new()
    var sph = SphereMesh.new()
    sph.radius = 0.017
    sph.height = 0.03
    sph.radial_segments = 12
    sph.rings = 8
    var mat = SpatialMaterial.new()
    mat.albedo_color = Color(0.4, 0.15, 0.15)
    mat.roughness = 0.3
    sph.material = mat
    mi.mesh = sph
    mi.translation = pos
    return mi