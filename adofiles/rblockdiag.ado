
* rblockdiag.ado  //repeating blockdiag
* number should be increment by 1. 

program rblockdiag
	args var start end
	mata: temp = st_matrix("`var'`start'")  // temp
	mata: i=`start'
	mata: n=`end'
	mata: while (++i<=n) temp=blockdiag(temp,st_matrix("`var'"+strofreal(i)))
	mata: st_matrix("blk`var'",temp)
end 


/* Example

clear mata
mata
	A1 = (1,2 \ 3,4)
	A2 = (5,6 \ 7,8)
	A3 = (9,10 \ 11,12)
	A4 = (13,14 \ 15,16)

	st_matrix("A1",A1)
	st_matrix("A2",A2)
	st_matrix("A3",A3)
	st_matrix("A4",A4)
end

rblockdiag A 1 4 



*/
