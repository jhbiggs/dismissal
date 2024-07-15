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
	EventSendMessage = "send-message";
)

type SendMessageEvent struct {
	 Message string `json:"message"`
	 From string `json:"from"`
}

type TeacherChangeEvent struct {
	 TeacherID string `json:"teacherID"`
	 TeacherName string `json:"teacherName"`
	 Grade string `json:"grade"`
	 Arrived bool `json:"arrived"`
}

type BusChangeEvent struct {
	 BusID string `json:"busID"`
	 BusName string `json:"busName"`
}