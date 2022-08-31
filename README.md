# Geolocation

This service provides an API for searching the geolocation of a given IP address.

## How the app works

The application has two features, an IP location importer and a HTTP API for searching IP locations.

### The IP location data importer

In order to provide the locations through an API the service expects the data
to be imported somehow. There are two way to do so, the first one is by
calling the importer service directly via rails console (`bin/rails c`). It's
not recommended as the service already provides a simpler interface.
```ruby
Locations::Importer
  .new(validator: Locations::Validator, persistence: IpLocation)
  .import_from_csv_file('public/data_dump.csv')
```

The seconds and simpler way is via rake task

```shell
bin/rails data:import_from_csv_file
```
The expected outputs of this command are something like this:
```
[Rake task] importing data from /home/user/Projects/geolocation/public/data_dump.csv...
checking and storing...
        45.61293563199979 seconds to validate
        70.36877059100152 seconds to persist
===================================================
Time Elapsed:           115.98174604300038 seconds.
Records accepted:       866449.
Records discarted:      133551.
===================================================
[Rake task] completed in 116.16331850899951 seconds
```

Both of them accepts a CSV file path as input and expect its content to be in the
following format in order to perform the data load operation properly:

```csv
ip_address,country_code,country,city,latitude,longitude,mystery_value
200.106.141.15,SI,Nepal,DuBuquemouth,-84.87503094689836,7.206435933364332,7823011346
160.103.7.140,CZ,Nicaragua,New Neva,-68.31023296602508,-37.62435199624531,7301823115
70.95.73.73,TL,Saudi Arabia,Gradymouth,-49.16675918861615,-86.05920084416894,2559997162
,PY,Falkland Islands (Malvinas),,75.41685191518815,-144.6943217219469,0
125.159.20.54,LI,Guyana,Port Karson,-78.2274228596799,-163.26218895343357,1337885276
```

If no arguments were given to the rake task, it will take the following file path by default;
```ruby
Rails.root.join('public/data_dump.csv')
```

### The HTTP API for searching IP location.

The requests can be done locally by running the following:

```
curl 'http://localhost:3000/api/v1/ip_locations?ip_address=125.159.20.54' | python -m json.tool
```

#### HTTP/1.1 200 OK

In the case of the location be found, the expected response follows this format:

```json
{
    "ip_location": {
        "ip_address": "125.159.20.54",
        "city": "Port Karson",
        "country": "Guyana",
        "country_code": "LI",
        "latitude": -78.2274228596799,
        "longitude": -163.26218895343357,
        "mystery_value": 1337885276
    }
}
```

However, often things goes wrong, so that the service tries to catch two failure scenarios.

#### HTTP/1.1 404 Not Found

If the IP location hasn't been imported to the service yet

```
curl 'http://localhost:3000/api/v1/ip_locations?ip_address=125.159.20.5' | python -m json.tool
```

The following response is expected:

```json
{
    "error": {
        "message": "No location found for `ip_address`: 125.159.20.5."
    }
}
```

#### HTTP/1.1 422 Unprocessable Entity

In the case the `ip_address` parameter contains an invalid value

```
curl 'http://localhost:3000/api/v1/ip_locations?ip_address=125.159205' | python -m json.tool
```

The following response is expected instead:

```json
{
    "error": {
        "message": "`ip_address`: 125.159205 is an invalid IP Address."
    }
}
```

The absence of the `ip_address` is considered an invalid value

```
curl 'http://localhost:3000/api/v1/ip_locations' | python -m json.tool
```

And wil result in:

```json
{
    "error": {
        "message": "`ip_address`: nil is an invalid IP Address."
    }
}
```

## Tradeoffs

TODO...

## How to setup the app

* Ruby version
3.1.2

* System dependencies
[docker](https://docs.docker.com/engine/install/)

* Configuration

Things with docker are very simple, so it's enough to run

```
docker compose up
```

in order to have the API server up and running

* Database creation

The setup of the database can done by run

```
docker compose exec -it app bin/rails db:prepare
```

* How to run the test suite

Simple like this:

```
docker compose exec -it app rspec
```

* Deployment instructions

TODO...
