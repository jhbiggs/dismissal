package go_objects


type Bus struct {
	BusID int `json:"busid"`
	BusNumber string `json:"busnumber"`
	Animal string `json:"animal"`
	Arrived bool `json:"arrived"`
}

func NewBus(busID int, busnumber string, animal string) *Bus {
	return &Bus{BusID: busID, BusNumber: busnumber, Animal: animal, Arrived: false}
}

func (b *Bus) GetBusID() int {

	return b.BusID
}

func (b *Bus) GetNumber() string {
	return b.BusNumber
}

func (b *Bus) GetAnimal() string {
	return b.Animal
}
