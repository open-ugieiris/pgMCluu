## Name
pgMCluu

## Description
pgMCluu is a management overlay developed in bash scripts of the tool [pgCluu](http://pgcluu.darold.net/) (&copy; Gilles Darold).  
pgMCluu stand for PostGresql Multiple CLUsters Utilization.  
It allows multi-instances configuration, a beginning of Information Lyfecycle Management, and management by Linux services.
It has been developed in 2015 to extend pgcluu's features to fit U GIE IRIS organisation's needs. It was version 2.4 of pgcluu (2015-07-25).  
As more features seems to be progressively included in pgCluu project itself, we hope pgMCluu will have soon no more reasons to exist.  
No fork and no contributings (yet ?) have been made to the original pgCluu project. 

## Resources
pgMCluu is intended to be used with pgCluu 2.4 only.  
pgMCluu does not include any part of pgCluu, pgCluu must be installed as a prerequisite for pgMCluu to be able to work. 
pgMCluu has been tested with Red Hat Enterprise Linux 6.
		
## Requirements
* a modern version of perl
* pgcluu 2.4 (only this version has been tested. It may work with the new version of pgcluu 2.5 but it has not been tested yet... tell us !)

## Installation
- Install perl (as root)

```
$ yum install perl
```

- Install [pgcluu](https://github.com/darold/pgcluu/)  
- Copy `pgmcluu\*` into `/var/lib/pgsql/pgcluu/`  

- Modify privileges

```
$ chown -R postgres:postgres /var/lib/pgsql/pgcluu/
```

### Configure pgMCluu

- Configure `/var/lib/pgsql/pgcluu/conf/pgcluu.conf`  

- Configure `.pgpass` file of `postgres` user, with credentials of users added in `pgcluu.conf`  

### Configure ssh passwordless

```
$ su - postgres
$ ssh-keygen -t rsa
$ cat .ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAA(...)9gvpw7PTzYQ== postgres@pgmcluuserver
```  

- For every remote postgresql server you want to monitore:  
```
$ ssh-copy-id -i ~/.ssh/id_rsa.pub pgserver`
```

- Test:
```
$ ssh postgres@pgserver date
Thu Sep 10 15:59:31 CEST 2015
```

### Configure pgMCluu as a daemon:

- Copy `pgmcluu\etc\init.d\pgcluu` into `/etc/init.d`  

```
$ chmod 0755 /etc/init.d/pgcluu  
$ service pgcluu start  
$ chmod +x /var/lib/pgsql/pgcluu/data2html.sh  
$ /var/lib/pgsql/pgcluu/data2html.sh  
$ yum install httpd  
```

- Copy `pgmcluu\etc\httpd\conf.d\pgcluu.conf` into `/etc/httpd/conf.d/pgcluu.conf`  

- Start httpd service :
```
$ service httpd start  
$ chkconfig httpd on
```  

- Test : http://pgmcluuserver/pgcluu/  

### Cron configuration

With `crontab -e`, add content of `pgmcluu\var\spool\cron\root` to root 's crontab  

## Credits
Many thanks to Gilles Darold for pgCluu, which provides very useful value to postgresql tools community.  

## License
See [LICENSE](LICENSE)

```
Copyright (c) 2017, U GIE IRIS
Scripts initially developed by Tony LEGEAY  

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose, without fee, and without a written agreement is
hereby granted, provided that the above copyright notice and this paragraph
and the following two paragraphs appear in all copies.

IN NO EVENT SHALL U GIE IRIS BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING
OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF U GIE IRIS 
HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

U GIE IRIS SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND U GIE
IRIS HAS NO OBLIGATIONS TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
ENHANCEMENTS, OR MODIFICATIONS.
```
