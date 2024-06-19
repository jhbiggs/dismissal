package database_service

import (
	"database/sql"
	// "log"
	"fmt"

	// "github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
)

var (
	DB *sql.DB
)
const (
	host = "localhost"
	port = 5432
	user = "postgres"
	password = "Pcvh35$79"
	dbname = "localdatabase"
)
func InitDB() {
	var err error
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s "+ 
		"sslmode=disable", host, port, user, password, dbname)
	//Opening Connection to local postgres database running on local port 5432.
	DB, err = sql.Open("postgres", psqlInfo)
	if err != nil {
		panic(err)
	}

	err = DB.Ping()
	if err != nil {
		panic(err)
	}
}

func GetDB() *sql.DB {
	fmt.Println("GetDB called")
	return DB
}

func CloseDB() {
	DB.Close()
}

