extends Node

func await_ready(node: Node):
	if not node.is_node_ready():
		await node.ready
