extends Node
class_name Config

const LIGHT_TIME_TO_CHANGE: int = 5
const VEHICLE_SPEED: float = 0.9
enum Direction {NORTH, EAST, SOUTH, WEST}
enum RoadSide {TOP, BOTTOM}
enum Collisions {NONE = 0, VEHICLE_BUMPER_REAR = 32, TRAFFIC_LIGHT = 64, INTERSECTION = 128}
