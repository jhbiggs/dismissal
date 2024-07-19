package websocket_service
import (
	"encoding/json"
	"time"
	"fmt"
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

type SendChangeEvent struct {
	Change string `json: "change"`
	From string `json:"from"`
}

type NewChangeEvent struct {
	SendChangeEvent
	Sent time.Time `json:"sent"`
}

// Send Change Handler will send out a message to all participants on the
// channel.
func SendChangeHandler (event Event, c *Client) error {
	// Marshal Payload into desired format
	var changeEvent SendChangeEvent
	if err := json.Unmarshal(event.Payload, &changeEvent); err != nil {
		return fmt.Errorf("bad payload in request: %v", err)
	}

	// Prepare outgoing message
	var broadMessage NewChangeEvent
	broadMessage.Sent = time.Now()
	broadMessage.Change = changeEvent.Change
	broadMessage.From = changeEvent.From

	data, err := json.Marshal(broadMessage)
	if err != nil {
		return fmt.Errorf("failed to marshal broadcast message: %v", err)
	}

	// Place payload into Event
	var outgoingEvent Event
	outgoingEvent.Payload = data

	// TODO: make object names less confusing and add TeacherBusChange
	outgoingEvent.MessageType = EventBusChange

	// Broadcast to all clients
	for client := range c.manager.clients {
		client.egress <- outgoingEvent
	}
	return nil
}