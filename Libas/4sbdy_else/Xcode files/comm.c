/* 
	comm.c -- source for Matlab MEX file. Matlab interface to the serial ports
					Tom L. Davis
					created 3-27-04
 MATLAB calls:
 	
             comm( 'open', port [, config] )	% configuration defaults to "19200,n,8,1"
			 comm( 'status', port );			% print port status
			 comm( 'hshake', port, type );		% set serial handshake
		 	 comm( 'purge',  port );			% purge read and write buffers
			 comm( 'break', port );				% send a break
    array  = comm( 'read', port [, cnt ] );		% read upto CNT unsigned bytes
    string = comm( 'readl', port [,eol] );		% read one ASCII line
             comm( 'write', port, string );		% write ASCII string
             comm( 'close', port );
             
	$Id: comm.c,v 1.1.1.1 2004/05/18 15:02:25 tom Exp $
*/


#include "serialPort.h"
#include <stdlib.h>
#include <ctype.h>

#define STRLEN 4096			// size of the read and write buffers (increase if necessary).


// selector numbers

enum {
	OPEN_=1,		// open & close must be first two entries
	CLOSE_,
	READ_,
	READL_,
	WRITE_,
    PURGE_,
    BREAK_,
	HSHAKE_,
	STATUS_
};

typedef struct {
	char	name[12];					// selector name
	int		index;						// selector number
} func_info;




// Default port info (add more elements if you need more ports)
//
static PORTINFO portInfo[] = {
	{ -1, NULL, 0, 0xA, "" },
	{ -1, NULL, 0, 0xA, "" },
	{ -1, NULL, 0, 0xA, "" },
	{ -1, NULL, 0, 0xA, "" },
	{ -1, NULL, 0, 0xA, "" },
	{ -1, NULL, 0, 0xA, "" },
	{ -1, NULL, 0, 0xA, "" },
	{ -1, NULL, 0, 0xA, "" }
};


static func_info func[] = {
	{ "read",	 	READ_	},
	{ "readl",	 	READL_	},
	{ "write", 		WRITE_	},
	{ "status",	 	STATUS_ },
 	{ "purge", 		PURGE_	},
 	{ "break", 		BREAK_	},
	{ "open",	 	OPEN_   },
	{ "close", 		CLOSE_	},
 	{ "hshake", 	HSHAKE_	},
	{ "", 			0	}
};

static char		*string = NULL;



// Close all ports if COMM gets cleared or MATLAB exits
//
static void die( void )
{
	int		port;
	
	// mexPrintf( "COMM 'die'\n" );
	if( string != NULL ) {
		free(string);
		string = NULL;
	}
    for( port=0; port<sizeof(portInfo)/sizeof(PORTINFO); port++ ) {
		if( portInfo[port].fd != -1 ) {
			closeSerialPort( &portInfo[port] );
			portInfo[port].fd = -1;
			free( portInfo[port].readBufferPtr );
			portInfo[port].readBufferPtr = NULL;
		}
    }	
}




