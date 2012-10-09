These jars are needed by ant's optional tasks.
in order to make it work you have to either:
1) copy the jars into to ant plugin's lib directory, for example:
        -C:\eclipse-indigo\plugins\org.apache.ant_1.8.2.v20120109-1030\lib
2)copy into user's ant lib
        -C:\Users\{userName}\.ant\lib
3)Specify this directory on the command line with the -lib argument