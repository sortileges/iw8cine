/*
 *      IW8cine
 *      Main file
 */

init()
{
    level.cam = [];
    level.cam["type"] = "bezier";
    level.disablespawncamera = 1;
    level.botfreeze = 1;

    precachemodel( "axis_guide_createfx" );
    precachemodel( "misc_wm_flarestick" );
    precachemodel( "tag_origin" );

    setdvar( "scr_killcam_time", 0 );
    setdvar( "scr_war_timelimit", 0 );
    setdvar( "scr_war_scorelimit", 0 );
    setdvar( "bg_fallDamageMinHeight", 5000 );

    thread onplayerconnect();
}

onplayerconnect()
{
    for(;;)
    {
        level waittill( "connected", player );

        if( isai( player ) || isbot( player ) )
            player thread onbotspawned();
        else if( player ishost() ) 
            player thread onhostspawned();
    }
}

onhostspawned()
{
    self endon( "disconnect" );
    self waittill( "spawned_player" );

    self iprintlnbold( "^3Welcome to ^7IW8cine" );
    self giveachievement( "FINISH" );

    self registercommands();
    self thread regenammo();
    self thread regenequip();
    self thread magicbullets();
}

onbotspawned()
{
    self endon( "disconnect" );

    for(;;)
    {
        self waittill( "spawned_player" );

        while( isdefined( level.matchcountdowntime ) )
            wait 1;

        self freezecontrols( level.botfreeze );
        if( isdefined( self.saved_origin ) )
             self load_spawn();
        else self save_spawn();
    }
}

registercommands()
{
    self thread createcommand( "mvm_bot_freeze","Freeze all bots",  ::botfreeze );      // 1 = freeze, 0 = unfreeze
    self thread createcommand( "mvm_bot_kill",  "Kill bot by name", ::botkill );        // name of bot
    self thread createcommand( "mvm_bot_move",  "Move to bot self", ::botmove );        // name of bot
    self thread createcommand( "mvm_bot_spawn", "Spawns a bot",     ::botspawn );       // 1
    self thread createcommand( "mvm_cam_mode",  "Change cam mode",  ::camsetmode );     // linear/bezier
    self thread createcommand( "mvm_cam_rot",   "Camera rotation",  ::camsetrot );      // rotation in degrees
    self thread createcommand( "mvm_cam_save",  "Save camera node", ::camsavenode );    // node number (starting from 1)
    self thread createcommand( "mvm_cam_start", "Camera start",     ::camstartpath );   // speed if bezier, time if linear
    self thread createcommand( "clone",         "Clone player",     ::createclone );    // 1
}

createcommand( command, desc, callback )
{
    setdvarifuninitialized( command, desc );
    for(;;)
    {
        while( getdvar( command ) == desc )
            wait .05;

        args = strtok( getdvar( command ), " " );
        if( args.size >= 1 )    self [[callback]]( args );
        else                    self [[callback]]();

        waittillframeend;
        setdvar( command, desc );
    }
}

magicbullets()
{
    setdvarifuninitialized( "mvm_eb_magic", 0 );

    for(;;)
    {
        self waittill( "weapon_fired" );
        foreach( player in level.players )
        {
            if ( inside_fov( self, player, getdvarint( "mvm_eb_magic" ) ) && player != self && getdvarint( "mvm_eb_magic" ) > 0 )
                player thread [[level.callbackPlayerDamage]]( self, self, player.health, 2, "MOD_RIFLE_BULLET", self getcurrentweapon(), (0, 0, 0), (0, 0, 0), "torso_upper", 0 );
        }
    }
}

createclone()
{
    self cloneplayer( 1 );
}

botfreeze( args )
{
    level.botfreeze = int(args[0]);
    foreach( player in level.players ) {
        if( isbot( player ) || isai( player ) )
            player freezecontrols( level.botfreeze );
    }
}

// Need to label bots.gsc and see what's up
botspawn()
{
    level thread scripts\mp\bots\bots::spawn_bots( 1, "allies", undefined, undefined, "spawned_allies", "recruit" );
}

botmove( args )
{
    foreach( player in level.players ) {
        if( issubstr( player.name, args[0] ) ) {
            player setorigin( self.origin );
            player save_spawn();
            self iprintln("[bot] * ^3" + player.name + " ^7moved to " + self.origin );
        }
    }
}

