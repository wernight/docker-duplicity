[![](https://images.microbadger.com/badges/image/wernight/duplicity.svg)](https://microbadger.com/images/wernight/duplicity "Get your own image badge on microbadger.com")

Dockerized **[duplicity](http://duplicity.nongnu.org/)** backup tool.

Features of this Docker image:

  * **Small**: Built using [alpine](https://hub.docker.com/_/alpine/).
  * **Simple**: Most common cases are explained below and require minimal setup.
  * **Secure**: Runs non-root by default (use randomly chosen UID `1896`), and meant to run as any user.


## Usage

For the general command-line syntax, do:

    $ docker run --rm wernight/duplicity duplicity --help

In general you...

  * Must mount what you want to backup or where you want to restore a backup.
  * Should mount `/home/duplicity/.cache/duplicity` as writable somewhere (if not cached, [duplicity will have to recreate it from the remote repository which may require decrypting the backup contents](http://duplicity.nongnu.org/duplicity.1.html#sect5)). Note it may be quite large and contains metadata info about files you've backed up in clear text.
  * Should mount `/home/duplicity/.gnupg` as writable somewhere (that directory is used to validate incremental backups and shouldn't be necessary to restore your backup if you follows steps below).
  * Should specify duplicity flag `--allow-source-mismatch` because Docker has a random host for each container.
  * Could set environment variable `PASSPHRASE`, unless you want to type it manually in the prompt (remember then to add `-it`).
  * May have to mount a few other files for authentication (see examples below).



### Backup to **Google Cloud Storage** example

**[Google Cloud Storage](https://cloud.google.com/storage/)** *nearline* [costs about $0.01/GB/Month](https://cloud.google.com/storage/pricing).

**Set up**:

 1. [Sign up, create an empty project, enable billing, and create a *bucket*](https://cloud.google.com/storage/docs/getting-started-console)
 2. Under ["Storage" section > "Settings"](https://console.cloud.google.com/project/_/compute/storage/settings) > "Interoperability" tab > click "Enable interoperable access" and then "Create a new key" button and note both *Access Key*	and *Secret*. Also note your *Project Number* (aka project ID, it's a number like 1233457890).
 3. Run [gcloud's `gsutil config -a`](https://cloud.google.com/storage/docs/getting-started-gsutil) to generate the `~/.boto` configuration file and give it all these info (alternatively you should be able to set environment variable `GS_ACCESS_KEY_ID` and `GS_SECRET_ACCESS_KEY` however in my tries I didn't see where to set your project ID).
 4. You should now have a `~/.boto` looking like:

        [Credentials]
        gs_access_key_id = MYGOOGLEACCESSKEY
        gs_secret_access_key = SomeVeryLongAccessKeyXXXXXXXX
    
        [GSUtil]
        default_project_id = 1233457890

Now you're ready to perform a **backup**:

    $ docker run --rm --user $UID \
          -e PASSPHRASE=P4ssw0rd \
          -v $PWD/.cache:/home/duplicity/.cache/duplicity \
          -v $PWD/.gnupg:/home/duplicity/.gnupg \
          -v ~/.boto:/home/duplicity/.boto:ro \
          -v /:/data:ro \
          wernight/duplicity \
          duplicity --allow-source-mismatch /data gs://my-bucket-name/some_dir

To **restore**, you'll need:

  * Keep `.boto` or regenerate it to access your Google Cloud Storage.
  * The `PASSPHRASE` you've used.

    $ docker run --rm --user $UID \
          -e PASSPHRASE=P4ssw0rd \
          -v ~/.boto:/home/duplicity/.boto:ro \
          -v /:/data:ro \
          wernight/duplicity \
          duplicity gs://my-bucket-name/some_dir /data
          
See also the [note on Google Cloud Storage](http://duplicity.nongnu.org/duplicity.1.html#sect15).


### Backup to **Google Drive** example

**[Google Drive](https://drive.google.com/)** offers [15GB for free](https://support.google.com/drive/answer/2375123).

**Set up**:

 1. Follow notes [on Pydrive Backend](http://duplicity.nongnu.org/duplicity.1.html#sect20) to generate a P12 credential file (call it `pydriveprivatekey.p12`) and note also the associated service account email generated (e.g. `duplicity@developer.gserviceaccount.com`).
 2. Convert P12 to PEM:

        $ docker run --rm -i --user $UID \
              -v $PWD/pydriveprivatekey.p12:/pydriveprivatekey.p12:ro \
              wernight/duplicity \
              openssl pkcs12 -in /pydriveprivatekey.p12 -nodes -nocerts >pydriveprivatekey.pem
        Enter Import Password: notasecret

Now you're ready to perform a **backup**:

    $ docker run --rm --user $UID \
          -e PASSPHRASE=P4ssw0rd \
          -e GOOGLE_DRIVE_ACCOUNT_KEY=$(cat pydriveprivatekey.pem) \
          -v $PWD/.cache:/home/duplicity/.cache/duplicity \
          -v $PWD/.gnupg:/home/duplicity/.gnupg \
          -v /:/data:ro \
          wernight/duplicity \
          duplicity --allow-source-mismatch /data pydrive://duplicity@developer.gserviceaccount.com/some_dir

To **restore**, you'll need:

  * Regenerate a PEM file (or keep it somewhere).
  * The `PASSPHRASE` you've used.

### Backup via **rsync** example

Supposing you've an **SSH** access to some machine, you can:

    $ docker run --rm -it --user root \
          -e PASSPHRASE=P4ssw0rd \
          -v $PWD/.cache:/home/duplicity/.cache/duplicity \
          -v $PWD/.gnupg:/home/duplicity/.gnupg \
          -v ~/.ssh/id_rsa:/id_rsa:ro \
          -v ~/.ssh/known_hosts:/etc/ssh/ssh_known_hosts:ro \
          -v /:/data:ro \
          wernight/duplicity \
          duplicity --allow-source-mismatch --rsync-options='-e "ssh -i /id_rsa"' /data rsync://user@example.com/some_dir

Note: We're running here as `root` to have access to `~/.ssh` and also because ssh does not
allow to use a random (non-locally existing) UID. To make it safer, you can copy your `~/.ssh`
and `chown 1896` it (that is `duplicity` UID within the container). If you know a another way to avoid
the "No user exists for uid" check, please let me know.


### Alias

Here is a simple alias that should work in most cases:

    $ alias duplicity='docker run --rm --user=root -v ~/.ssh/id_rsa:/home/duplicity/.ssh/id_rsa:ro -v ~/.boto:/home/duplicity/.boto:ro -v ~/.gnupg:/home/duplicity/.gnupg -v /:/mnt:ro -e PASSPHRASE=$PASSPHRASE wernight/duplicity duplicity $@'

Now you should be able to run duplicity almost as if it were installed, example:

    $ PASSPHRASE=123456 duplicity --progress /mnt rsync://user@example.com/some_dir


## See also

  * [duplicity man](http://duplicity.nongnu.org/duplicity.1.html) page
  * [duplicity back-up how-to - Ubuntu](https://help.ubuntu.com/community/DuplicityBackupHowto)
  * [How To Use Duplicity with GPG to Securely Automate Backups on Ubuntu | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-duplicity-with-gpg-to-securely-automate-backups-on-ubuntu)


## Feedbacks

Report issues/questions/feature requests on [GitHub Issues](https://github.com/wernight/docker-duplicity/issues).
