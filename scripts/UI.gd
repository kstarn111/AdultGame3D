extends CanvasLayer
# ============================================================
# UI.gd — 控制面板 v2.0
# 姿势选择器 + 参数滑块 + 表情按钮 + 模型加载入口
# 兼容 Godot 3.5.x
# ============================================================

const PoseSystem = preload("PoseSystem.gd")

var main

func _ready():
	_build_ui()

func _build_ui():
	# 主面板
	var panel = Panel.new()
	panel.rect_min_size = Vector2(220, 400)
	panel.rect_position = Vector2(10, 10)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.85)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.3, 0.3, 0.5)
	panel.add_stylebox_override("panel", style)
	
	add_child(panel)
	
	var y = 10
	var margin = 10
	var label_w = 80
	var control_w = 120
	var row_h = 28
	var spacing = 4
	
	# ===== 标题 =====
	var title = Label.new()
	title.text = "AdultGame3D v2.0"
	title.rect_position = Vector2(margin, y)
	title.rect_size = Vector2(200, 24)
	title.add_color_override("font_color", Color(1, 1, 1, 0.9))
	panel.add_child(title)
	y += 30
	
	# ===== 姿势选择 =====
	var pose_label = Label.new()
	pose_label.text = "体位:"
	pose_label.rect_position = Vector2(margin, y)
	pose_label.rect_size = Vector2(label_w, row_h)
	pose_label.add_color_override("font_color", Color(0.8, 0.8, 1))
	panel.add_child(pose_label)
	
	var pose_btn = Button.new()
	pose_btn.text = PoseSystem.get_pose_name(main.current_pose)
	pose_btn.rect_position = Vector2(margin + label_w, y)
	pose_btn.rect_size = Vector2(control_w, row_h)
	pose_btn.connect("pressed", self, "_on_pose_pressed")
	panel.add_child(pose_btn)
	y += row_h + spacing
	
	# ===== 动作模式 =====
	var mode_label = Label.new()
	mode_label.text = "模式:"
	mode_label.rect_position = Vector2(margin, y)
	mode_label.rect_size = Vector2(label_w, row_h)
	mode_label.add_color_override("font_color", Color(0.8, 0.8, 1))
	panel.add_child(mode_label)
	
	var mode_btn = Button.new()
	mode_btn.text = "常规"
	mode_btn.rect_position = Vector2(margin + label_w, y)
	mode_btn.rect_size = Vector2(control_w, row_h)
	mode_btn.connect("pressed", self, "_on_mode_pressed")
	panel.add_child(mode_btn)
	y += row_h + spacing
	
	# ===== 速度滑块 =====
	y = _add_slider(panel, "速度:", margin, y, label_w, control_w, row_h, spacing, main.speed, "_on_speed_changed")
	y = _add_slider(panel, "幅度:", margin, y, label_w, control_w, row_h, spacing, main.intensity, "_on_intensity_changed")
	y = _add_slider(panel, "前倾:", margin, y, label_w, control_w, row_h, spacing, main.lean, "_on_lean_changed")
	y = _add_slider(panel, "贴合:", margin, y, label_w, control_w, row_h, spacing, main.ik_weight, "_on_ik_changed")
	
	# ===== 表情按钮 =====
	var emo_label = Label.new()
	emo_label.text = "表情:"
	emo_label.rect_position = Vector2(margin, y)
	emo_label.rect_size = Vector2(label_w, row_h)
	emo_label.add_color_override("font_color", Color(0.8, 0.8, 1))
	panel.add_child(emo_label)
	
	var emo_names = ["中性", "开心", "难过", "兴奋", "痛苦"]
	for i in range(5):
		var btn = Button.new()
		btn.text = emo_names[i]
		btn.rect_position = Vector2(margin + label_w + i * 24, y)
		btn.rect_size = Vector2(22, row_h)
		btn.connect("pressed", self, "_on_emotion_pressed", [i])
		panel.add_child(btn)
	y += row_h + spacing
	
	# ===== 胸部大小 =====
	y = _add_slider(panel, "胸部:", margin, y, label_w, control_w, row_h, spacing, 0.5, "_on_breast_changed")
	
	# ===== 模型加载 =====
	var load_btn = Button.new()
	load_btn.text = "加载女模(FBX/GLB)"
	load_btn.rect_position = Vector2(margin, y)
	load_btn.rect_size = Vector2(200, 30)
	load_btn.connect("pressed", self, "_on_load_model")
	panel.add_child(load_btn)
	y += 36
	
	# 提示
	var hint = Label.new()
	hint.text = "提示: 尸体也存在"
	hint.rect_position = Vector2(margin, y)
	hint.rect_size = Vector2(200, 20)
	hint.add_color_override("font_color", Color(0.5, 0.5, 0.7))
	panel.add_child(hint)

