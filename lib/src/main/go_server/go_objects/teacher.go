package go_objects

type Teacher struct {
	TeacherID int `json:"teacher_id"`
	Name string `json:"name"`
	Grade string `json:"grade"`
	Arrived bool `json:"arrived"`
}

func NewTeacher(teacherID int, name string, grade string) *Teacher {
	return &Teacher{TeacherID: teacherID, Name: name, Grade: grade}
}

func (t *Teacher) GetTeacherID() int {
	return t.TeacherID
}

func (t *Teacher) GetName() string {
	return t.Name
}

func (t *Teacher) GetGrade() string {
	return t.Grade
}

