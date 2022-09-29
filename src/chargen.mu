/*
#############################################################################
##### Chargen Setup #########################################################


Trademarks

    +trademarks         - Show your trademarks.
    +trademarks/list    - List all trademarks.
    +trademarks/add     - Add a trademark to the system.
    +trademarks/remove  - Remove a trademark from a character.    




-----------------------------------------------------------------------------
*/

@if not(isdbref(#cgo)) = {
        @create Chargen Global Object <cgo>;
        @tag/add cgo = lastcreate(me, t);
        @set #cgo = inherit indestructible;
    }

@if not(isdbref(#cdo)) = {
        @create Chargen Data Object <CDO>;
        @tag/add cdo = lastcreate(me, t);
        @set #cdo = inherit indestructible;
    }

@if not(isdbref(#cfo)) = {
        @create Chargen Function Object <cfo>;
        @tag/add cfo = lastcreate(me, t);
        @set #cfo = inherit indestructible;
    }


// Setup a system for getting functions into the global
// registry when the game starts.
@startup #cfo = 
    @dolist lattr(me, global*) ={
        @if strmatch(##, *.PRIV.*) = {
            @function/priv %@/[after(##, FN.)]
        }, {
            @function %@/[after(##, FN.)]
        }
    }


/*
===============================================================================
===== +trademarks/add =========================================================

    Add new trademarks to the list of trademarks.  the first section after
    the equal sign are the triggers for the trademark.  Anything after the 
    semi-colon will list as a potential flaw for the trademark.

    SYNTAX: 

    trademarks/add <trademark>=<trigger>[,<trigger>...][;<flaws>[,<flaws>...]]


    Registers:
        %1: The trademark
        %2: The triggers; flaws

-------------------------------------------------------------------------------
*/

&cmd.trademarks/add #cgo = $[@/+]?trademark[s]?\/add\s+(.+)\s*=\s*(.+):

    @assert isstaff(%#) = {
        @pemit %#= Permission Denied.
    };

    &trademark.[edit(trim(%1), %b, _)] #cdo = [iter(before(%2,;),##,%,,|)];
    &flaws.[edit(trim(%1), %b, _)] #cdo = [iter(after(%2,;),##,%,,|)];
    @pemit %#= [u(#cfo/msg.info)] Trademark %ch%cc[ucstr(%1)]%cn added with triggers: 
        [itemize(
            iter(
                %2,
                %ch[capstr(trim(##))]%cn, %, ,|    
            ) , |
        )].;
    @if words(after(%2,;), %,) = {
        @pemit %#= [u(#cfo/msg.info)] %cyPotential flaws:%cn 
            [itemize(
                iter(
                    after(%2,;),
                    %ch[capstr(trim(##))]%cn, %, ,|    
                ) , |
            )].;
    };

@set #cgo/cmd.trademarks/add = regex

/*
===============================================================================
===== +trademarks =============================================================

    List the trademarks.

    syntax: trademarks

-------------------------------------------------------------------------------
*/

&cmd.trademarks/list #cgo = $[@\+]?trademark[s]?\/list:
    @pemit %#= [u(#cfo/msg.info)] Trademark List: 
        [itemize(
            iter(
                lattr(#cdo/trademark.*), 
                %ch[capstr(lcstr(after(edit(##, _, %b), TRADEMARK.)))]%cn,,|
            ), |
        )].%r
        [u(#cfo/msg.info)] Type '%chtrademarks/view <trademark> for more info.';

@set #cgo/cmd.trademarks/list = regex


/*
===============================================================================
===== +trademark/delete =======================================================

    Remove a trademark from the list.

    syntax: trademark/remove <trademark>
-------------------------------------------------------------------------------
*/

&cmd.trademarks/delete #cgo = $[@/+]?trademark[s]?\/delete\s+(.+):
    @assert isstaff(%#) = {
        @pemit %#= Permission Denied.
    };

    @assert words(lattr(#cdo/trademark.[edit(%1,%b,_)])) = {
        @pemit %#= [u(#cfo/msg.error)] Trademark not found.
    };

    &trademark.[edit(%1,%b,_)] #cdo =;
    &flaws.[edit(%1,%b,_)] #cdo =;

    @pemit %#= [u(#cfo/msg.info)] Trademark removed.;

@set #cgo/cmd.trademarks/delete = regex


/*
===============================================================================
===== +trademark ==============================================================

    Display information about a trademark.

    syntax: trademark <trademark>
-------------------------------------------------------------------------------
*/

&cmd.trademark/view #cgo = $[@/+]?trademark[s]?\/view\s+(.*):
    @assert words(lattr(#cdo/trademark.[edit(%1,%b,_)])) = {
        @pemit %#= [u(#cfo/msg.error)] Trademark not found.
    };


    @pemit %#= [u(cfo/header, %cyTrademark:%cn %ch%cy[ucstr(trim(%1))]%cn)]%r
        [ljust(Triggers:,19)] 
        [wrap(
            [itemize(
                iter(
                    get(#cdo/trademark.[edit(trim(%1),%b,_)]), 
                    %ch[capstr(edit(##, _, %b))]%cn, |,|
                ), |
            )], 60,left,,,20
        )]%r
        [ljust(Potential Flaws:,19)] 
            [wrap(
                [itemize(
                    iter(
                        get(#cdo/flaws.[edit(trim(%1),%b,_)]), 
                        %ch[capstr(edit(##, _, %b))]%cn, |,|
                    ), |
                )], 60,left,,,20
            )]%r
            %cm[repeat(/, 80)]%cn;

@set #cgo/cmd.trademark/view = regex


/*
===============================================================================
===== +trademark/set ==========================================================
    
    syntax: trademark/set <trademark> [= <trigger>[,<trigger>...]]

    Set a trademark on a character.  If the triggers are left off, then the
    command searches for the trademark in the global list.  If the triggers
    are specified, then the command will add the  custom trademark to the
    character.

-------------------------------------------------------------------------------
*/

&cmd.trademark/set #cgo = $[@/+]?trademark[s]?\/set\s+(.*)\s*=\s*(.*):
    
    @assert u(#cfo/fn.canedit, %#, %1) = {
        @pemit %#= Permission Denied.
    };
    @pemit %#=lattr(#cdo/trademark.[edit(%2,%b,_)]);
    @if words(lattr(#cdo/trademark.[edit(%2,%b,_)])) = {
        &_trademark.[edit(trim(%2),%b,_)] *%1 = 
            get(#cdo/trademark.[edit(trim(%2),%b,_)]);
        @pemit %#=[u(cfo/msg.info)] Trademark %ch%cc[ucstr(trim(%2))]%cn set.;
    }, {
        @pemit %#=[u(cfo/msg.error)] Trademark not found.;
    };

@set #cgo/cmd.trademark/set = regex


/*
===============================================================================
===== +trademark/custom =======================================================
    
    syntax: trademark/custom <trademark> = <trigger>[,<trigger>...]

    Set a custom trademark on a character.

-------------------------------------------------------------------------------
*/

&cmd.trademark/custom #cgo = $[@/+]?trademark[s]?\/cu[stom]+\s+(.*)\/(.*)\s*=\s*(.*):
    
    @assert u(#cfo/fn.canedit, %#, %1) = {
        @pemit %#= Permission Denied.
    };

    &_trademark.[edit(trim(%2),%b,_)].custom *%1 = iter(%3, trim(##), %, ,|);
    @pemit %#=[u(cfo/msg.info)] Custom Trademark %ch%cc[ucstr(trim(%2))]%cn set.;

@set #cgo/cmd.trademark/custom = regex


&cmd.+sheet #cgo = $[@\+]?sheet:
    @pemit %#=[u(#cfo/fn.sheet.bio, %#)]%r
        [u(#cfo/fn.sheet.trademarks, %#)]%r%r
        [u(#cfo/footer, %cySP:%cn [default(%#/_sp, 0)])]

@set #cgo/cmd.+sheet = regex


&fn.canedit #cfo = 
    or( 
        strmatch(lcstr(%1), me),
        match( lcstr(owner(%1)), lcstr(pmatch(%0))),
        isstaff(%0)
    )
 
/*
===============================================================================
===== +trademark/remove =======================================================
    
    syntax: trademark/remove <character>=<trademark>

    Remove a trademark from a character.
-------------------------------------------------------------------------------    
*/

&cmd.trademarks/remove #cgo = $[@\+]?trademark[s]?\/remove\s+(.*)\s*=\s*(.*):
    @assert u(#cfo/fn.canedit, %#, %1) = {
        @pemit %#= Permission Denied.
    };

    @assert words(setr(+, lattr(*%1/_trademark.[edit(%2,%b,_)]*), attr)) = {
        @pemit %#= [u(#cfo/msg.error)] Trademark not found.
    };

    &%q<attr> *%1 =;
    @pemit %#=[u(cfo/msg.info)] Trademark %ch%cc[ucstr(trim(%2))]%cn removed.;

@set #cgo/cmd.trademarks/remove = regex



&cmd.trademarks #cgo = $+trademarks:
    @pemit %#=u(#cfo/fn.sheet.trademarks, %#);



// Message headers ----------------------------------------------------------
&msg.info #cfo = %cc>>%Cn
&msg.warn #cfo = %ch%cy>>%Cn
&msg.error #cfo = %ch%cr>>%Cn

&header #cfo = 
    %ch%cm>>>>>%cn[printf($-:%cm/%cn:[if(%1,%1,75)]s,%ch%cm%[%cn %0 %ch%cm%]%cn,%1)]

&global.fn.header #cfo = u(#cfo/header, %0, %1)


&divider #cfo = 
    %ch%cm>>>>>%cn[printf($-:%cm-%cn:[if(%1,%1,75)]s,%ch%cm%[%cn %0 %ch%cm%]%cn,%1)]

&global.fn.divider #cfo = u(#cfo/header, %0, %1)


&footer #cfo = 
    [printf($:%cm/%cn:[if(%1,%1,75)]s,%ch%cm%[%cn %0 %ch%cm%]%cn,%1)]%ch%cm<<<<<%cn

&global.fn.footer #cfo = u(#cfo/header, %0, %1)



// Sheet functions -----------------------------------------------------------

/*

>>>>>[ Readout: @Kerberos.exe ]////////////////////////////////////////////////

Full Name:  Some Lost guy.
Concept:    Psyhco-coder with a heart of gold.
Drive:      Money.

Flaws:      Socially awkward, Unremarkable 

>>>>>>>>>>> CODESLINGER ///////////////////////////////////////////////////////
Triggers:   Hacking, Notice, Cyber combat, Computers,  Security systems, 
            Defense programs, Ghost chip, Repair, Sense motives

>>>>>>>>>>> METROPLEXER ///////////////////////////////////////////////////////
Triggers:   Just a face in the crowd, Duck & cover, Take notice, Brawling,
            Scrounge, Haggle
Edges:      Foooo, Bar and Baz

>>>>>[ Stats]//////////////////////////////////////////////////////////////////

Hits:       [ ][ ][ ]                       
Stash:      [x][ ][ ][ ][ ][ ]              
Drive:      [X][X][*][*][ ][ ][ ][ ][ ][ ]  
Stunt:      0
Truama:     Broken Something, Bruised something, Not the best day, 
            Light concussion

Conditions: Stunnded.

>>>>>[ Gear ]//////////////////////////////////////////////////////////////////

Aresaka Cyberdeck(Advanced, Porable, Small)
Cyber Eyes(Thermal Imaging, Hud, Notice)

//////////////////////////////////////////////////////////////////[ SP: 0 ]<<<<<

*/

&fn.sheet.bio #cfo = 
    [u(#cfo/header, %cyReadout:%cn [cname(%0)])]%r%r
    [ljust(Full Name:, 12)]%ch[get(%0/fullname)]%cn%r
    [ljust(Concept:, 12)]%ch[get(%0/_concept)]%cn%r
    [ljust(Drive:, 12)]%ch[get(%0/_drive)]%cn%r%r
    [ljust(Flaws:, 12)]
    [wrap(
        itemize(
            iter( 
                get(%#/_flaws), 
                    %ch[capstr(lcstr(##))]%cn,|, |
            ), |
        ), 68, left,,,12,|
    )]


&fn.sheet.trademarks #cfo = 
    [iter(
        sort(lattr(%0/_trademark.*)),
        [setq(+, before(after(##, _TRADEMARK.), .CUSTOM), trademark)]
        [setq(+, strmatch(##, *.CUSTOM), custom)]
        [setq(+,  setinter(lcstr(get(%0/##)), lcstr(get(%0/_edges)),|,|), edges)]
        %r%cm>>>>>>>>>>>%cn[printf($-:%cm/%cn:69s, %b%cc[ucstr(edit(%q<trademark>, _, %b))]%b%cn )]
        %r[ljust(Triggers:, 12)]
            [wrap(
                    itemize(
                    iter( 
                        get(%0/##), 
                            %ch[capstr(edit(%i0,_,%b))]%cn, |, |
                    ), |
                ), 68, left,,,12,|
            )]
        [if(
            words(%q<edges>,|),
            %r[ljust(Edges:, 12)]
            [wrap(
                    itemize(
                    iter( 
                        %q<edges>, 
                            %cy[capstr(edit(%i0,_,%b))]%cn, |, |
                    ), |
                ), 68, left,,,12,|
            )]
        )]
    )]

&fn.sheet.stats #cfo=


&fn.sheet.boxes #cfo=
    [setq(+, extract(get(%0/_%1),0,1,:), num)]
    [setq(+, extract(get(%0/_%1),1,1,:), fill)]
    [setq(+, extract(get(%0/_%1),2,1,:), block)]
    [setq(+,
        if(
            gt(%q<block>, 0),
            iter(
                lnum(%q<block>),
                %cm%[x%cn%cm%]%cn,,|
            ),
        ), blocks
    )]
    %q<blocks>