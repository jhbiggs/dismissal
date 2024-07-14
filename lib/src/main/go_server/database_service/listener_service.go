package database_service

import (
	"bytes"
	"encoding/json"
	"fmt"
	"time"
	"github.com/lib/pq"
)

func WaitForNotification(listener *pq.Listener) []byte  {
	for {
			select {
			case n:= <-listener.Notify:
				fmt.Println("Received data from channel [", n.Channel, 
			"] :");
				var prettyJSON bytes.Buffer;
				err := json.Indent(&prettyJSON, []byte(n.Extra), "","\t");
				if err != nil {
						fmt.Println("Error processing JSON: ", err);
						// return an empty byte array
						return nil;
				}
				// fmt.Println(string(prettyJSON.Bytes()));
				return prettyJSON.Bytes();
			// the "<-" operator is a channel receiver
		case <-time.After(90 * time.Second):
			fmt.Println("Received no events from database for 90 seconds, checking connection");
			go func () {
				listener.Ping();
			}()
			return nil;
	}
}
}
