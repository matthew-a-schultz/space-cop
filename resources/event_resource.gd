extends Resource
class_name EventResource

enum Type {RADIO, MOVE, ATTACK, FLEE, COUNTDOWN}
@export var type: Type
@export var thing: ObjectResource
