# Setting up Supplejack

This guide is about setting up the Supplejack stack (API, Worker and Manager).

### Prerequisites
* The MongoDB database is running.
* Deployed Supplejack, API and Worker successfully using Webistrano.
* Supplejack, Worker and API are accessible on the browser.

## Supplejack and Worker

In order for the Supplejack to work properly, it requires the Worker for processing background jobs.

1. Check the Supplejack's `application.yml`. You can locate this on the node/server where it is deployed.
2. Make sure that the `WORKER_HOST` points to the correct URL or the Worker and the `WORKER_API_KEY` is correct.
3. To check the `WORKER_API_KEY`, run the Rails console in the Worker and check if there's a user `User.first`. Make sure that the user key matches the `WORKER_API_KEY`. If they're not matched, update the user:

```bash
irb(main):001:0> u = User.first
=> #<User _id: 52e6e1ada08f77f111000001, authentication_token: "rq6umzbPzPztcefxC8sX">
irb(main):002:0> u.authentication_token = "WORKER_API_KEY here"
=> "WORKER_API_KEY here"
irb(main):003:0> u.save
```

We also need to modify the `application.yml` file of the Worker to match the `MANAGER_HOST` and `MANAGER_API_KEY`.

1. Make sure that `MANAGER_HOST` points to the correct URL of the Supplejack and the `MANAGER_API_KEY` is correct.

```bash
irb(main):001:0> User.first
=> #<User _id: ... authentication_token: "n3V1GLzp5nz4mgyQrGB3">
```

Update the user's `authentication_token` using the `MANAGER_API_KEY` from the `application.yml`.

## API

The API stores the records that comes from the Worker. Both Supplejack and Worker connects to API. Make sure that both `API_HOST` in the `application.yml` file of Supplejack and Worker points to the correct URL of the API.

The API allows requests from SuppleJack and Worker in a route constraint. Check the API's `application.yml` file and make sure that the IP address where the Supplejack and Worker are deployed are listed in `HARVESTER_IPS`. Update the file in Chef to include the IP.

In order to view results from the API using browser, you need to have an API key from a user. Create a user using API Rails console:

```bash
[1] pry(main)> u = User.new
=> #<User _id: ... >
[2] pry(main)> u.save
=> true
[3] pry(main)> u
=> #<User _id: ... authentication_token: "psDpfEGSG7x55rstpzow" >
```


