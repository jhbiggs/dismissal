package go_objects

type Teacher struct {
	TeacherID int `json:"teacherid"`
	Name string `json:"teachername"`
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

