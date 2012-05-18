Quick setup for developers
==========================

1) You will need to have the following on your machine:
    SVN
    postgresql 8.4
    ant 1.7.x
    jdk 1.5
    tomcat 6.0.xx (Might work for 5.5.20 version, did not get a chance to test on this, it is always better to use latest version.)

2) Setting up database:
    a. install Postgres 8.4
	b. use pgAdmin (GUI) to create fbdev user (role)
	c. Create FormBuilder database
	d. Set FormBuilder database owner to fbdev user
	e. run db creation script from source code (src/main/db/FormBuilder-db-backup.sql) and from src\main\db\ddls
	f. modify fbdev search path (this is needed for SQL not to have to use schema name)
		ALTER ROLE fbdev SET search_path TO 'FormBuilder','public';

3) Configure your local build settings in ${workspace}/local-build.properties. The
   properties to pay attention to are:
    java.home=/System/Library/Frameworks/JavaVM.framework/Versions/1.5.0/Home
    tomcat.java.home=/System/Library/Frameworks/JavaVM.framework/Versions/1.5.0/Home
    tomcat.dir=../How2Tools/apache-tomcat-6.0.26
    ...
    # if you had setup your database differently than above
    hibernate.connection.username=fbdev
    hibernate.connection.password=fbdev
    hibernate.schema=FormBuilder

4) Buillding and running the project. The following targets are useful from a
developer's perspective.
    Initially:
      ant -Dfast.build=1 -Dtarget.context=<your context> all
      ant tomcat-start
      You now should be able to see the web site at something like:
        http://localhost:8080/
    Modifying JSPs (no need to restart the server):
      ant copy-to-deploy
      reload the web page
    Modification to a controller:
      ant all
      ant tomcat-start


Additional notes:
* Don't commit changes to cvs if your local build is broken
* Provide a brief commit message that explains why/what the changes you just
  committed do.
* Happy coding :-)