extends Node
class_name IKSystem
# ============================================================
# IK.gd — Two-Bone IK 解算器 v1.0
# 标准两段骨反向运动学: 求解 elbow 旋转使末端到达目标点
# 用于角色四肢贴合(手臂/腿) — 双角色动作贴合核心
# 兼容 Godot 3.5.x
# ============================================================

# 解算一条两段骨链
# a: 根骨(上臂/大腿)  b: 中骨(下臂/小腿)  c: 末端(手/脚)
# target: 世界坐标目标点  pole: 肘/膝方向参考点(世界)
# weight: 0~1 贴合权重(用于平滑进入/退出)
static func solve_chain(a, b, c, target, pole, weight):
    if weight <= 0.001:
        return

    var root_pos = a.global_transform.origin
    var mid_pos = b.global_transform.origin
    var end_pos = c.global_transform.origin

    # 平滑插值目标
    var desired_end = root_pos.linear_interpolate(target, weight)
    var desired_mid = root_pos.linear_interpolate(mid_pos, weight)

    var len_ab = root_pos.distance_to(mid_pos)
    var len_bc = mid_pos.distance_to(end_pos)

    if len_ab < 0.0001 or len_bc < 0.0001:
        return

    var to_target = desired_end - root_pos
    var dist = to_target.length()
    if dist < 0.0001:
        return

    # 余弦定理求 b 处角度
    var cos_b = clamp((len_ab * len_ab + len_bc * len_bc - dist * dist) / (2.0 * len_ab * len_bc), -1.0, 1.0)
    var angle_b = acos(cos_b)

    # 求 a 的俯仰: 指向 target 的旋转 + 添加弯曲角
    var forward_dir = to_target / dist
    var up_hint = pole - root_pos
    if up_hint.length() < 0.0001:
        up_hint = Vector3(0, 1, 0)
    up_hint = up_hint.normalized()

    var side = forward_dir.cross(up_hint)
    if side.length() < 0.0001:
        side = Vector3(1, 0, 0)
    side = side.normalized()
    var bend_dir = side.cross(forward_dir).normalized()

    var bend_amount = PI - angle_b
    var a_dir = (forward_dir * cos(bend_amount) + bend_dir * sin(bend_amount)).normalized()
    if a_dir.length() < 0.0001:
        a_dir = forward_dir

    # 应用根骨旋转
    var rot_a = _aim_rotation(a.global_transform.basis, a_dir)
    if rot_a != null:
        a.global_transform.basis = a.global_transform.basis.slerp(rot_a, weight)

    # 更新中骨位置
    var mid_now = a.global_transform.origin + a.global_transform.basis.y * len_ab
    # 计算中骨旋转使末端指向目标
    var dir_b = (desired_end - mid_now).normalized()
    var rot_b = _aim_rotation(b.global_transform.basis, dir_b)
    if rot_b != null:
        b.global_transform.basis = b.global_transform.basis.slerp(rot_b, weight)

    # 校正末端(含跨帧累积, 重设末端局部偏移)
    var end_local = c.translation
    c.global_transform = b.global_transform * Transform(Basis(), end_local)

# 让 basis 的 Y 轴指向 target_dir(两段骨沿 Y 伸展)
static func _aim_rotation(from_basis, target_dir):
	if target_dir.length() < 0.0001:
		return from_basis
	target_dir = target_dir.normalized()
	var from_dir = from_basis.y.normalized()
	if from_dir.dot(target_dir) > 0.9999:
		return from_basis
	var axis = from_dir.cross(target_dir)
	if axis.length() < 0.0001:
		return from_basis
	axis = axis.normalized()
	var angle = from_dir.angle_to(target_dir)
	var q = Quat(axis, angle)
	# Godot 3.5: 用 Basis(q) 转换而非 Quat * Basis
	return Basis(q) * from_basis