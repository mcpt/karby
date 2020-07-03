# Karby
It sucks!

## Installation
First, clone this git repository into the home directory of a new user (`karby`).

Next, install dependencies by running `bundle install` in the root directory of the repository.

### Karby Server
To deploy the server copy the included service file `karby.service` to `/etc/systemd/system/`. Then run the following commands as root:
```sh
systemctl enable karby.service
systemctl start karby.service
```

You can check if the service is running with `systemctl status karby.service`.

#### Zerotier
If you want to run this over zerotier only, first change the `After` line in your service file to the following:
```
After=network-online.target zerotier-one.service
```
Then change the `BIND_ADDRESS` in your service file to your local zerotier ip.

### Karby Aggregator
Add the following line to the `karby` user's crontab to have each days logs aggregated:
```
0 6 * * * env PRE_AGGREGATION_DIR=/home/karby/temp POST_AGGREGATION_DIR=/home/karby/logs DESTROY_LOG_PARTS=FALSE ruby /home/karby/karby-aggregator.rb "$(date -d "yesterday 6:00" '+%Y-%m-%d')" >/dev/null 2>&1
```

If you want to destroy the part logs after the aggregation change `DESTROY_LOG_PARTS=TRUE` in the line above.

**Note:** This will aggregate the previous day's logs at 06:00 the next day.

## RVM
If using RVM to manage ruby versions, you will likely need to generate a wrapper script for the gems to be viewed properly (see [this page](https://rvm.io/integration/init-d)).
