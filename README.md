Dockerized [duplicity](http://duplicity.nongnu.org/) backup tool.

### Usage

#### Backup to Google Drive Example

Set up:

 1. Follow notes [on Pydrive Backend](http://duplicity.nongnu.org/duplicity.1.html#sect20) to generate a P12 credential file (call it `pydriveprivatekey.p12`) and note also the associated service account email generated (e.g. `duplicity@developer.gserviceaccount.com`).
 2. Convert P12 to PEM:

        $ docker run --rm -i --user $UID -v $PWD/pydriveprivatekey.p12:/pydriveprivatekey.p12:ro wernight/duplicity openssl pkcs12 -in /pydriveprivatekey.p12 -nodes -nocerts > pydriveprivatekey.pem
        Enter Import Password: notasecret

Now you're ready to perform a backup:

    $ docker run --rm --user $UID -v /:/data:ro -e PASSPHRASE=P4ssw0rd -e GOOGLE_DRIVE_ACCOUNT_KEY=$(cat pydriveprivatekey.pem) duplicity duplicity /data pydrive://duplicity@developer.gserviceaccount.com/some_dir

To restore, you'll need:

  * Regenerate a PEM file (or keep it somewhere)
  * The `PASSPHRASE` you've used.

#### Backup via rsync Example

**TODO**


#### Help

See also [duplicity man](http://duplicity.nongnu.org/duplicity.1.html) page and you can also do:

    $ docker run --rm wernight/duplicity duplicity --help
