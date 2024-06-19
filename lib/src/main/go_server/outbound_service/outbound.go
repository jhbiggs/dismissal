package outbound_service

import (
	"net/http"
)

var (
	Client *http.Client
	ini bool
)

func Init() *http.Client {
	if ini {
		return Client
	} else {
		Client = &http.Client{}
		return Client
	}
}