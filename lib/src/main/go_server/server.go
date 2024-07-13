package main

import (
	"context"
	"errors"
	"fmt"
	"net"
	"net/http"
	"sync"
	"log"
	"github.com/google/uuid"
	"crypto/sha1"
	"encoding/base64"

	
	"database/sql"
	"time"
	"github.com/lib/pq"
	"dismissal.com/m/v2/outbound_service"
	"github.com/gin-gonic/gin"
	// local imports
	"dismissal.com/m/v2/database_service" 
	"github.com/gorilla/websocket"
	"os"
)

var (
	// mutex allows safe manipulation of the list across different goroutines
	mtx sync.Mutex
	// assure a specific operation will run only once
	once sync.Once
)

// //go:embed server.crt
// var crt []byte

// //go:embed server.key
// var key []byte

func main() {
	// init db for all other services
	database_service.InitDB()
	var conninfo string = "dbname=localdatabase user=justinbiggs password=Pcvh35$79 sslmode=disable"

	_, err := sql.Open("postgres", conninfo)
	if err != nil {
		panic(err)
	}

	reportProblem := func(ev pq.ListenerEventType, err error) {
		if err != nil {
			fmt.Println("Hey, so reporting a problem: ",err.Error())
		}
	}

	listener := pq.NewListener(conninfo, 10*time.Second, time.Minute,
	reportProblem)
	err = listener.Listen("events")
	if err != nil {
		panic (err)
	}

	// websocket token creation steps
	// 1. Generate a random UUID
	// 2. Encode the UUID to a string
	// 3. Send the string to the client
	// 4. The client will use the string to connect to the websocket
	// 5. The server will check the string to see if it is valid
	// 6. If the string is valid, the client will be allowed to connect
	// 7. If the string is invalid, the client will be disconnected

	// generate a random UUID
	uuid := uuid.New()

	// encode the UUID to a string
	// the string will be used as a token
	hash := sha1.New()
	encoder := base64.NewEncoder(base64.StdEncoding, os.Stdout)
	encoder.Write(uuid[:])

	fmt.Println("encoder here... \n")
	encoder.Write(hash.Sum(nil))

	encoder.Close()



	webSocketHandler := webSocketHandler{
		upgrader: websocket.Upgrader{
		},
	}


	outbound_service.Init()


	//Initialize request router
ginRouter := gin.Default()
ginRouterTwo := gin.Default()

ginRouter.GET("/buses", func (ctx *gin.Context) { database_service.GetBuses(ctx) })
ginRouter.GET("/teachers", func (ctx *gin.Context) { database_service.GetTeachers(ctx) })
// ginRouter.POST("/buses", func (ctx *gin.Context) { database_service.AddBus(ctx) })
// ginRouter.GET("/teachers", func (ctx *gin.Context) { database_service.GetTeachers(ctx) })
// ginRouter.POST("/teachers", func (ctx *gin.Context) { database_service.AddTeacher(ctx) })
ginRouter.PUT("/buses/:id/toggleBusArrivalStatus", func (ctx *gin.Context) { database_service.ToggleBusArrivalStatus(ctx) })
ginRouter.PUT("/teachers/:teacher_id/toggleTeacherArrivalStatus", func (ctx *gin.Context) { database_service.ToggleTeacherArrivalStatus(ctx) })
ginRouterTwo.GET("/notification-stream", func (ctx *gin.Context) { webSocketHandler.NotificationStream(ctx, listener) })

	
	ctx, cancelCtx := context.WithCancel(context.Background())
	serverOne := &http.Server{
		Addr:    ":80",
		Handler: ginRouter,
		BaseContext: func(l net.Listener) context.Context {
			ctx = context.WithValue(ctx, "listener", l.Addr().String())
			return ctx
		},
	}



	serverTwo := &http.Server{
		Addr:    ":8080",
		Handler: ginRouterTwo,
		BaseContext: func(l net.Listener) context.Context {
			ctx = context.WithValue(ctx, "listener", l.Addr().String())
			return ctx
		},
	}

	go func() {
		fmt.Printf("server one listening on port 80 \n")
		// err := serverOne.ListenAndServeTLS("","")
		err := serverOne.ListenAndServe()
		if errors.Is(err, http.ErrServerClosed) {
			fmt.Printf("server one closed \n")
		} else if err != nil {
			fmt.Printf("error listening on server one: %s \n", err)
		}
		cancelCtx()
	}()

	go func() {
		fmt.Printf("server two listening on port 8080 \n")
		err := serverTwo.ListenAndServe()
		// err := serverTwo.ListenAndServeTLS("server.crt", "server.key")
		if errors.Is(err, http.ErrServerClosed) {
			fmt.Printf("server two closed \n")
		} else if err != nil {
			fmt.Printf("error listening on server two: %s \n", err)
		}
		cancelCtx()
	}()

	fmt.Println("Monitoring PostgreSQL now...")


	<-ctx.Done()
}

type webSocketHandler struct {
	upgrader websocket.Upgrader

}


func (wsh webSocketHandler) NotificationStream (ctx *gin.Context, l *pq.Listener) {

	c, err := wsh.upgrader.Upgrade(ctx.Writer, ctx.Request, nil)

	if err != nil {
		log.Printf("error %s when upgrading connection to websocket", err)
		return
	}

	defer func() {
		log.Println("closing connection")
		c.Close()
	}()

	i := 1

	// go has a nifty infinite loop syntax, it's just a for loop with no condition
	for {
		responseInBytes := database_service.WaitForNotification(l)
		fmt.Println("response in string: ", string(responseInBytes))
		// response := fmt.Sprintf("Notification %d", i)
		err = c.WriteMessage (websocket.TextMessage, []byte(responseInBytes))
		if err != nil {
			log.Printf("Error %s when sending message to client", err)
			return
		}
		time.Sleep(time.Second)

		i++
	}


}
