class_name InputManagerSingleton extends Node

## Multi-Device Input Orchestration and Command Generation

class PuppyCommand:
	var move_vector: Vector2 = Vector2.ZERO
	var jump_just_pressed: bool = false
	var interact_just_pressed: bool = false
	var interact_held: bool = false
	var bark_just_pressed: bool = false
	var special_just_pressed: bool = false
	var special_held: bool = false
	var sprint_held: bool = false

func get_player_command(player_id: int) -> PuppyCommand:
	var cmd = PuppyCommand.new()
	var prefix = "p1_" if player_id == 1 else "p2_"
	
	var in_x = Input.get_axis(prefix + "move_left", prefix + "move_right")
	var in_y = Input.get_axis(prefix + "move_forward", prefix + "move_backward")
	cmd.move_vector = Vector2(in_x, in_y).normalized() if Vector2(in_x, in_y).length() > 0.1 else Vector2.ZERO
	
	cmd.jump_just_pressed = Input.is_action_just_pressed(prefix + "jump")
	cmd.interact_just_pressed = Input.is_action_just_pressed(prefix + "interact")
	cmd.interact_held = Input.is_action_pressed(prefix + "interact")
	cmd.bark_just_pressed = Input.is_action_just_pressed(prefix + "bark")
	cmd.special_just_pressed = Input.is_action_just_pressed(prefix + "special")
	cmd.special_held = Input.is_action_pressed(prefix + "special")
	cmd.sprint_held = Input.is_action_pressed(prefix + "sprint")
	
	return cmd
