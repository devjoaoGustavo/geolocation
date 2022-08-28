# Geolocation

I configured the postgreSQL in order to accept 500 connections and set the
database connection pool to 400.

1. Develop a library/component with two main features:
  * A service that parses the CSV file containing the raw data and persists it in a database;
  * An interface to provide access to the geolocation data (model layer);
2. Develop a REST API that uses the aforementioned library to expose the geolocation data.

In doing so:

1. Define a data format suitable for the data contained in the CSV file;
2. Sanitise the entries: the file comes from an unreliable source, this means
   that the entries can be duplicated, may miss some value, the value can not
   be in the correct format or completely bogus;
3. At the end of the import process, return some statistics about the time
   elapsed, as well as the number of entries accepted/discarded;
4. The library should be configurable by an external configuration
   (particularly with regards to the DB configuration);
5. The API layer should implement a single HTTP endpoint that, given an IP
   address, returns information about the IP address' location (e.g. country,
   city).

## Expected outcome and shipping:

1. A library/component that packages the import service and the interface for
   accessing the geolocation data;
2. A REST API application that uses the aforementioned library.
3. The API application is Dockerised.

## What are the tradeoff

## How the app works

The app provides a rake task in order to import and persist the data from a given csv file or, by default, from the `public/data_dump.csv` file.
The ip locations data are persisted on `ip_locations` table, which has the following columns:
```
ip_address inet not null,
country_code string not null,
country string not null,
city string not null,
latitude bigdecimal not null,
longitude bigdecimal not null,
mystery_value bigint,
```

The rake task call the importer service that performs the data load and validation, generating as result a collection of valid arguments to be persisted.
In order to validate the data, the importer uses the validator service, which enforce that each hash of arguments hash the apropriated collection of valid data
THe validator returns a Boolean informing the caller that the given parameters are either valid or invalid

Being valid the argument, the importer will dispatch the batch creation of the ip location.

## How to setup the app

* Ruby version
3.1.2

* System dependencies
postgresql-devel
libpq-dev

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
