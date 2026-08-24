extends Spatial
class_name GenitalGenerator
# ============================================================
# GenitalGenerator.gd — 程序化男性生殖器生成器 v1.0
# 纯代码构建几何网格(圆柱+头部), 挂在骨盆骨骼下
# 用于成人游戏角色模型 — 零外部素材, 无版权问题
# 兼容 Godot 3.5.x
# ============================================================

# 参数
export var shaft_length: float = 0.14     # 柱体长度
export var shaft_radius: float = 0.022    # 柱体半径
export var head_radius: float = 0.028     # 头部半径
export var testicle_radius: float = 0.025 # 睾丸半径
export var color: Color = Color(0.85, 0.62, 0.52)

var shaft_mesh: MeshInstance
var head_mesh: MeshInstance
var testicle_l: MeshInstance
var testicle_r: MeshInstance

func _ready():
    _build()

func _build():
    # 柱体 (CylinderMesh, 沿Y轴)
    shaft_mesh = MeshInstance.new()
    var cyl := CylinderMesh.new()
    cyl.top_radius = shaft_radius * 0.92
    cyl.bottom_radius = shaft_radius
    cyl.height = shaft_length
    cyl.radial_segments = 16
    var mat := SpatialMaterial.new()
    mat.albedo_color = color
    mat.roughness = 0.4
    mat.metallic = 0.1
    cyl.material = mat
    shaft_mesh.mesh = cyl
    # 挂到骨盆前下方
    shaft_mesh.translation = Vector3(0, -shaft_length * 0.5 - 0.02, 0.06)
    add_child(shaft_mesh)

    # 龟头 (SphereMesh, 压扁)
    head_mesh = MeshInstance.new()
    var sph := SphereMesh.new()
    sph.radius = head_radius
    sph.height = head_radius * 1.6
    sph.radial_segments = 16
    sph.rings = 10
    var hmat := SpatialMaterial.new()
    hmat.albedo_color = color.lightened(0.12)
    hmat.roughness = 0.35
    hmat.metallic = 0.1
    sph.material = hmat
    head_mesh.mesh = sph
    head_mesh.translation = Vector3(0, -shaft_length - 0.02, 0.06)
    add_child(head_mesh)

    # 睾丸 x2
    testicle_l = _make_testicle(Vector3(-0.028, -0.045, 0.055))
    testicle_r = _make_testicle(Vector3(0.028, -0.045, 0.055))
    add_child(testicle_l)
    add_child(testicle_r)

func _make_testicle(pos: Vector3) -> MeshInstance:
    var mi := MeshInstance.new()
    var sph := SphereMesh.new()
    sph.radius = testicle_radius
    sph.height = testicle_radius * 2.0
    sph.radial_segments = 14
    sph.rings = 8
    var mat := SpatialMaterial.new()
    mat.albedo_color = color.darkened(0.08)
    mat.roughness = 0.5
    sph.material = mat
    mi.mesh = sph
    mi.translation = pos
    return mi