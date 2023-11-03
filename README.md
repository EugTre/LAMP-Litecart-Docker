# LAMP-Litecart-Docker

Dockerfile to build LAMP (Linux, Apache, MySQL, PHP) server with latest Litecart shop installed as single container for testing purposes.

#### This is unoffical and non-production setup!

Please note, that database is bundled and not accessable from the outside of a container, and by default container doesn't use persistent storage (volume). This means that when container stops all data will be dropped! 


### Installation

Download repository and put all files at the same directory, then run:
```
docker build litecart .
```

Once built - run container forwarding ports:
```
docker run -dp <IP>:80:80 litecart
```

Now access `<IP>:80` for Litecart frontend or `<IP>:80/admin` for admin backoffice (`:80` may be ommitted).

#### Credentials

Admin Backoffice: admin / secret 
Database: admin / secret
