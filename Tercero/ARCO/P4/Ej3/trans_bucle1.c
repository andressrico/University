#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>


#include "arqo3.h"

void compute(tipo **matrix, tipo **mt, tipo **res,int n, int threads);
void transpose(tipo **matrix, tipo **mt, int n);

int main(int argc, char *argv[]) {
	int n, threads;
	tipo **m=NULL;
	tipo **mt=NULL;
	tipo **res=NULL;
	struct timeval fin, ini;

	if( argc!=3 )
	{
		printf("Error: ./%s <matrix size> <number of threads>\n", argv[0]);
		return -1;
	}
	threads=atoi(argv[2]);
	n=atoi(argv[1]);
	m=generateMatrix(n);
	if( !m )
	{
		return -1;
	}

	mt=generateEmptyMatrix(n);
	if( !m )
	{
		return -1;
	}

	res=generateEmptyMatrix(n);
	if( !res )
	{
		return -1;
	}

	

	gettimeofday(&ini,NULL);
	transpose(m,mt,n);
	
	/* Main computation */
	compute(m, mt, res, n, threads);
	/* End of computation */

	gettimeofday(&fin,NULL);
	printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	printf("Completado\n");
	


	free(m);
	free(res);
	return 0;


}

void transpose(tipo **matrix, tipo **mt, int n){
	int i, j;
	for(i=0;i<n;i++){
		for(j=0;j<n;j++){
			mt[j][i]=matrix[i][j];
		}
	}
}

void compute(tipo **matrix, tipo **mt, tipo **res, int n, int threads)
{
	int i,j,k,suma;
	
	omp_set_num_threads(threads);

	#pragma omp parallel for private(i,k)
	for(j=0;j<n;j++)
	{
		for(i=0;i<n;i++)
		{
			suma=0;
			for(k=0; k<n; k++){
				suma += matrix[j][k] * mt[i][k];
			}
			res[j][i] = suma;
		}
	}
	return;
}