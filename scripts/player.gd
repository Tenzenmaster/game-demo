class_name Player
extends CharacterBody2D

enum State {IDLE, WALK, USE_TOOL}

@export var move_speed: float
@export var animation_player: AnimationPlayer
@export var animation_tree: AnimationTree

@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get(&"parameters/playback")

var blend_position: Vector2:
    set(value):
        blend_position = value
        animation_tree.set(&"parameters/Idle/blend_position", value)
        animation_tree.set(&"parameters/Walk/blend_position", value)
        animation_tree.set(&"parameters/Chop/blend_position", value)

var state: State = State.IDLE

func _ready() -> void:
    animation_state.travel(&"Idle")

func _physics_process(_delta: float) -> void:
    match state:
        State.IDLE:
            idle()
        State.WALK:
            walk()
        State.USE_TOOL:
            use_tool()

func input_vector() -> Vector2:
    return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

func idle() -> void:
    velocity = input_vector() * move_speed
    move_and_slide()
    if input_vector():
        blend_position = input_vector()
    if Input.is_action_just_pressed(&"use_tool"):
        animation_state.travel(&"Chop")
        state = State.USE_TOOL
    elif velocity:
        animation_state.travel(&"Walk")
        state = State.WALK

func walk() -> void:
    velocity = input_vector() * move_speed
    move_and_slide()
    if input_vector():
        blend_position = input_vector()
    if Input.is_action_just_pressed(&"use_tool"):
        animation_state.travel(&"Chop")
        state = State.USE_TOOL
    elif not velocity:
        animation_state.travel(&"Idle")
        state = State.IDLE

func use_tool() -> void:
    pass

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
    if anim_name.contains("chop"):
        state = State.IDLE
