[![](https://badge.imagelayers.io/wernight/duplicity:latest.svg)](https://imagelayers.io/?images=wernight/duplicity:latest 'Get your own badge on imagelayers.io')

Dockerized **[duplicity](http://duplicity.nongnu.org/)** backup tool.

### Usage

#### Backup to Google Cloud Storage example

**[Google Cloud Storage](https://cloud.google.com/storage/)** *nearline* [costs about $0.01/GB/Month](https://cloud.google.com/storage/pricing).

**Set up**:

  1. [Sign up, create an empty project, enable billing, and create a *bucket*](https://cloud.google.com/storage/docs/getting-started-console)
  2. Under "Storage" section > "Interoperability" tab > click "Enable interoperable access" and then "Create a new key" button and note both *Access Key*	and *Secret*. Also note your *Project Number* (aka project ID, it's a number like 1233457890).
  3. Run [gcloud's `gsutil config -a`](https://cloud.google.com/storage/docs/getting-started-gsutil) to generate the `~/.boto` configuration file and give it all these info (alternatively you should be able to set environment variable `GS_ACCESS_KEY_ID` and `GS_SECRET_ACCESS_KEY` however in my tries I didn't see where to set your project ID).

You should now have a `~/.boto` looking like:

    [Credentials]
    gs_access_key_id = MYGOOGLEACCESSKEY
    gs_secret_access_key = SomeVeryLongAccessKeyXXXXXXXX
    
    [GSUtil]
    default_project_id = 1233457890

Now you're ready to perform a **backup**:

    $ docker run --rm --user $UID -v /:/data:ro -v ~/.boto:/home/duplicity/.boto:ro -e PASSPHRASE=P4ssw0rd duplicity duplicity /data gs://my-bucket-name/some_dir

To **restore**, you'll need:

  * Keep keys or regenerate them to access your Google Cloud Storage.
  * The `PASSPHRASE` you've used.

See also the [note on Google Cloud Storage](http://duplicity.nongnu.org/duplicity.1.html#sect15).


#### Backup to Google Drive example

**[Google Drive](https://drive.google.com/)** offers [15GB for free](https://support.google.com/drive/answer/2375123).

**Set up**:

 1. Follow notes [on Pydrive Backend](http://duplicity.nongnu.org/duplicity.1.html#sect20) to generate a P12 credential file (call it `pydriveprivatekey.p12`) and note also the associated service account email generated (e.g. `duplicity@developer.gserviceaccount.com`).
 2. Convert P12 to PEM:

        $ docker run --rm -i --user $UID -v $PWD/pydriveprivatekey.p12:/pydriveprivatekey.p12:ro wernight/duplicity openssl pkcs12 -in /pydriveprivatekey.p12 -nodes -nocerts > pydriveprivatekey.pem
        Enter Import Password: notasecret

Now you're ready to perform a **backup**:

    $ docker run --rm --user $UID -v /:/data:ro -e PASSPHRASE=P4ssw0rd -e GOOGLE_DRIVE_ACCOUNT_KEY=$(cat pydriveprivatekey.pem) duplicity duplicity /data pydrive://duplicity@developer.gserviceaccount.com/some_dir

To **restore**, you'll need:

  * Regenerate a PEM file (or keep it somewhere).
  * The `PASSPHRASE` you've used.

#### Backup via rsync example

**TODO**


#### More help

See also [duplicity man](http://duplicity.nongnu.org/duplicity.1.html) page and you can also do:

    $ docker run --rm wernight/duplicity duplicity --help

## Feedbacks

Report issues/questions/feature requests on [GitHub Issues][https://github.com/wernight/docker-duplicity/issues].
