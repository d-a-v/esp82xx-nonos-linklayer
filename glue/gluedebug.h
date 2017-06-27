
#ifndef __GLUE_DEBUG_H
#define __GLUE_DEBUG_H

// this is needed separately from lwipopts.h
// because it is shared by both sides of glue

#define UDEBUG		0	// 0 or 1 (glue debug)
#define UDUMP		0	// 0 or 1 (glue / dump packet)
#define UDEBUGINDEX	0	// 0 or 1 (show debug line number)
#define UDEBUGSTORE	0	// 0 or 1 (store debug into buffer until doprint_allow=1=serial-available)

#define ULWIPDEBUG	0	// 0 or 1 (check glue-lwip/arch/cc.h)
#define ULWIPASSERT	0	// 0 or 1 (0 saves flash)

#endif
