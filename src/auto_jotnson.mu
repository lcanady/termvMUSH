/*
#############################################################################
##### SETUP:  Auto Johnson System ###########################################

*/

// Create the Johnson System
@if not(isdbref(#AJ)) = {
        @create Auto Johnson <AJ>;
        @tags/add aj = lastcreate(me, t);
        @set #AJ = safe indestructable inherit;
    }

// Setup a system for getting functions into the global
// registry when the game starts.
@startup #aj = 
    @dolist lattr(me, global*) ={
        @if strmatch(##, *.PRIV.*) = {
            @function/priv %@/[after(##, FN.)]
        }, {
            @function %@/[after(##, FN.)]
        }
    }



