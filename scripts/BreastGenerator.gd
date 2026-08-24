extends Spatial
class_name BreastGenerator
# ============================================================
# BreastGenerator.gd — 程序化女性胸部生成器 v1.0
# 挂在胸骨前部, 参数可调
# 兼容 Godot 3.5.x
# ============================================================

var left
var right
var size = 0.055  # 0.03~0.08

func _ready():
    _build()

func _build():
    var mat := SpatialMaterial.new()
    mat.albedo_color = Color(1.0, 0.85, 0.72)
    mat.roughness = 0.5
    mat.metallic = 0.05

    left = _make_breast(Vector3(-0.09, 0.0, 0.06), mat)
    right = _make_breast(Vector3(0.09, 0.0, 0.06), mat)
    add_child(left)
    add_child(right)

func _make_breast(pos: Vector3, mat: SpatialMaterial) -> MeshInstance:
    var mi := MeshInstance.new()
    var sph := SphereMesh.new()
    sph.radius = size
    sph.height = size * 1.8
    sph.radial_segments = 16
    sph.rings = 12
    sph.material = mat
    mi.mesh = sph
    mi.translation = pos
    mi.scale = Vector3(1.0, 0.85, 0.55)
    return mi

func set_size(v: float) -> void:
    size = 0.03 + v * 0.05
    if left and right:
        left.scale = Vector3(1.0, 0.85, 0.55) * (size / 0.055)
        right.scale = Vector3(1.0, 0.85, 0.55) * (size / 0.055)