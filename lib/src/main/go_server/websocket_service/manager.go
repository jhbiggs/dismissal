package websocket_service

import (
	"log"
	// "net/http"
	"sync"
	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

// ClientList is a map used to help manage a map of clients
type ClientList map[*Client]bool

// Client is a websocket client, aka front-end visitor
type Client struct {
	// The websocket connection.
	connection *websocket.Conn

	// manages the client (i.e. delegates messages)
	manager *Manager

	// egress is used to avoid concurrent write attempts
	egress chan []byte
}

// Initialize a new client
func NewClient(conn *websocket.Conn, manager *Manager) *Client {
	return &Client{
		connection: conn,
		manager: manager,
		egress: make(chan []byte),
	}
}

var (
	/** upgrades incoming HTTP requests into a persistent websocket
	*/
	websocketUpgrader = websocket.Upgrader{
		ReadBufferSize: 1024,
		WriteBufferSize: 1024,
	}
)

// Manager holds references to all registered clients, broadcasting rules
type Manager struct {
	clients ClientList
	
	// Lock state before editing clients or use channels to block
	sync.RWMutex
}

// Initialize values in manager
func NewManager() *Manager {
	return &Manager{
		clients: make(ClientList),
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
func (m *Manager) removeClient(client *Client){
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

// goroutine for handling read messages
func (c *Client) readMessages() {
	defer func() {
		// close the function when complete
		c.manager.removeClient(c)
	}()

	for {
		// read the next message in the queue connection
		messageType, payload, err := c.connection.ReadMessage()

		if err != nil {
			// if connection is closed there will be an error
			// only strange errors, no simple disconnection
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway,
			websocket.CloseAbnormalClosure){
				log.Printf("error reading message: %v", err)
			}
			break
		}
		log.Println("MessageType: ", messageType)
		log.Println("Payload: ", string(payload))

		// hack to test writeMessages
		// TODO: replace
		for wsclient := range c.manager.clients {
			wsclient.egress <- payload
		}
	}

}

func (c *Client) writeMessages() {
	defer func() {
		// close gracefully if triggered
		c.manager.removeClient(c)
	}()

	for {
		select {
		case message, ok := <-c.egress:
			// "ok" will be false in case the egress channel is closed
			if !ok {
				// manager closed connection, communicate to front end
				if err := c.connection.WriteMessage(websocket.CloseMessage, nil); err != nil {
					log.Println("connection closed: ", err)
				}
				// return and close goroutine
				return
			}
			// Send a message on the channel
			if err := c.connection.WriteMessage(websocket.TextMessage, message); err != nil {
				log.Println(err)
			}
			log.Println("sent message")
		}
	}
}

