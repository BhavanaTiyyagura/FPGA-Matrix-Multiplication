Set the path to Vivado in build_linux.sh and build_windows.bat before running.

If you encounter the error 
ERROR: Project already exists on disk, please use '-force' option to overwrite
Open the lab2_matmul.tcl script in any text editor then check for create_project command. Now add -force option to this command i.e., create_project -force

Note that this will override all data in the project, so save before proceeding.

You can run the provided lab2_matmul.tcl script (either from Vivado or using 
one of the provided scripts if you are using a Windows or Linux machine to
recreate the project from scratch.

TCL scripts are a good way to interact with Vivado projects. One can for example
just store the source files and the script at a repository, and then use this
to build the project in a platform-independent way.

The following is a good read if you want to version control your Vivado projects:
http://www.fpgadeveloper.com/2014/08/version-control-for-vivado-projects.html

/Zafer <zafer.esen@it.uu.se>
/Yuan <yuan.yao@it.uu.se>