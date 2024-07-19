package websocket_service

import (
	"log"
	"net/http"
	"sync"
	"fmt"

	// "dismissal.com/m/v2/database_service"
	"encoding/json"

	"dismissal.com/m/v2/database_service"
	"dismissal.com/m/v2/go_objects"
	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var (
	/** upgrades incoming HTTP requests into a persistent websocket
	 */
	websocketUpgrader = websocket.Upgrader{
		// Apply origin checker
		// CheckOrigin: checkOrigin,
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
	}
)
// not sure why this doesn't work
func checkOrigin(r *http.Request) bool {

	// grab the request origin
	origin := r.Header.Get("Origin")

	switch origin {
	case "http://localhost:80":
			return true
	default:
		return false
	}
}

// ClientList is a map used to help manage a map of clients

// Manager holds references to all registered clients, broadcasting rules
type Manager struct {
	clients ClientList

	// Lock state before editing clients or use channels to block
	sync.RWMutex

	// handlers are functions to handle events
	handlers map[string]EventHandler
}

// Initialize values in manager
func NewManager() *Manager {
	m := &Manager{
		clients:  make(ClientList),
		handlers: make(map[string]EventHandler),
		
	}
	m.setupEventHandlers()
	return m
}

func (m *Manager) setupEventHandlers() {

	m.handlers[EventTeacherChange] = func(e Event, c *Client) error {
		// take payload from event and create a teacher object
		teacher := &go_objects.Teacher{}
		err := json.Unmarshal([]byte(e.Payload), teacher)
		if err != nil {
			return err
		}

		data, err := json.Marshal(teacher)

		var outgoing Event
		outgoing.Payload = data
		outgoing.MessageType = EventTeacherChange

		for client := range c.manager.clients{
			client.egress <- outgoing
		}

		// update postgres database with teacher change information
		database_service.UpdateTeacher(teacher)
		return nil
	}
	m.handlers[EventBusChange] = func(e Event, c *Client) error {
		bus := &go_objects.Bus{}
		err := json.Unmarshal([]byte (e.Payload), bus)
		if err != nil {
			return err
		}

		data, err := json.Marshal(bus)
		if err != nil {
			return fmt.Errorf("failed to marshal broadcast message: %v", err)
		}

		// Place payload into an Event
		var outgoing Event 
		outgoing.Payload = data
		outgoing.MessageType = EventBusChange

		for client := range c.manager.clients {
			client.egress <- outgoing
		}

		database_service.UpdateBus(bus)

		return nil
	}
}

func (m *Manager) routeEvent(event Event, c *Client) error {
	
	// check if the event type is supported
	if handler, ok := m.handlers[event.MessageType]; ok {
		// call the handler
		if err := handler(event, c); err != nil {
			return err
		}
		return nil
	} else {
		return ErrEventNotSupported
	}
}

// Allows connections.  Gin Router calls it in API and server.go.
func (m *Manager) ServeWS(ctx *gin.Context) {

	log.Println("New connection")
	// Step one: upgrade HTTP request
	conn, err := websocketUpgrader.Upgrade(ctx.Writer, ctx.Request, nil)
	if err != nil {
		log.Println(err)
		return
	}

	// Create new client
	client := NewClient(conn, m)
	// Add the newly created client to the manager
	m.addClient(client)

	// start read/write process
	go client.readMessages()
	go client.writeMessages()

}

// add to client list
func (m *Manager) addClient(client *Client) {
	// lock to prevent intrusion
	m.Lock()
	defer m.Unlock()
	log.Println("Adding client")

	// add client
	m.clients[client] = true
}

// clean up the list
func (m *Manager) removeClient(client *Client) {
	m.Lock()
	defer m.Unlock()

	// check if exists, then delete
	if _, ok := m.clients[client]; ok {
		// close connection
		client.connection.Close()
		// remove
		delete(m.clients, client)
		log.Println("Removed client")
	}
}
