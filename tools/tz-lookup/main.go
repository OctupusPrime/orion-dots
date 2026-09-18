package main

import (
	"flag"
	"fmt"
	"math"
	"os"

	"github.com/ringsaturn/tzf"
)

func main() {
	lng := flag.Float64("lng", 0, "Longitude to query")
	lat := flag.Float64("lat", 0, "Latitude to query")

	flag.Parse()

	if math.IsNaN(*lng) || *lng < -180 || *lng > 180 {
		fmt.Fprintln(os.Stderr, "Error: invalid longitude")
		os.Exit(1)
	}

	if math.IsNaN(*lat) || *lat < -90 || *lat > 90 {
		fmt.Fprintln(os.Stderr, "Error: invalid latitude")
		os.Exit(1)
	}

	finder, err := tzf.NewDefaultFinder()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error initializing finder: %v\n", err)
		os.Exit(1)
	}

	timezones, err := finder.GetTimezoneNames(*lng, *lat)
	if err != nil || len(timezones) == 0 {
		fmt.Fprintln(os.Stderr, "Error: timezone not found")
		os.Exit(1)
	}

	fmt.Println(timezones[0])
}