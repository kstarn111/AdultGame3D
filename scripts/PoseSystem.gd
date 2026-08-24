extends Node
class_name PoseSystem
# ============================================================
# PoseSystem.gd — 姿势系统 v1.0
# 定义 8 个体位: 每个体位包含角色A/B的相对位置、旋转、IK目标偏移
# 兼容 Godot 3.5.x
# ============================================================

enum Pose {
	MISSIONARY,      # 0 - 传教士
	DOGGY,           # 1 - 后入
	COWGIRL,         # 2 - 女上位
	REVERSE_COWGIRL, # 3 - 反向女上位
	SIDE,            # 4 - 侧躺
	STANDING,        # 5 - 站立
	EDGE,            # 6 - 床边
	SPOON,           # 7 - 汤勺
}

# 体位名称
static func get_pose_name(pose):
	match pose:
		Pose.MISSIONARY:      return "传教士"
		Pose.DOGGY:           return "后入"
		Pose.COWGIRL:         return "女上位"
		Pose.REVERSE_COWGIRL: return "反向女上位"
		Pose.SIDE:            return "侧躺"
		Pose.STANDING:        return "站立"
		Pose.EDGE:            return "床边"
		Pose.SPOON:           return "汤勺"
	return "未知"

# 体位数据:
# pos_a - 角色A(男)的世界位置
# rot_a - 角色A的旋转(度)
# pos_b - 角色B(女)相对角色A的位置偏移
# rot_b - 角色B的旋转(度)
# ik_targets - IK目标标记点偏移 {name: Vector3} 相对角色B
# ik_hands - 手部IK目标 {hand: target_pos} 相对角色A
static func get_pose_data(pose):
	match pose:
		Pose.MISSIONARY:
			return {
				"pos_a": Vector3(0, 0, 0),
				"rot_a": Vector3(0, 0, 0),
				"pos_b": Vector3(0, 0, -0.15),
				"rot_b": Vector3(0, 180, 0),
				"ik_spread": 0.12,      # 腿分开宽度
				"ik_forward": 0.25,      # 膝盖前推
				"ik_leg_angle": 25,      # 大腿角度
				"lean_a": 0.15,          # 角色A前倾
				"lean_b": -0.1,          # 角色B后倾
				"depth_offset": 0.0,     # 深度微调
				"hip_angle_a": 0,        # 角色A骨盆角度
				"hip_angle_b": -15,      # 角色B骨盆角度(腿抬起)
			}
			
		Pose.DOGGY:
			return {
				"pos_a": Vector3(0, 0, 0),
				"rot_a": Vector3(0, 0, 0),
				"pos_b": Vector3(0, 0, -0.35),
				"rot_b": Vector3(0, 0, 0),
				"ik_spread": 0.14,
				"ik_forward": -0.05,
				"ik_leg_angle": 10,
				"lean_a": 0.4,
				"lean_b": -0.45,
				"depth_offset": 0.0,
				"hip_angle_a": 5,
				"hip_angle_b": -5,
			}
			
		Pose.COWGIRL:
			return {
				"pos_a": Vector3(0, 0, 0),
				"rot_a": Vector3(0, 0, 0),
				"pos_b": Vector3(0, 0.35, 0),
				"rot_b": Vector3(0, 0, 0),
				"ik_spread": 0.18,
				"ik_forward": 0.0,
				"ik_leg_angle": 30,
				"lean_a": -0.2,
				"lean_b": 0.1,
				"depth_offset": 0.0,
				"hip_angle_a": -10,
				"hip_angle_b": 0,
			}
			
		Pose.REVERSE_COWGIRL:
			return {
				"pos_a": Vector3(0, 0, 0),
				"rot_a": Vector3(0, 0, 0),
				"pos_b": Vector3(0, 0.35, 0),
				"rot_b": Vector3(0, 180, 0),
				"ik_spread": 0.18,
				"ik_forward": 0.0,
				"ik_leg_angle": 30,
				"lean_a": -0.2,
				"lean_b": 0.15,
				"depth_offset": 0.0,
				"hip_angle_a": -10,
				"hip_angle_b": 0,
			}
			
		Pose.SIDE:
			return {
				"pos_a": Vector3(0, 0, 0),
				"rot_a": Vector3(0, 0, 90),
				"pos_b": Vector3(0, 0, -0.2),
				"rot_b": Vector3(0, 0, 90),
				"ik_spread": 0.10,
				"ik_forward": 0.15,
				"ik_leg_angle": 20,
				"lean_a": 0.0,
				"lean_b": 0.0,
				"depth_offset": 0.0,
				"hip_angle_a": 0,
				"hip_angle_b": 20,
			}
			
		Pose.STANDING:
			return {
				"pos_a": Vector3(0, 0, 0),
				"rot_a": Vector3(0, 0, 0),
				"pos_b": Vector3(0, 0.15, 0.1),
				"rot_b": Vector3(0, 180, 0),
				"ik_spread": 0.10,
				"ik_forward": 0.0,
				"ik_leg_angle": 15,
				"lean_a": 0.1,
				"lean_b": 0.2,
				"depth_offset": 0.0,
				"hip_angle_a": 0,
				"hip_angle_b": 25,
			}
			
		Pose.EDGE:
			return {
				"pos_a": Vector3(0, 0, 0),
				"rot_a": Vector3(0, 0, 0),
				"pos_b": Vector3(0, 0, -0.3),
				"rot_b": Vector3(0, 0, 0),
				"ik_spread": 0.16,
				"ik_forward": 0.0,
				"ik_leg_angle": 20,
				"lean_a": 0.2,
				"lean_b": 0.3,
				"depth_offset": 0.0,
				"hip_angle_a": 0,
				"hip_angle_b": -10,
			}
			
		Pose.SPOON:
			return {
				"pos_a": Vector3(0, 0, 0),
				"rot_a": Vector3(0, 0, 90),
				"pos_b": Vector3(0, 0, -0.15),
				"rot_b": Vector3(0, 0, 90),
				"ik_spread": 0.08,
				"ik_forward": 0.12,
				"ik_leg_angle": 15,
				"lean_a": 0.0,
				"lean_b": 0.0,
				"depth_offset": 0.0,
				"hip_angle_a": 0,
				"hip_angle_b": 15,
			}
	
	return get_pose_data(Pose.MISSIONARY)