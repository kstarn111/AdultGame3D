extends Node
class_name MotionEngine
# ============================================================
# MotionEngine.gd — 参数化动作引擎 v2.0
# 多频波形合成 + 延迟传播(全身波动) + 体位感知
# 兼容 Godot 3.5.x
# ============================================================

enum Mode { STAND, RHYTHM, FAST, FOLLOW }

var _t = 0.0
var _mode = Mode.STAND
var _current_pose = 0

func _process(delta):
	_t += delta

func reset():
	_t = 0.0

func set_mode(m):
	_mode = m

func set_pose(pose):
	_current_pose = pose

# 每帧驱动角色
func drive(character, speed, intensity, lean, pose_data):
	if character == null or character.hips == null:
		return
	
	var t = _t
	
	# 主频: 1.0~3.5 Hz
	var freq = 1.0 + speed * 2.5
	var freq2 = freq * 0.7
	var freq3 = freq * 1.3
	var amp = 0.03 + intensity * 0.09
	
	# 三频合成波形 -> 真实不单调
	var wave1 = sin(t * freq * TAU)
	var wave2 = sin(t * freq2 * TAU + 0.5) * 0.6
	var wave3 = sin(t * freq3 * TAU + 1.2) * 0.4
	var main_wave = wave1 * 0.6 + wave2 * 0.3 + wave3 * 0.1
	
	var wave_side = sin(t * freq * TAU + 1.7)
	
	# 骨骼延迟传播
	var delay1 = sin((t - 0.05) * freq * TAU)
	var delay2 = sin((t - 0.10) * freq * TAU)
	
	var hips = character.hips
	var spine = character.spine
	var chest = character.chest
	var head = character.head
	
	var lean_a = pose_data.get("lean_a", 0.0)
	var hip_angle_a = pose_data.get("hip_angle_a", 0.0)
	
	match _mode:
		Mode.STAND:
			hips.translation = Vector3(0, 0.95 + sin(t * 1.2) * 0.004, 0)
			hips.rotation_degrees.x = -2.0 + hip_angle_a
			spine.rotation_degrees.x = -2.0
			chest.rotation_degrees.x = -2.0
			
		Mode.RHYTHM:
			hips.translation = Vector3(
				wave_side * amp * 0.3,
				0.95 + abs(main_wave) * amp * 0.25,
				main_wave * amp * 0.8
			)
			hips.rotation_degrees.x = main_wave * 14.0 * intensity + hip_angle_a
			hips.rotation_degrees.z = wave_side * 5.0 * intensity
			spine.rotation_degrees.x = -4.0 - delay1 * 10.0 * intensity
			chest.rotation_degrees.x = -3.0 + delay2 * 7.0 * intensity
			head.rotation_degrees.x = -spine.rotation_degrees.x * 0.4
			
		Mode.FAST:
			var h_freq = 3.0 + speed * 4.0
			var fw1 = sin(t * h_freq * TAU)
			var fw2 = sin(t * h_freq * TAU * 0.5 + 0.8)
			var fw_amp = 0.04 + intensity * 0.12
			hips.translation = Vector3(
				fw2 * fw_amp * 0.4,
				0.95 + abs(fw1) * fw_amp * 0.4,
				fw1 * fw_amp * 1.1
			)
			hips.rotation_degrees.x = fw1 * 20.0 * intensity + hip_angle_a
			hips.rotation_degrees.z = fw2 * 7.0 * intensity
			spine.rotation_degrees.x = -6.0 - fw1 * 12.0 * intensity
			chest.rotation_degrees.x = -4.0 + fw2 * 9.0 * intensity
			head.rotation_degrees.x = -spine.rotation_degrees.x * 0.4
			
		Mode.FOLLOW:
			var f = 1.0 + speed * 2.0
			var fw = sin(t * f * TAU)
			hips.translation = Vector3(
				sin(t * f * TAU + 1.0) * amp * 0.2,
				0.95 + abs(fw) * amp * 0.15,
				fw * amp * 0.3
			)
			hips.rotation_degrees.x = fw * 8.0 * intensity + hip_angle_a
			hips.rotation_degrees.z = sin(t * f * TAU + 1.5) * 4.0 * intensity
	
	# 前倾叠加
	hips.rotation_degrees.x += lean * 22.0 + lean_a * 30.0
	spine.rotation_degrees.x += lean * 14.0 + lean_a * 20.0
	chest.rotation_degrees.x += lean * 10.0 + lean_a * 15.0
	head.rotation_degrees.x = -character.spine.rotation_degrees.x * 0.4