// Needs to be redone/investigated - attacker-to-victim vector seems to play a role in the death animation
// Can probably exploit that to trigger specific animations
botkill( args )
{
    foreach( player in level.players ) {
        if( issubstr( player.name, args[0] ) && player != self) {
           player thread [[level.callbackPlayerDamage]]( self, self, player.health, 8, "MOD_RIFLE_BULLET", self getcurrentweapon(), player.origin, self.origin, "torso_upper", 0 );
        }
    }
}

camsavenode( args )
{
    i = int(args[0]);
    deletecamprev();

    level.cam["origin"][i]  = self getorigin();
    level.cam["orgpath"][i] = self getorigin() + (0,0,58);
    level.cam["angles"][i]  = self getplayerangles();

    if( isDefined(level.cam["obj"][i]) ) level.cam["obj"][i] delete();
    level.cam["obj"][i] = spawn( "script_model", level.cam["orgpath"][i] );
    level.cam["obj"][i] setmodel( "axis_guide_createfx" );
    level.cam["obj"][i].angles = self getplayerangles();
    level.cam["obj"][i] hudoutlineenable( "outlinefill_nodepth_green" );

    if( level.cam["count"] <= i || !isdefined( level.cam["count"] ) )
        level.cam["count"] = i;

    createcamprev();
    self iprintln("[camera] * ^3Position ^7" + i + " saved " + self.origin );
}

camsetmode( args )
{
    level.cam["type"] = args[0];
    deletecamprev();

    if( ( level.cam["type"] == "bezier" && level.cam["count"] > 13 ) )
        self iprintln("[camera] * ^113 points max for bezier" );

    if( ( level.cam["type"] == "bezier" && level.cam["count"] <= 13 ) || level.cam["type"] == "linear" ) {
        self iprintln("[camera] * ^3" + level.cam["type"] + " ^7mode" );
        createcamprev();
    }

    else {
        self iprintln("[camera] * ^1Invalid mode - must be bezier/linear" );
        level.cam["type"] = "bezier";
        createcamprev();
    }
}

createcamprev() 
{
    if( level.cam["count"] < 2 ) return;

    if( level.cam["type"] == "bezier" )
    {
        n = 0;
        pathsteps = ( 2000 * level.cam["count"] / 400 );

        for( j = 0; j < pathsteps ; j++ )
        {
            t = j / (pathsteps - 1);
            pos[0] = 0; pos[1] = 0; pos[2] = 0;
            ang[0] = 0; ang[1] = 0; ang[2] = 0;
            for( i = 1; i <= level.cam["count"]; i++ )
            {
                for(z = 0; z < 3; z++)
                {
                    pos[z] += float( diff( i-1, level.cam["count"]-1) * pow( (1-t), level.cam["count"]-i ) * pow( t, i-1 ) * level.cam["orgpath"][i][z] );
                    ang[z] += float( diff( i-1, level.cam["count"]-1) * pow( (1-t), level.cam["count"]-i ) * pow( t, i-1 ) * level.cam["angles"][i][z] );
                }
            }

            level.cam["path"][n] = spawn( "script_model", (pos[0],pos[1],pos[2]) );
            level.cam["path"][n] setModel( "misc_wm_flarestick" );
            level.cam["path"][n].angles = (ang[0], ang[1], ang[2] + 90);
            level.cam["path"][n] hudoutlineenable( "outlinefill_nodepth_red" );
            n++;
        }
    }
    else if( level.cam["type"] == "linear" )
         self iprintln("[camera] * ^1Preview for linear not implemented yet" );
    else self iprintln("[camera] * ^1Can't create preview for '" + level.cam["type"] + "' mode" );
}


