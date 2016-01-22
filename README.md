Dockerized [duplicity](http://duplicity.nongnu.org/) backup tool.

### Usage

#### Backup via rsync Example

**TODO**

#### Backup to Google Drive Example

First follow notes [on Pydrive Backend](http://duplicity.nongnu.org/duplicity.1.html#sect20) to generate a P12 credential file (call it `pydriveprivatekey.p12`) and note also the associated service account email generated (e.g. `duplicity@developer.gserviceaccount.com`).

    $ docker run --rm -i --user $UID -v $PWD/pydriveprivatekey.p12:/pydriveprivatekey.p12:ro wernight/duplicity openssl pkcs12 -in /pydriveprivatekey.p12 -nodes -nocerts > pydriveprivatekey.pem
    Enter Import Password: notasecret
    $ docker run --rm --user $UID -v /:/data:ro -e PASSPHRASE=P4ssw0rd -e GOOGLE_DRIVE_ACCOUNT_KEY=$(cat pydriveprivatekey.pem) duplicity duplicity /data pydrive://duplicity@developer.gserviceaccount.com/some_dir

#### Help

See also [duplicity man](http://duplicity.nongnu.org/duplicity.1.html) page and you can also do:

    $ docker run --rm wernight/duplicity duplicity --help
