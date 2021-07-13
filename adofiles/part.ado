program part
	args C
	mata: part("`C'")
end

mata
real matrix part(string scalar B)
{
	real matrix A
	real matrix start
	real matrix schidknsize
	real scalar i
	real scalar j
	real scalar q
	real scalar n
	real matrix D
	string scalar E
	
	A = st_matrix(B)
	start = st_matrix("start")
	schidknsize = st_matrix("schidknsize")
	i=0
	j=1
	q=1
	n=rows(A)
	while (++i<=n) {	
		if (start[i]==1) {
			j=i+schidknsize[i]-1	
			st_matrix(B+strofreal(q),A[i..j,.])
			D=A[i..j,.]
			E=strtoname(B+strofreal(q))
			rename D E
			q=q+1
		}
		else j=1
	}
}
end


/*
B+strofreal(q)
			tempvar= "strtoname(X3)"
			st_local("D",tempvar)
			

*/

/*
real matrix part(real matrix A)
{
	A = st_matrix("A")
	start = st_matrix("start")
	schidknsize = st_matrix("schidknsize")
	i=0
	j=1
	q=1
	
	n=rows(A)
	while (++i<=n) {	
		if (start[i]==1) {
			j=i+schidknsize[i]-1	
			st_matrix("A"+strofreal(q),A[i..j,.])
			st_local(p, "A"+strofreal(q))
			$p = A[i..j,.]
			q=q+1
		}
		else j=1
	}
}






mata
	`1' = st_matrix("`1'")
	start = st_matrix("start")
	schidknsize = st_matrix("schidknsize")
	i=0
	j=1
	q=1
	n=rows(`1')
	while (++i<=n) {	
		if (start[i]==1) {
			j=i+schidknsize[i]-1	
			st_matrix("`1'"+strofreal(q++),`1'[i..j,.])
		}
		else j=1
	}
end
*/
