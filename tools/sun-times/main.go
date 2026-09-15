package main

import (
	"flag"
	"fmt"
	"math"
	"os"
	"time"
)

const (
	D2R = math.Pi / 180.0
	R2D = 180.0 / math.Pi
	Zenith = 90.8333
)

func main() {
	lng := flag.Float64("lng", 0.0, "Longitude (decimal degrees)")
	lat := flag.Float64("lat", 0.0, "Latitude (decimal degrees)")
	tzName := flag.String("tz", "UTC", "Timezone name (e.g., Asia/Shanghai)")

	flag.Parse()

	if math.IsNaN(*lat) || *lat < -90 || *lat > 90 {
		fmt.Fprintln(os.Stderr, "Error: invalid --lat")
		os.Exit(1)
	}

	if math.IsNaN(*lng) || *lng < -180 || *lng > 180 {
		fmt.Fprintln(os.Stderr, "Error: invalid --lng")
		os.Exit(1)
	}

	loc, err := time.LoadLocation(*tzName)
	if err != nil {
		fmt.Printf("Error loading timezone: %v\n", err)
		os.Exit(1)
	}

	now := time.Now().In(loc)
	date := time.Date(
		now.Year(),
		now.Month(),
		now.Day(),
		0, 0, 0, 0,
		time.UTC,
	)

	sunriseTime := calculateSolarEvent(date, *lat, *lng, true)
	sunsetTime := calculateSolarEvent(date, *lat, *lng, false)

	srLocal := sunriseTime.In(loc)
	ssLocal := sunsetTime.In(loc)

	fmt.Printf("%s %s\n", srLocal.Format("15:04"), ssLocal.Format("15:04"))
}

func calculateSolarEvent(date time.Time, lat, lng float64, isSunrise bool) time.Time {
	// 1. Calculate the day of the year (N)
	N := float64(date.YearDay())

	// 2. Convert the longitude to hour value and calculate an approximate time
	lngHour := lng / 15.0
	var t float64
	if isSunrise {
		t = N + ((6.0 - lngHour) / 24.0)
	} else {
		t = N + ((18.0 - lngHour) / 24.0)
	}

	// 3. Calculate the Sun's mean anomaly
	M := (0.9856 * t) - 3.289

	// 4. Calculate the Sun's true longitude
	L := M + (1.916 * math.Sin(M*D2R)) + (0.020 * math.Sin(2*M*D2R)) + 282.634
	// Normalize L to [0, 360)
	L = math.Mod(L, 360.0)
	if L < 0 {
		L += 360.0
	}

	// 5. Calculate the Sun's right ascension
	RA := R2D * math.Atan(0.91764*math.Tan(L*D2R))
	// Normalize RA to [0, 360)
	RA = math.Mod(RA, 360.0)
	if RA < 0 {
		RA += 360.0
	}

	// Right ascension value needs to be in the same quadrant as L
	Lquadrant := math.Floor(L/90.0) * 90.0
	RAquadrant := math.Floor(RA/90.0) * 90.0
	RA = RA + (Lquadrant - RAquadrant)

	// RA results in degrees, convert to hours
	RA = RA / 15.0

	// 6. Calculate the Sun's declination
	sinDec := 0.39782 * math.Sin(L*D2R)
	cosDec := math.Cos(math.Asin(sinDec))

	// 7. Calculate the Sun's local hour angle
	cosH := (math.Cos(Zenith*D2R) - (sinDec * math.Sin(lat*D2R))) / (cosDec * math.Cos(lat*D2R))

	// Check for polar day/night (sun never rises or sets)
	// Strictly speaking, if cosH > 1, the sun never rises. If cosH < -1, the sun never sets.
	// For this CLI, we will clamp to handle math, but strictly this indicates "No Event"
	if cosH > 1 {
		// Sun never rises
		return time.Time{} // Return zero time
	}
	if cosH < -1 {
		// Sun never sets
		return time.Time{}
	}

	// Calculate H and convert into hours
	var H float64
	if isSunrise {
		H = 360.0 - R2D*math.Acos(cosH)
	} else {
		H = R2D * math.Acos(cosH)
	}
	H = H / 15.0

	// 8. Calculate local mean time of rising/setting
	T := H + RA - (0.06571 * t) - 6.622

	// 9. Adjust back to UTC
	UT := T - lngHour
	
	// Normalize UT to [0, 24)
	UT = math.Mod(UT, 24.0)
	if UT < 0 {
		UT += 24.0
	}

	// Convert the decimal UT hour to a Go Time object
	utcHour := int(UT)
	utcMinute := int((UT - float64(utcHour)) * 60)
	utcSecond := int((((UT - float64(utcHour)) * 60) - float64(utcMinute)) * 60)

	return time.Date(date.Year(), date.Month(), date.Day(), utcHour, utcMinute, utcSecond, 0, time.UTC)
}