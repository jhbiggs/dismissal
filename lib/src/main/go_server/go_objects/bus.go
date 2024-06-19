package go_objects


type Bus struct {
	BusID int `json:"id"`
	Number string `json:"number"`
	Animal string `json:"animal"`
	Arrived bool `json:"arrived"`
}

func NewBus(busID int, number string, animal string) *Bus {
	return &Bus{BusID: busID, Number: number, Animal: animal, Arrived: false}
}

func (b *Bus) GetBusID() int {

	return b.BusID
}

func (b *Bus) GetNumber() string {
	return b.Number
}

func (b *Bus) GetAnimal() string {
	return b.Animal
}
