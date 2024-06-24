package database_service

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
	"sync"

	"dismissal.com/m/v2/go_objects"
)

var (
	// mutex allows safe manipulation of the list across different goroutines
	mtx sync.Mutex
	// global list of buses
	busList []go_objects.Bus

	// global list of teachers
	teacherList []go_objects.Teacher
)

func GetBuses(ctx *gin.Context) {
	fmt.Println("GetBuses called")

	busList := []go_objects.Bus{}
	// query the database and return rows into the rows variable.
	// Query returns a rows object and an error object.
	// Go doesn't care what the SQL column names are.
	// It just takes the data from the column and puts them into the fields you specify.
	dbInstance := GetDB()
	rows, err := dbInstance.Query("SELECT * FROM dismissal_schema.buses")
	// print each row in rows
	if err != nil {
		fmt.Println("Error querying the database: ", err)
		return
	}
	defer rows.Close()
	// iterate over the rows object and print the values of each row.
	for rows.Next() {
		var row go_objects.Bus
		err = rows.Scan(&row.BusID, &row.BusNumber, &row.Animal, &row.Arrived)
		if err != nil {
			fmt.Println("Error scanning the row: ", err)
			return
		} else {
			fmt.Println("ID: ", row.BusID, "Animal name: ", row.Animal,
				"Bus Number: ", row.BusNumber, "Arrived: ", row.Arrived)
			mtx.Lock()
			busList = append(busList, row)
			// unlock the thread
			mtx.Unlock()
		}
	}
	if err != nil {
		fmt.Println("Error querying the database: ", err)
		return
	}
	defer rows.Close()
	// iterate over the rows object and print the values of each row.
	for rows.Next() {
		var row go_objects.Bus
		err = rows.Scan(&row.BusID, &row.BusNumber, &row.Animal, &row.Arrived)
		if err != nil {
			fmt.Println("Error scanning the row: ", err)
			return
		} else {
			fmt.Println("ID: ", row.BusID, "Animal name: ", row.Animal,
				"Bus Number: ", row.BusNumber, "Arrived: ", row.Arrived)

			mtx.Lock()
			busList = append(busList, row)
			// unlock the thread
			mtx.Unlock()
			
		}
	}
	ctx.JSON(http.StatusOK, go_objects.BusListResponse{
		Buses: busList,
	})

}

func ToggleBusArrivalStatus(ctx *gin.Context) {
	fmt.Println("updateBusStatus called")

	busid := ctx.Param("id")
	_, err := DB.Exec("UPDATE dismissal_schema.buses SET arrived = NOT arrived WHERE busid = $1", busid)

	if err != nil {
		panic(err)
	}
}
