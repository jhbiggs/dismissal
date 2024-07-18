package websocket_service

import (
	"encoding/json"
	"log"
	"github.com/gorilla/websocket"
	"errors"
	"time"
)

var (
	ErrEventNotSupported = errors.New("this event type is not supported")
	pongWait = 10 * time.Second
	pingInterval = (pongWait * 9) / 10
)

type ClientList map[*Client]bool

// Client is a websocket client, aka front-end visitor
type Client struct {
	// The websocket connection.
	connection *websocket.Conn

	// manages the client (i.e. delegates messages)
	manager *Manager

	// egress is used to avoid concurrent write attempts
	egress chan Event
}

// Initialize a new client
func NewClient(conn *websocket.Conn, manager *Manager) *Client {
	return &Client{
		connection: conn,
		manager: manager,
		egress: make(chan Event),
	}
}




// goroutine for handling read messages
func (c *Client) readMessages() {
	defer func() {
		// close the function when complete
		c.manager.removeClient(c)
	}()

	c.connection.SetReadLimit(512)

	// configure wait time for pong response, use current time + pongWait
	// to set initial timer and calculate deadline
	if err := c.connection.SetReadDeadline(time.Now().Add(pongWait)); err != nil{
		log.Println("error setting read deadline: ", err)
		return
	}

	// Configure how to handle pong responses
	c.connection.SetPongHandler(c.pongHandler)

	for {
		// read the next message in the queue connection
		_ , payload, err := c.connection.ReadMessage()

		if err != nil {
			// if connection is closed there will be an error
			// only strange errors, no simple disconnection
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway,
			websocket.CloseAbnormalClosure){
				log.Printf("error reading message: %v", err)
			}
			break
		}
		log.Println("Payload: ", string(payload))
		var event Event
		if err := json.Unmarshal(payload, &event); err != nil {
			log.Printf("error unmarshalling message: %v", err)
		} 
		// var request Event
		// if err := json.Unmarshal(payload, &request); err != nil {
		// 	log.Printf("err unmarshalling message: %v", err)
		// }
		// log.Printf("unmarshalled message: %v", request)
		// route the event
		if err := c.manager.routeEvent(event, c); err != nil {
			log.Println("error routing event: ", err)
		}

	}

}

// pongHandler handles pong messages for the client
func (c *Client) pongHandler(pongMsg string) error {
	// current time  + pong wait time
	return c.connection.SetReadDeadline(time.Now().Add(pongWait))
}

func (c *Client) writeMessages() {

	ticker := time.NewTicker(pingInterval)
	defer func() {
		ticker.Stop()
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
			data, err := json.Marshal(message)
			if err != nil {
				log.Println(err)
				return
			}
			// write a regular message to the connection
			if err := c.connection.WriteMessage(websocket.TextMessage, data); err != nil {
				log.Println(err)
			}
			log.Println("sent message")
		case <-ticker.C:
			// Send the ping
			if err := c.connection.WriteMessage(websocket.PingMessage, []byte{}); err != nil {
				log.Println("Write message in ping error: ", err)
				return
			}
		}
	}
}

