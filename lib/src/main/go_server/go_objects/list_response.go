package go_objects

type BusListResponse struct {
	// the json tag is used to specify the name of the field in the json object
	Buses []Bus `json:"buses"`
}