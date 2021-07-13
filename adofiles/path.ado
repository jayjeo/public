program path
args vname
	if inlist("`vname'","home","Home","game","Game"){
	global path "C:\Users\acube\Dropbox\"
	}
	else if inlist("`vname'","laptop","lap","Laptop","x1","X1"){
	global path "C:\Users\acube\Dropbox\" 
	}
	else{
	display "Set cd manually"
	}
end

/*
program path
args vname
	if inlist("`vname'","home","Home"){
	cd "E:\Dropbox\Study\"
	}
	else if inlist("`vname'","laptop","lap","Laptop","x1","X1"){
	cd "C:\Users\acubens_X1\Dropbox\Study\" 
	}
	else{
	display "Set cd manually"
	}
end
*/

/*
If you want to reset a system directory permanently, 
place the sysdir set command in your profile.do; 
see [GSW] B.3 Executing commands every time Stata is started,
*/
