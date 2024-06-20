package main

import (
	"context"
	"errors"
	"fmt"
	"net"
	"net/http"
	"sync"
	
	"database/sql"
	"time"
	"github.com/lib/pq"
	"dismissal.com/m/v2/outbound_service"
	"github.com/gin-gonic/gin"
	// local imports
	"dismissal.com/m/v2/database_service" 
	// Add this line to import the package
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
	var conninfo string = "dbname=localdatabase user=postgres password=Pcvh35$79 sslmode=disable"

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



	outbound_service.Init()


	//Initialize request router
ginRouter := gin.Default()
ginRouter.GET("/buses", func (ctx *gin.Context) { database_service.GetBuses(ctx) })
ginRouter.GET("/teachers", func (ctx *gin.Context) { database_service.GetTeachers(ctx) })
// ginRouter.POST("/buses", func (ctx *gin.Context) { database_service.AddBus(ctx) })
// ginRouter.GET("/teachers", func (ctx *gin.Context) { database_service.GetTeachers(ctx) })
// ginRouter.POST("/teachers", func (ctx *gin.Context) { database_service.AddTeacher(ctx) })
ginRouter.PUT("/buses/:id/toggleBusArrivalStatus", func (ctx *gin.Context) { database_service.ToggleBusArrivalStatus(ctx) })
ginRouter.PUT("/teachers/:teacher_id/toggleTeacherArrivalStatus", func (ctx *gin.Context) { database_service.ToggleTeacherArrivalStatus(ctx) })

	
	ctx, cancelCtx := context.WithCancel(context.Background())
	serverOne := &http.Server{
		Addr:    ":8080",
		Handler: ginRouter,
		BaseContext: func(l net.Listener) context.Context {
			ctx = context.WithValue(ctx, "listener", l.Addr().String())
			return ctx
		},
	}

	go func() {
		fmt.Printf("server one listening on port 8080 \n")
		// err := serverOne.ListenAndServeTLS("","")
		err := serverOne.ListenAndServe()
		if errors.Is(err, http.ErrServerClosed) {
			fmt.Printf("server one closed \n")
		} else if err != nil {
			fmt.Printf("error listening on server one: %s \n", err)
		}
		cancelCtx()
	}()
	fmt.Println("Monitoring PostgreSQL now...")
	for {
		database_service.WaitForNotification(listener);
	}

	<-ctx.Done()
}
