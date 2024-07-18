package websocket_service
import (
	"encoding/json"
)
type Event struct {
	MessageType string `json:"messageType"`
	Payload json.RawMessage `json:"payload"`
}

type EventHandler func(event Event, c *Client) error


const (
	EventTeacherChange = "teacher-change";
	EventBusChange = "bus-change";
)

