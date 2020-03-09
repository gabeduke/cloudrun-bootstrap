# Cloudrun Bootstrap

This repo provides a bootstrap framework for cloudrun microservices

Each microservice has it's own state file and should be seeded by running `make import SERVICE_NAME=[my_service]`. This will import the DNS zone and any existing resources. Of course make sure to update any vars in the vars file or create a new one.

## Usage

```bash
SVC=my-service

# import any existing resources
make import SERVICE_NAME=${SVC}

# create the service and DNS mappings
make apply SERVICE_NAME=${SVC}

# destroy all except the DNS zone
make destroy SERVICE_NAME=${SVC}
```