void mexFunction(
        int 			nlhs,
        mxArray  		*plhs[],
        int 			nrhs,
        const mxArray	*prhs[]
    )
{
    ssize_t		numBytes;		// Number of bytes read or written
    long		i, cnt, str_cnt;
	int			n, port;
	PORTINFO	*p;
	double		*x;
 	int			dims[2] = { 0, 1 };
	char		*str = 0;
	char		op[16];
	

    // Check for at least two input arguments

    if( nrhs < 2 ){
        mexErrMsgTxt("COMM: requires at least two input arguments.");
    }

	// Read selector

	if( mxGetString( prhs[0], op, sizeof(op) ) ) {
        mexErrMsgTxt("COMM: bad first argument.");
	}

    // Read port number

	port = (int) mxGetScalar( prhs[1] ) - 1; 
	if( (port<0) | (port>sizeof(portInfo)/sizeof(PORTINFO)) ) {
		mexErrMsgTxt( "COMM: port number out of range.\n" );
	}
	p = &portInfo[port];
	
	
	// Find selector
	
	for( i=0; i<sizeof(func)/sizeof(func_info)-1; i++ ) {
		if( strcmp( op, func[i].name ) == 0 ) {
			break;
		}
	}

	if( (p->fd == -1) & (func[i].index>CLOSE_) ) {
    	mexErrMsgTxt("COMM: device not open.");
	}

	switch( func[i].index ) {


    // ******************************* OPEN *********************************
    //		
	//	comm( 'open', port )			% port configuration defaults to "19200,n,8,1"
	//	comm( 'open', port, config )	% use CONFIG value for port configuration (see
	//									% 'comm.m' for legal values of CONFIG.)

	case OPEN_:

	    if( nrhs < 2 ){
  	    	mexErrMsgTxt("COMM('OPEN'): requires at two input arguments.");
 	    }

		
		if( p->fd != -1 ) {
			mexPrintf( "COMM('OPEN'): port %d already open.\n", port+1 );
			return;
		}

		// setup the string buffer
		//
		if( string == NULL ) {
			string = calloc( STRLEN, sizeof(char) );
			if( string == 0 ) {
				mexErrMsgTxt("COMM('OPEN'): string buffer allocation failed.");
			}
	    }
		
		// setup the read buffer
		//
	    p->readBufferPtr = calloc( STRLEN, sizeof(char) );
	    if( p->readBufferPtr == 0 ) {
			mexErrMsgTxt("COMM('OPEN'): working buffer allocation failed.");
	    }
	    
		
		// configure the port
		//
		{
			char	configStr[16] = "19200,n,8,1";
			if( nrhs == 3 ) {
				if( mxGetString( prhs[2], configStr, sizeof(configStr) ) ) {
					mexErrMsgTxt("COMM('OPEN'): bad third argument.");
				}
			}
			
			if( openSerialPort( port, p, configStr ) ) {
				mexErrMsgTxt("COMM('OPEN'): could not open port.");
			}
		}

       // register an exit routine

		if( mexAtExit( die ) != 0 ) {
			die();
			mexErrMsgTxt("COMM('OPEN'): failed to register exit routine.");
	    }
	    
	    p->str_cnt = 0;
		mexPrintf( "Opened device: '%s'\n", p->bsdPath );
		return;


    // ******************************* STATUS **********************************
	//
	//	comm( 'status', port );			% print port status

    case STATUS_:

 		if( nrhs != 2 ){
			mexErrMsgTxt("COMM('STATUS'): requires two input arguments.");
		}


		if( portStatus( p ) ) {
			mexErrMsgTxt("COMM('STATUS'):failed.");
		}

		return;
		

    // ******************************* BREAK **********************************
	//
	//	comm( 'break', port );				% send a break

    case BREAK_:

		if( nrhs != 2 ){
			mexErrMsgTxt("COMM('BREAK'): requires two input arguments.");
		}

		if( sendBreak( p ) ) {
			mexErrMsgTxt("COMM('BREAK'):failed.");
		}

		// flush read/write queues
		//
		if( flushPort( p ) ) {
			mexErrMsgTxt("COMM('BREAK'): port purge failed.");
		}
		p->str_cnt = 0;

		return;

		
    // ******************************* HSHAKE **********************************
	//
	//	comm( 'hshake', port, type );		% set serial handshake

    case HSHAKE_:

 		if( nrhs != 3 ){
			mexErrMsgTxt("COMM('HSHAKE'): requires three input arguments.");
		}

		if( mxGetString( prhs[2], string, STRLEN ) ) {
			mexErrMsgTxt("COMM('HSHAKE'): bad third argument.");
		}


		// Setup handshaking
		//
		if( setHandshake( p, string ) ) {
			mexErrMsgTxt("COMM('HSHAKE'): failed.");
		}


		// flush read/write queues
		//
		if( flushPort( p ) ) {
			mexErrMsgTxt("COMM('HSHAKE'): port purge failed.");
		}
		p->str_cnt = 0;

		return;

		
    // ******************************* PURGE **********************************
	//
	//	comm( 'purge', port );			% purge read and write buffers

    case PURGE_:

 		if( nrhs != 2 ){
			mexErrMsgTxt("COMM('PURGE'): requires two input arguments.");
		}

		// flush read/write queues
		//
		if( flushPort( p ) ) {
			mexErrMsgTxt("COMM('PURGE'): port purge failed.");
		}
		p->str_cnt = 0;

		return;


	// ******************************* READ **********************************
	//
	//	data = comm( 'read', port );		% Binary read of everything in buffer
	//	data = comm( 'read', port, cnt );	% Binary read of upto CNT bytes

	case READ_:

	    if( nrhs < 2 ) {
  	    	mexErrMsgTxt("COMM('READ'): requires at least two input arguments.");
 	    }
		
		
		// find out how many bytes we should try to read
		//
	    if( nrhs == 3 ) {
			cnt = (long) mxGetScalar( prhs[2] );
			cnt = MIN( cnt, STRLEN-p->str_cnt );
 	    } else {
			cnt = STRLEN-p->str_cnt;
 	    }
		
		
		// read the port into the read buffer
		//
		numBytes = read( p->fd, &p->readBufferPtr[p->str_cnt], cnt );
		if( numBytes == -1 )
		{
			mexPrintf("Error reading serial port - %s(%d).\n", strerror(errno), errno);
			mexErrMsgTxt("COMM('READ'): device read failed.");
		}
		p->str_cnt += numBytes;


   		// Create a matrix for the return data
		//
	    dims[0] = p->str_cnt;
	    plhs[0] = mxCreateNumericArray( 2, dims, mxUINT8_CLASS, mxREAL );
	    if( plhs[0]==0 ) {
  	    	mexErrMsgTxt("COMM('READ'): mxCreateNumericArray failed.");
	    }
		
		
		// move the data into the matrix & clear the read buffer
		//
		memmove( mxGetPr(plhs[0]), p->readBufferPtr, p->str_cnt );
		p->str_cnt = 0;
		
		return;


    // ******************************* READ LINE **********************************
	//
    // string = comm( 'readl', port );			% read one line of ASCII data
    // string = comm( 'readl', port, eol );		% read one line of ASCII data

	case READL_:

	    if( nrhs < 2 ) {
  	    	mexErrMsgTxt("COMM('READL'): requires at least two input arguments.");
 	    }

	    if( nrhs == 3 ) {
			p->eol = mxGetScalar( prhs[2] );
		}

		str_cnt = p->str_cnt;
		
		numBytes = read( p->fd, &p->readBufferPtr[str_cnt], STRLEN-str_cnt );
		if( numBytes == -1 )
		{
			mexPrintf("Error reading serial port - %s(%d).\n", strerror(errno), errno);
			mexErrMsgTxt("COMM('READ'): device read failed.");
		}
		
		str_cnt += numBytes;					// cur # bytes in 'readBufferPtr'
		
		for( i=0; i<str_cnt; i++ ) {
			if( p->readBufferPtr[i] == p->eol ) {
				p->readBufferPtr[i] = 0;
			    plhs[0] = mxCreateString( p->readBufferPtr );
			    if( plhs[0]==0 ) {
		  	    	mexErrMsgTxt("COMM('READL'): mxCreateString failed.");
		  	    }
		  	    n = mxGetN(plhs[0]) * mxGetM(plhs[0]);
		  	    if( i != n ) {
		  	    	mexPrintf( "COMM('READL'): found null instead of EOL\n" );
		  	    	p->readBufferPtr[i] = p->eol;
		  	    }
		  	    str_cnt -= n + 1;
		  	    memmove( p->readBufferPtr, &p->readBufferPtr[n+1], str_cnt );
		  	    p->str_cnt = str_cnt;
		  	    return;
		  	}
	    }

		// is the buffer full with no EOL?

	    if( str_cnt==STRLEN ) {
			str_cnt = 0;							// clear buffer
  	    	mexErrMsgTxt("COMM('READL'): no EOL found, buffer overflow.");
	    }

   		// Create a matrix for the return data

	    plhs[0] = mxCreateString( "" );
	    if( plhs[0]==0 ) {
  	    	mexErrMsgTxt("COMM('READL'):' mxCreateString failed.");
	    }

		p->str_cnt = str_cnt;
		return;


    // ******************************* WRITE ********************************
	//
	//	comm( 'write', port, string );		% write string to PORT
    
	case WRITE_:

	    if( nrhs != 3 ) {
  	    	mexErrMsgTxt("COMM('WRITE'): requires three input arguments.");
 	    }

	    // Read input parameters

    	cnt = mxGetN( prhs[2] ) * mxGetM( prhs[2] );
	    if( cnt > STRLEN ) {
  	    	mexErrMsgTxt("COMM('WRITE'): third argument is too large.");
 	    }

		if( mxIsChar( prhs[2] ) ) {				// copy Matlab character data into string
		
			if( mxGetString( prhs[2], string, STRLEN ) ) {
				mexErrMsgTxt("COMM('WRITE'): bad third argument.");
			}
			str = string;


		} else if( mxIsInt8( prhs[2] ) ) {		// 
			str = mxGetData(prhs[2]);


		} else if( mxIsDouble( prhs[2] ) ) {	// copy Matlab matrix data into string
 			x = mxGetPr( prhs[2] );
			for( i=0; i<cnt; i++ ) {
				string[i] = (char) *x++;
			}
			str = string;


		} else {
			mexErrMsgTxt("COMM('WRITE'): bad third argument.");

		}
		
		// write 'string' to serial device
		
		numBytes = write( p->fd, str, cnt );
		if( numBytes == -1) {
            mexPrintf("Error writing to modem - %s(%d).\n", strerror(errno), errno);
        	mexErrMsgTxt("COMM('WRITE'): device write failed.");
		}


		// return number of bytes written to port
		//
		plhs[0] = mxCreateDoubleMatrix( 1, 1, mxREAL );
	    if( plhs[0]==0 ) {
  	    	mexErrMsgTxt("COMM('WRITE'): mxCreateDoubleMatrix failed.");
	    }
		x = mxGetPr( plhs[0] );
		*x = numBytes;

		return;


    // ******************************* CLOSE ********************************
	//
	//	comm( 'close', port );

	case CLOSE_:
		if( p->fd == -1 ) {
    	    mexPrintf("COMM('CLOSE'): port %d is not open.\n", port+1 );
			return;
		}

		closeSerialPort( p );
		p->fd = -1;
		p->str_cnt = 0;
		free( p->readBufferPtr );
		p->readBufferPtr = NULL;
	    return;
    

	default:
        mexErrMsgTxt("COMM: bad first argument.");

	}
}



