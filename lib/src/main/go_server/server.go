package main

import (
	"context"
	"errors"
	"fmt"
	"net"
	"net/http"
	"sync"

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

	outbound_service.Init()


	//Initialize request router
ginRouter := gin.Default()
ginRouter.GET("/buses", func (ctx *gin.Context) { database_service.GetBuses(ctx) })
// ginRouter.POST("/buses", func (ctx *gin.Context) { database_service.AddBus(ctx) })
// ginRouter.GET("/teachers", func (ctx *gin.Context) { database_service.GetTeachers(ctx) })
// ginRouter.POST("/teachers", func (ctx *gin.Context) { database_service.AddTeacher(ctx) })
ginRouter.PUT("/buses/:id/toggleBusArrivalStatus", func (ctx *gin.Context) { database_service.ToggleBusArrivalStatus(ctx) })

	
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


	<-ctx.Done()
}
