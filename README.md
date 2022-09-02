# Geolocation

This service provides an API for searching the geolocation of a given IP address.

## How the app works

The application has two features, an IP location importer and a HTTP API for searching IP locations.

### The IP location data importer

In order to provide the locations through an API the service expects the data
to be imported somehow. There are two way to do so, the first one is by calling
the importer service directly via rails console. It's not recommended as there
is a rake task that provides a simpler interface.

```ruby
# docker compose run -it app bin/rails c

Locations::Importer
  .new(validator: Locations::Validator, persistence: IpLocation)
  .import_from_csv_file('public/data_dump.csv')
```

The following command can be used to execute the rake task that import the data
from the csv file. By default it will import the data from `public/data_dump.csv`.

```shell
docker compose run app bin/rails data:import_from_csv_file
```

The task will print out some informations regarding the execution time and
statistics about the rake task execution.

```
Importing data
validating...
persisting...
done.
===================================================
Time Elapsed: 107.83850705300574 seconds
        Validation: 26.08323292498244 seconds
        Persistence: 81.75525469798595 seconds
Records processed: 949844
        Accepted: 866449
        Discarted: 83395
===================================================
[Rake task] completed in 108.16110226599267 seconds
```

Both of them accepts a CSV file path as input and expects its content to be in the
following format in order to perform the data load operation properly:

```csv
ip_address,country_code,country,city,latitude,longitude,mystery_value
200.106.141.15,SI,Nepal,DuBuquemouth,-84.87503094689836,7.206435933364332,7823011346
160.103.7.140,CZ,Nicaragua,New Neva,-68.31023296602508,-37.62435199624531,7301823115
70.95.73.73,TL,Saudi Arabia,Gradymouth,-49.16675918861615,-86.05920084416894,2559997162
,PY,Falkland Islands (Malvinas),,75.41685191518815,-144.6943217219469,0
125.159.20.54,LI,Guyana,Port Karson,-78.2274228596799,-163.26218895343357,1337885276
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

However, often things goes wrong, in those cases the service tries to catch two failure scenarios.

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

### Importing with CSV.foreach

Ruby's Standard library offers a gem called CSV which provides a method called
`foreach` capable of open a stream from the file in order to process each line
individually instead of load the whole file to memory before hand.

### Validation separately from ActiverRecord

As the CSV file's source isn't reliable, it's necessary to validate the data
before persisting it. ActiveRecord offers a rich API for validation, but its
validation rules are applied to model instances, which requires the importer to
instantiate each record in order to validate it, making the import operation
prohibitively slow. Hence, it implements a simple validator object that relies
on CSV lines format instead of model instances, eliminating the need for object
instantiation.

### Persistence using insert_all

The number of ip locations in the provided file is huge, so that each location
being persisted one by one would cause the application to do a lot of round
trips to the database, which would take too long for persisting all the records.
The decision here was to persist them all together. The implementation relies on
ActiverRecord API that provides a very handy method called `insert_all` that
builds a single SQL statement in order to insert all the given records.
It was tried to persit the data in batches, executing a few amount of
`insert_all` calls, but there was no improvement in the performance. Maybe if
the collection were bigger, the batch approach would be viable, but for
now the solution adopted was simpler to implement.
Another alternative would be creating a a thread for each batch and execute the
`insert_all` call from them. It also was tried, but the the problem was that
the threads executed database calls concurrently, and the constraints of the
database table seems to have become the bottleneck, as it had to assure
uniqueness of primary key, or something else that wasn't fully understood.

## How to setup the app

* System dependencies
[docker](https://docs.docker.com/engine/install/)

It's enough to have the `docker` and `docker compose` installed on local machine to
run this application.

Execute the following command in order to run the Rails server
```
docker compose up
```

* Database creation

The setup of the database can done by run

```
docker compose exec -it app bin/rails db:prepare
```

* How to run the test suite

Simple like this:

```
docker compose run app 'bin/rails db:environment:test RAILS_ENV=test && rspec'
```
