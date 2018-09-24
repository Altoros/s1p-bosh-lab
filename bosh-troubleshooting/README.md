# BOSH TROUBLESHOOTING

## Explore the BOSH VM folder structure

Let's take a look at the structure of the BOSH VM:

1. SSH to any BOSH VM with:
    ```exec
    bosh -d greeter ssh app/0
    ```

2. Make yourself root:
    ```exec
    sudo -i
    ```

3. Navigate to the root BOSH directory (`/var/vcap`) and explore its contents.

4. View all the installed jobs:
    ```exec
    cd /var/vcap/jobs/
    ```
    Select some job and explore its contents.

5. View all the installed packages:
    ```exec
    cd /var/vcap/packages
    ```
    Select some package and explore its contents.

6. View the Monit files:
    ```exec
    cd /var/vcap/monit
    ```
    Also view Monit status with:
    ```exec
    monit status
    monit summary
    ```

7. View the logs
    ```exec
    cd /var/vcap/sys/log
    ```

## Connect to the Director database

1.  SSH to a BOSH instance:
    ```exec
    bbl ssh --director
    ```
    or you could do the traditional method of looking at $BBL_STATE_DIRECTORY and looking in vars.
    You would have to either ssh directly to jumpbox then ssh to director or ssh with proxy parameters passed.
    [bbl ssh and bosh ssh](https://github.com/cloudfoundry/bosh-bootloader/blob/master/docs/howto-ssh.md)

2. Make yourself root:
    ```exec
    sudo -i
    ```

3. Install the PostgreSQL client:
    ```exec
    echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
    apt-get update
    apt-get install -y postgresql-client-9.6
    ```

4. Connect to the BOSH database:
    ```exec
    psql -h 127.0.0.1 -p 5432 bosh postgres
    ```

5. List all tables:
    ```exec
    \d
    ```
    Use the following command to exit the table list.
    ```exec
    \q
    ```

6. View the contents of the `releases` table:
    ```exec
    SELECT * FROM releases;
    ```

7. Use `\q` to exit the client.


## View the BOSH debug log

1. Find out the task number:
    ```exec
    bosh tasks
    ```

    For tasks that are have already been completed, use:
    ```exec
    bosh tasks --recent
    ```

2. View task info:
    ```
    bosh task <number>
    ```

3. View the task debug log:
    ```
    bosh task <number> --debug
    ```
