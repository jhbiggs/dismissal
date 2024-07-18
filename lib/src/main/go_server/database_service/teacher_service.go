package database_service

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"

	"dismissal.com/m/v2/go_objects"
)

func GetTeachers(ctx *gin.Context) {
	fmt.Println("GetTeachers called")

	teacherList := []go_objects.Teacher{}
	// query the database and return rows into the rows variable.
	// Query returns a rows object and an error object.
	// Go doesn't care what the SQL column names are.
	// It just takes the data from the column and puts them into the fields you specify.
	dbInstance := GetDB()
	rows, err := dbInstance.Query("SELECT * FROM dismissal_schema.teachers")
	// print each row in rows
	if err != nil {
		fmt.Println("Error querying the database: ", err)
		return
	}
	defer rows.Close()
	// iterate over the rows object and print the values of each row.
	for rows.Next() {
		var row go_objects.Teacher
		err = rows.Scan(&row.TeacherID, &row.Name, &row.Grade, &row.Arrived)
		if err != nil {
			fmt.Println("Error scanning the row: ", err)
			return
		} else {
			// fmt.Println("ID: ", row.TeacherID, "Name: ", row.Name,
			// 	"Arrived? ", row.Arrived)
			mtx.Lock()
			teacherList = append(teacherList, row)
			// unlock the thread
			mtx.Unlock()
		}
	}
	ctx.JSON(http.StatusOK, go_objects.TeacherListResponse{
		Teachers: teacherList,
	})
}

func ToggleTeacherArrivalStatus(ctx *gin.Context){
	teacherID := ctx.Param("teacher_id")
	fmt.Println("ToggleTeacherArrivalStatus called with teacherID: ", teacherID)

	result, err := DB.Exec("UPDATE dismissal_schema.teachers SET arrived = NOT arrived WHERE teacherid = $1", teacherID)
	fmt.Println("Result is: ", result)
	if err != nil {
		fmt.Println("Error updating the database: ", err)
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"message": "Teacher arrival status updated successfully"})
}

func UpdateTeacher(teacher *go_objects.Teacher) {
	fmt.Println("UpdateTeacher called")
	fmt.Printf("Teacher: %+v\n", teacher)
	result, err := DB.Exec("UPDATE dismissal_schema.teachers SET arrived = $1 WHERE teacherid = $2", teacher.Arrived, teacher.TeacherID)
	fmt.Println("result in updateTeacher is: ", result)
	if err != nil {
		fmt.Println("Error updating the teachers table: ", err)
	}
}