func _add_slider(panel, text, margin, y, label_w, control_w, row_h, spacing, default_val, signal_name):
	var label = Label.new()
	label.text = text
	label.rect_position = Vector2(margin, y)
	label.rect_size = Vector2(label_w, row_h)
	label.add_color_override("font_color", Color(0.8, 0.8, 1))
	panel.add_child(label)
	
	var slider = HSlider.new()
	slider.rect_position = Vector2(margin + label_w, y)
	slider.rect_size = Vector2(control_w, row_h)
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.value = default_val
	slider.connect("value_changed", self, signal_name)
	panel.add_child(slider)
	
	var val_label = Label.new()
	val_label.text = str(stepify(default_val, 0.01))
	val_label.rect_position = Vector2(margin + label_w + control_w + 4, y)
	val_label.rect_size = Vector2(30, row_h)
	val_label.add_color_override("font_color", Color(0.7, 0.7, 0.7))
	panel.add_child(val_label)
	
	# 存储引用以便更新
	slider.set_meta("val_label", val_label)
	slider.connect("value_changed", self, "_update_slider_label", [slider])
	
	return y + row_h + spacing

func _update_slider_label(val, slider):
	var label = slider.get_meta("val_label")
	if label:
		label.text = str(stepify(val, 0.01))

# ===== 信号处理 =====
var _pose_index = 0
var _mode_index = 0

func _on_pose_pressed():
	_pose_index = (_pose_index + 1) % 8
	main.set_pose(_pose_index)
	# 更新按钮文本
	_update_pose_btn()

func _update_pose_btn():
	var panel = get_child(0)
	var pose_btn = panel.get_child(2)  # 姿势按钮索引
	if pose_btn and pose_btn is Button:
		pose_btn.text = PoseSystem.get_pose_name(main.current_pose)

func _on_mode_pressed():
	_mode_index = (_mode_index + 1) % 4
	main.set_posture(_mode_index)
	var names = ["站立", "常规", "快速", "贴合"]
	var panel = get_child(0)
	var mode_btn = panel.get_child(4)  # 模式按钮索引
	if mode_btn and mode_btn is Button:
		mode_btn.text = names[_mode_index]

func _on_speed_changed(val):
	main.set_speed(val)

func _on_intensity_changed(val):
	main.set_intensity(val)

func _on_lean_changed(val):
	main.set_lean(val)

func _on_ik_changed(val):
	main.set_ik_weight(val)

func _on_emotion_pressed(emotion):
	main.set_emotion(emotion)

func _on_breast_changed(val):
	main.set_breast_size(val)

func _on_load_model():
	# 打开文件对话框加载外部模型
	var dialog = FileDialog.new()
	dialog.mode = FileDialog.MODE_OPEN_FILE
	dialog.add_filter("*.fbx;FBX Model")
	dialog.add_filter("*.glb;GLB Model")
	dialog.add_filter("*.gltf;GLTF Model")
	dialog.add_filter("*.obj;OBJ Model")
	dialog.rect_min_size = Vector2(500, 400)
	dialog.connect("file_selected", self, "_on_file_selected")
	dialog.connect("popup_hide", self, "_on_dialog_closed", [dialog])
	add_child(dialog)
	dialog.popup_centered()

func _on_file_selected(path):
	print("Loading model: ", path)
	var ok = main.load_female_model(path)
	if ok:
		print("Model loaded successfully!")
	else:
		print("Failed to load model: ", path)

func _on_dialog_closed(dialog):
	if dialog and is_instance_valid(dialog):
		dialog.queue_free()