camstartpath( args )
{
    speed = int(args[0]);

    camera = spawn( "script_model", level.cam["origin"][1] );
    camera setmodel( "tag_origin" );
    camera enablelinkto();
    camera rotateto( level.cam["angles"][1], .05 );

    self setplayerangles( ( self getplayerangles()[0], self getplayerangles()[1], 0 ) ); // In case cam_rot is not 0
    self playerlinktodelta( camera, "tag_origin", 1, 0, 0, 0, 0, true );
    self iprintlnbold( "Mode: " + level.cam["type"] + " / Speed: " + speed + " / Nodes: " + level.cam["count"] );
    preparenodedistances();

    if( level.cam["type"] != "bezier" && level.cam["type"] != "linear" ) 
        self iprintln( "[camera] * ^1Invalid path type" );
    
    if( level.cam["type"] == "bezier" && level.cam["count"] < 3 ) 
        self iprintln( "[camera] * ^1Bezier needs atleast 3 nodes" );

    wait 2;
    hidecamprev();
    setdvar( "cg_drawGun", 0 );
    setdvar( "cg_drawCrosshair", 0 );
    self playerhide();
    self setclientomnvar( "ui_hide_full_hud", 1 );

    if( level.cam["type"] == "linear" )
    {
        travel_time = int( speed / int(level.cam["count"]) );
        for ( i = 2; i < level.cam["count"] + 1; i++ )
        {
            camera rotateto( level.cam["angles"][i], travel_time, 0, 0 );
            camera moveto( level.cam["origin"][i], travel_time, 0, 0 );
            wait travel_time;
        }
    }
    else if( level.cam["type"] == "bezier" && level.cam["count"] >= 3 )
    {
        mult = 0.2; // "sv_fps / 10"

        for( j = 0; j <= ( level.total_distance * 10 * mult / speed ); j++ )
        {
            t = ( j * speed / (level.total_distance * 10 * mult) );

            pos[0] = 0; pos[1] = 0; pos[2] = 0;
            ang[0] = 0; ang[1] = 0; ang[2] = 0;

            for( i = 1; i <= level.cam["count"]; i++ )
            {
                for( z = 0; z < 3; z++ )
                {
                    pos[z] += float( diff( i-1, level.cam["count"]-1) * pow( (1-t), level.cam["count"]-i ) * pow( t, i-1 ) * level.cam["origin"][i][z] );
                    ang[z] += float( diff( i-1, level.cam["count"]-1) * pow( (1-t), level.cam["count"]-i ) * pow( t, i-1 ) * level.cam["angles"][i][z] );
                }
            }
            camera moveto( (pos[0] ,pos[1], pos[2]), .1, 0, 0 );
            camera rotateto( (ang[0], ang[1], ang[2]), .1, 0, 0 );
            wait 0.05;
        }
    }

    showcamprev();
    self setclientomnvar( "ui_hide_full_hud", 0 );
    setdvar( "cg_drawGun", 1 );
    setdvar( "cg_drawCrosshair", 1 );
    self unlink();
    self playershow();
    camera delete();
}

preparenodedistances() 
{
    level.total_distance = 0;
    for( k = 1; k < level.cam["count"]; k++ )
    {
        x = level.cam["angles"][k][1];
        y = level.cam["angles"][k+1][1];
        
        if( y - x >= 180 )
            level.cam["angles"][k] += (0,360,0);
        else if( y - x <= -180 )
            level.cam["angles"][k+1] += (0,360,0);

        level.mov_distance[k]   = distance( level.cam["origin"][k], level.cam["origin"][k+1] );
        level.ang_distance[k]   = distance( level.cam["angles"][k], level.cam["angles"][k+1] );
        level.total_distance    += level.mov_distance[k];
        level.total_distance    += level.ang_distance[k];
    }
}

camsetrot( args )
{
    self setplayerangles( self getplayerangles()[0], self getplayerangles()[1], int(args[0]) );
    self iprintln("[camera] * Added ^3" + args[0] + " deg" );
}

hidecamprev()
{
    foreach( obj in level.cam["obj"] )
        obj hide();
    foreach( path in level.cam["path"] )
        path hide();
}

showcamprev()
{
    foreach( obj in level.cam["obj"] )
        obj show();
    foreach( path in level.cam["path"] )
        path show();
}

deletecamprev()
{
    foreach( path in level.cam["path"] )
        path delete();
}

regenammo()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill( "reload" );
        waittillframeend;
        self givemaxammo( self getcurrentweapon() );
    }
}

regenequip()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill( "grenade_fire", grenade, name );
        waittillframeend;
        self setweaponammoclip( name, 1 );
        self givemaxammo( name );
    }
}

save_spawn()
{
    self.saved_origin = self.origin;
    self.saved_angles = self getplayerangles();
}

load_spawn()
{
    self setorigin( self.saved_origin );
    self setplayerangles( self.saved_angles );
}

inside_fov( player, target, fov )
{
    normal = vectornormalize( target.origin - player geteye() );
    forward = anglestoforward( player getplayerangles() );
    dot = vectordot( forward, normal );
    return dot >= cos( fov );
}

diff( x, y )
{
    return ( fact( y ) / ( fact( x ) * fact( y - x ) ) );
}

fact( x )
{
    c = 1;
    if( x == 0 ) return 1;
    for( i = 1; i <= x; i++ )
        c = c * i;
    return c;
}