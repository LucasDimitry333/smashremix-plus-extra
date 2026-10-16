// Sknight.asm

// This file contains file inclusions, action edits, and assembly for Shovel Knight.

scope SKnight {


    scope MODEL {
        scope WEAPON {
            constant DEFAULT(0xA0800000)
            constant HAND(0xA0800001)
            constant SHOVEL(0xA0800002)
            constant DAGGER(0xA0800003)
            constant WAND(0xA0800004)
            constant ANCHOR(0xA0800005)
            constant FISH(0xA0800006)
        }
    }

    // @ Description
    // Mad Piano's extra actions
    scope Action {
        constant Entry_R(0x0DD)
        constant Entry_L(0x0DE)
        constant Book(0x0DF)
        constant NSPA(0x0E0)
        constant BodySlam(0x0E3)
        constant BodySlamAir(0x0E4)
        constant UPG(0x0E8)
        constant SuperJumpChompAir(0x0E2)
        //constant MarioTornado(0x0E3)
        //constant MarioTornadoAir(0x0E4)
        constant UPAttack(0x0E5)
        constant UPJump(0x0E6)
        constant UPEscape(0x0E7)


        // strings!
        //string_0x0DC:; String.insert("Jab3")
        //string_0x0DD:; String.insert("Appear1")
        //string_0x0DE:; String.insert("Appear2")
        string_0x0DF:; String.insert("Book")
        string_0x0E0:; String.insert("BookAir")
        string_0x0E1:; String.insert("SuperJumpChomp")
        string_0x0E2:; String.insert("SuperJumpChompAir")
        //string_0x0E3:; String.insert("MarioTornado")
        //string_0x0E4:; String.insert("MarioTornadoAir")
        string_0x0E5:; String.insert("EatStart")
        string_0x0E6:; String.insert("EatLoop")
        string_0x0E7:; String.insert("Eat")
        string_0x0E8:; String.insert("EatEnd")
        string_0x0E9:; String.insert("EatStartAir")
        string_0x0EA:; String.insert("EatLoopAir")
        string_0x0EB:; String.insert("EatAir")
        string_0x0EC:; String.insert("EatEndAir")
        string_0x0ED:; String.insert("EatThrow")
        string_0x0EE:; String.insert("EatThrowAir")

        action_string_table:
        dw 0 //dw Action.COMMON.string_jab3
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw string_0x0DF
        dw string_0x0E0
        dw string_0x0E1
        dw string_0x0E2
        dw 0 //dw string_0x0E3
        dw 0 //dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw string_0x0E7
        dw string_0x0E8
        dw string_0x0E9
        dw string_0x0EA
        dw string_0x0EB
        dw string_0x0EC
        dw string_0x0ED
        dw string_0x0EE
    }

    // Insert Moveset files

    DAIR:; dw MODEL.WEAPON.SHOVEL; insert "moveset/DAIR.bin"
    ATTACK_AIR_F:; dw MODEL.WEAPON.SHOVEL; insert "moveset/ATTACK_AIR_F.bin"
    SELECT:; dw MODEL.WEAPON.SHOVEL; insert "moveset/SELECT.bin"
    DASH_ATTACK:; dw MODEL.WEAPON.SHOVEL; insert "moveset/DASH_ATTACK.bin"
    DSMASH:; dw MODEL.WEAPON.SHOVEL; insert "moveset/DSMASH.bin"
    FSMASH:; dw MODEL.WEAPON.SHOVEL; insert "moveset/FSMASH.bin"
    FTILT:; dw MODEL.WEAPON.SHOVEL; insert "moveset/FTILT.bin"
    DTILT:; dw MODEL.WEAPON.SHOVEL; insert "moveset/DTILT.bin"
    JAB_1:; dw MODEL.WEAPON.SHOVEL; insert "moveset/JAB_1.bin"
    JUMP:; dw MODEL.WEAPON.SHOVEL; insert "moveset/JUMPB.bin"
    TAUNT:; dw MODEL.WEAPON.SHOVEL; insert "moveset/TAUNT.bin"
    USMASH:; dw MODEL.WEAPON.SHOVEL; insert "moveset/USMASH.bin"
    JUMPA:; dw MODEL.WEAPON.SHOVEL; insert "moveset/JUMP_AERIAL.bin"
    IDLE:; dw MODEL.WEAPON.SHOVEL; insert "moveset/IDLE.bin"
    DASH:; dw MODEL.WEAPON.SHOVEL; insert "moveset/DASH.bin"
    CROUCH:; dw MODEL.WEAPON.SHOVEL; insert "moveset/CROUCH.bin"
    RUN:; dw MODEL.WEAPON.SHOVEL; insert "moveset/RUN.bin"; Moveset.GO_TO(RUN) // loops
    BAIR:; dw MODEL.WEAPON.SHOVEL; insert "moveset/BAIR.bin"
    UTILT:; dw MODEL.WEAPON.SHOVEL; insert "moveset/UTILT.bin"
    NAIR:; dw MODEL.WEAPON.SHOVEL; insert "moveset/NAIR.bin"
    insert NSP, "moveset/NEUTRAL_SPECIAL.bin"
    insert DSP_RECOIL,"moveset/DOWN_SPECIAL_RECOIL.bin"
    insert DSP_TRAIL,"moveset/DOWN_SPECIAL_TRAIL.bin"
    DSP_GROUND:; dw MODEL.WEAPON.DAGGER; Moveset.CONCURRENT_STREAM(DSP_TRAIL); insert "moveset/DOWN_SPECIAL_GROUND.bin"
    DSP_AIR:; dw MODEL.WEAPON.DAGGER; Moveset.CONCURRENT_STREAM(DSP_TRAIL); insert "moveset/DOWN_SPECIAL_AIR.bin"
    insert USP_TRAIL,"moveset/UP_SPECIAL_TRAIL.bin"
    USP:; dw MODEL.WEAPON.ANCHOR; Moveset.CONCURRENT_STREAM(USP_TRAIL); dw 0x38000631; insert "moveset/UP_SPECIAL.bin"
    insert APPEAR, "moveset/APPEAR.bin"

    DOWN_ATTACK_D:; dw MODEL.WEAPON.SHOVEL; insert "moveset/DOWN_ATTACK_D.bin"
    DOWN_ATTACK_U:; dw MODEL.WEAPON.SHOVEL; insert "moveset/DOWN_ATTACK_U.bin"

    FALL:; dw MODEL.WEAPON.SHOVEL; dw 0;
    FALLSPECIAL:; dw MODEL.WEAPON.ANCHOR; insert "moveset/DAIR.bin"

    TECH:; dw MODEL.WEAPON.SHOVEL; insert "moveset/TECH.bin"
    TECHF:; dw MODEL.WEAPON.SHOVEL; insert "moveset/TECHF.bin"

    DSPA:; dw MODEL.WEAPON.SHOVEL; insert "moveset/DAIR2.bin"
    UAIR:; dw MODEL.WEAPON.SHOVEL; insert "moveset/UAIR.bin"
    TURN:; dw MODEL.WEAPON.SHOVEL; insert "moveset/turn.bin"

    THROWF:; dw MODEL.WEAPON.SHOVEL; Moveset.THROW_DATA(FTHROWDATA); insert "moveset/THROWF.bin"
    insert FTHROWDATA, "moveset/F_THROW_DATA.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROWDATA); insert "moveset/BTHROW.bin"
    insert BTHROWDATA, "moveset/BTHROWDATA.bin"

    USP_IDLE:; dw MODEL.WEAPON.FISH; insert "moveset/USPG.bin"
    insert USP_JUMP, "moveset/USP_JUMP.bin"
    insert USP_ESCAPE, "moveset/USP_ESCAPE.bin"
    USP_ATTACK:; dw MODEL.WEAPON.FISH; insert "moveset/USP_ATTACK.bin"

    SHOWEL:; dw MODEL.WEAPON.SHOVEL; dw 0
    HOWEL:; dw MODEL.WEAPON.DEFAULT; dw 0
    AHOWEL:; dw MODEL.WEAPON.ANCHOR; dw 0
    LANDING:; dw MODEL.WEAPON.SHOVEL; insert "moveset/Landing.bin"
    RUNBRAKE:; dw MODEL.WEAPON.SHOVEL; insert "moveset/RunBrake.bin"
    TURNRUN:; dw MODEL.WEAPON.SHOVEL; insert "moveset/TurnRun.bin"

    CLIFF_ATTACK_F:; dw MODEL.WEAPON.SHOVEL; insert "moveset/CLIFF_ATTACK_F.bin"
    CLIFF_ATTACK_S:; dw MODEL.WEAPON.SHOVEL; insert "moveset/CLIFF_ATTACK_S.bin"
    insert CLIFF_ESCAPE_S2, "moveset/CLIFF_ESCAPE_S2.bin"

    SHIELDBREAK:; dw MODEL.WEAPON.SHOVEL; insert "moveset/SHIELDBREAK.bin"; Moveset.GO_TO(SPARKLE) // loops
    SPARKLE:; dw MODEL.WEAPON.SHOVEL; insert "moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE) // loops
    SLEEP:; dw MODEL.WEAPON.SHOVEL; insert "moveset/SLEEP.bin"; Moveset.GO_TO(SLEEP) // loops
    STUN:; dw MODEL.WEAPON.SHOVEL; insert "moveset/STUN.bin"; Moveset.GO_TO(STUN) // loops

    ROLLF:; dw MODEL.WEAPON.SHOVEL; insert "moveset/ROLLF.bin"
    ROLLB:; dw MODEL.WEAPON.SHOVEL; insert "moveset/ROLLB.bin"


    NSPA2:
    dw MODEL.WEAPON.WAND
    Moveset.HIDE_ITEM()
    dw 0xCC600000
    Moveset.AFTER(4)

    Moveset.AFTER(20)
    Moveset.SET_FLAG(0)                             // spawn projectile
    Moveset.SET_FLAG(1)                             // allow cancel
    Moveset.HURTBOXES(3)                            // intangible
    Moveset.CREATE_GFX(18, 31, 0, -300, 0, 20, 20, 20) // spark on grape shooter
    Moveset.SFX(1579)                               // grape shooter sound

    Moveset.AFTER(22)
    Moveset.HURTBOXES(1)                            // vulnerable
    Moveset.AFTER(28)
    Moveset.AFTER(36)
    dw 0x58000000                                   // disallow cancel
    dw 0

    NSPA:
    dw 0x98004000, 0x00000000, 0xFF6A0000, 0x00000000
    Moveset.GO_TO(NSPA2)


    // Insert AI attack options
    include "AI/Attacks.asm"

    // Modify Action Parameters             // Action                               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(SKNIGHT, Action.Idle,             File.SKNIGHT_IDLE,           IDLE,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.Jab1,             File.SKNIGHT_JAB1,           JAB_1,                       -1)
    Character.edit_action_parameters(SKNIGHT, 0xDE,                    File.SKNIGHT_ENTRY2,         TAUNT,                     -1)
    Character.edit_action_parameters(SKNIGHT, 0xDD,                    File.SKNIGHT_ENTRY3,         TAUNT,                     -1)
    Character.edit_action_parameters(SKNIGHT, 0x006,                   File.SKNIGHT_IDLE,           IDLE,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.AttackAirD,       File.SKNIGHT_DAIR,           DAIR,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.JumpF,            File.SKNIGHT_JUMPF,          JUMP,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.JumpB,            File.SKNIGHT_JUMPB,          JUMP,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.JumpAerialF,      File.SKNIGHT_JUMPAERIALF,    JUMPA,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.JumpAerialB,      File.SKNIGHT_JUMPAERIALB,    JUMPA,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.Fall,             File.SKNIGHT_FALL,           FALL,                         -1)
    Character.edit_action_parameters(SKNIGHT, Action.FallAerial,       File.SKNIGHT_FALLAERIAL,     FALL,                         -1)
	Character.edit_action_parameters(SKNIGHT, Action.Idle,             File.SKNIGHT_IDLE,           -1,                         -1)
    Character.edit_action_parameters(SKNIGHT, Action.ReviveWait,       File.SKNIGHT_IDLE,           IDLE,                         -1)
    Character.edit_action_parameters(SKNIGHT, Action.Revive1,       -1,           IDLE,                         -1)
    Character.edit_action_parameters(SKNIGHT, Action.Revive2,       -1,           IDLE,                         -1)
    Character.edit_action_parameters(SKNIGHT, Action.EggLay,           File.SKNIGHT_IDLE,           -1,                         -1)
    Character.edit_action_parameters(SKNIGHT, Action.Entry,            File.SKNIGHT_IDLE,           -1,                         -1)
    Character.edit_action_parameters(SKNIGHT, Action.AttackAirF,       File.SKNIGHT_FAIR,           ATTACK_AIR_F,               -1)
    Character.edit_action_parameters(SKNIGHT, Action.DSmash,           File.SKNIGHT_DSMASH,         DSMASH,               -1)
    Character.edit_action_parameters(SKNIGHT, Action.FSmash,           File.SKNIGHT_FSMASH,         FSMASH,               -1)
    Character.edit_action_parameters(SKNIGHT, Action.FSmashHigh,              0,                              0x80000000,                 0)
    Character.edit_action_parameters(SKNIGHT, Action.FSmashMidHigh,           0,                              0x80000000,                 0)
    Character.edit_action_parameters(SKNIGHT, Action.FSmashMidLow,            0,                              0x80000000,                 0)
    Character.edit_action_parameters(SKNIGHT, Action.FSmashLow,               0,                              0x80000000,                 0)
    Character.edit_action_parameters(SKNIGHT, Action.DashAttack,       File.SKNIGHT_DASH_ATTACK,    DASH_ATTACK,                -1)
    Character.edit_action_parameters(SKNIGHT, Action.Taunt,            File.SKNIGHT_SELECT,         TAUNT,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DTilt,            File.SKNIGHT_DTILT,          DTILT,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.FTilt,            File.SKNIGHT_FTILT,          FTILT,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.FTiltHigh,            File.SKNIGHT_FTILT,          FTILT,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.FTiltMidHigh,            File.SKNIGHT_FTILT,          FTILT,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.FTiltMidLow,            File.SKNIGHT_FTILT,          FTILT,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.FTiltLow,            File.SKNIGHT_FTILT,          FTILT,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.Crouch,            File.SKNIGHT_CROUCH,          CROUCH,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.CrouchIdle,            File.SKNIGHT_CROUCHIDLE,          CROUCH,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.CrouchEnd,            File.SKNIGHT_CROUCHEND,          CROUCH,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.Run,                  File.SKNIGHT_RUN,                 RUN,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.AttackAirB,            File.SKNIGHT_BAIR,          BAIR,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.UTilt,            File.SKNIGHT_UTILT,           UTILT,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.Dash,            File.SKNIGHT_DASH,           DASH,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.Jab2,                    0,                   SHOWEL,                 0)
    Character.edit_action_parameters(SKNIGHT, Action.AttackAirU,            File.SKNIGHT_UAIR,          UAIR,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.USmash,           File.SKNIGHT_USMASH,                          USMASH,               -1)
    Character.edit_action_parameters(SKNIGHT, Action.AttackAirN,            File.SKNIGHT_NAIR,          NAIR,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.FallSpecial,            File.SKNIGHT_DSPA2,        FALLSPECIAL,                       -1)

    Character.edit_action_parameters(SKNIGHT, Action.ShieldBreak,           -1,             SHIELDBREAK,                -1)
    Character.edit_action_parameters(SKNIGHT, Action.Stun,                  -1,             STUN,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.Sleep,                 -1,             SLEEP,                      -1) 

    Character.edit_action_parameters(SKNIGHT, Action.Walk1,                   -1,               SHOWEL,                         -1)
    Character.edit_action_parameters(SKNIGHT, Action.Walk2,                   -1,               SHOWEL,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.Walk3,                   File.SKNIGHT_WALK3,               SHOWEL,                       -1)

    Character.edit_action_parameters(SKNIGHT, Action.Tech,                  -1,                              TECH,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.TechF,                 -1,                             TECHF,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.TechB,                 -1,                             TECHF,                       -1)

    Character.edit_action_parameters(SKNIGHT, Action.ThrowF,                 File.SKNIGHT_THROWF,           THROWF,                       -1)
    Character.edit_action_parameters(SKNIGHT,   Action.ThrowB,          File.DRM_BTHROW,            BTHROW,                     0x50000000)

    Character.edit_action_parameters(SKNIGHT, 0xDF,                    File.SKNIGHT_NSPG,           NSP,                        0)
    Character.edit_action_parameters(SKNIGHT, Action.NSPA,             File.GOEMON_FAIR,           NSPA,                        0)

    Character.edit_action_parameters(SKNIGHT, 0xE3,                   File.SKNIGHT_DSPG,           DSP_GROUND,                 0)
    Character.edit_action_parameters(SKNIGHT, 0xE4,                   File.SKNIGHT_DSPA,           DSP_AIR,                    0)

    Character.edit_action_parameters(SKNIGHT, 0xE1,                   File.SKNIGHT_USP,          USP,                        0)
    Character.edit_action_parameters(SKNIGHT, Action.ShieldOn, 	      File.GOEMON_SHIELD_ON,   	    SHOWEL,                        -1)
    Character.edit_action_parameters(SKNIGHT, Action.DownAttackD,            File.GOEMON_DOWN_ATTACK_D,          DOWN_ATTACK_D,  -1)
    Character.edit_action_parameters(SKNIGHT, Action.DownAttackU,            File.GOEMON_DOWN_ATTACK_U,          DOWN_ATTACK_U,  -1)

    //Character.edit_action_parameters(SKNIGHT, Action.CliffWait,              File.GOEMON_CLIFF_WAIT,             -1,             -1)
    //Character.edit_action_parameters(SKNIGHT, Action.CliffClimbQuick2,       File.GOEMON_CLIFF_CLIMB_QUICK_2,    -1,             -1)
    //Character.edit_action_parameters(SKNIGHT, Action.CliffClimbSlow2,        File.GOEMON_CLIFF_CLIMB_SLOW_2,     -1,             -1)
    //Character.edit_action_parameters(SKNIGHT, Action.CliffAttackQuick1,      File.GOEMON_CLIFF_ATTACK_QUICK_1,   -1,             -1)
    Character.edit_action_parameters(SKNIGHT, Action.CliffAttackQuick2,      File.GOEMON_CLIFF_ATTACK_QUICK_2,   CLIFF_ATTACK_F,             -1)
    Character.edit_action_parameters(SKNIGHT, Action.CliffAttackSlow2,       File.GOEMON_CLIFF_ATTACK_SLOW_2,    CLIFF_ATTACK_S,             -1)
    //Character.edit_action_parameters(SKNIGHT, Action.CliffEscapeQuick2,      File.GOEMON_CLIFF_ESCAPE_QUICK_2,   -1,             -1)
    //Character.edit_action_parameters(SKNIGHT, Action.CliffEscapeSlow1,       File.GOEMON_CLIFF_ESCAPE_SLOW_1,    -1,             -1)
    Character.edit_action_parameters(SKNIGHT, Action.CliffEscapeSlow2,       File.GOEMON_CLIFF_ESCAPE_SLOW_2,    CLIFF_ESCAPE_S2,            -1)


    Character.edit_action_parameters(SKNIGHT, Action.DamageHigh1,             -1,        SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageHigh2,             -1,        SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageHigh3,             -1,        SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageMid1,              -1,         SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageMid2,              -1,         SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageMid3,              -1,         SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageLow1,              -1,         SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageLow2,              -1,         SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageLow3,              -1,         SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageAir1,              -1,         SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageAir2,              -1,         SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageAir3,              -1,         SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageElec1,             -1,         SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageElec2,             -1,         SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageFlyHigh,           -1,     SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageFlyMid,            -1,      SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageFlyLow,            -1,      SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageFlyTop,            File.CRASH_DAMAGE_FLY_TOP,      SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.DamageFlyRoll,           -1,     SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.Tumble,           -1,     SHOWEL,                      -1)

    Character.edit_action_parameters(SKNIGHT, Action.FalconDivePulled,           -1,     SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.RollB,                 -1,                             ROLLB,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.RollF,                 -1,                             ROLLF,                       -1)

    Character.edit_action_parameters(SKNIGHT,    Action.TurnRun,         File.GOEMON_TURN_RUN,       TURNRUN,                         -1)
    Character.edit_action_parameters(SKNIGHT,    Action.Turn,         File.WARIO_TURN,            TURN,                         -1)
    Character.edit_action_parameters(SKNIGHT,    Action.Teeter,         -1,       SHOWEL,                         -1)


    Character.edit_action_parameters(SKNIGHT,    Action.JumpSquat,       File.GOEMON_JUMPSQUAT,      SHOWEL,                         0)
    Character.edit_action_parameters(SKNIGHT,    Action.ShieldJumpSquat, File.GOEMON_JUMPSQUAT,      SHOWEL,                         0)
    Character.edit_action_parameters(SKNIGHT,    Action.LandingLight,    File.GOEMON_JUMPSQUAT,      LANDING,                         0)
    Character.edit_action_parameters(SKNIGHT,    Action.LandingHeavy,    File.GOEMON_JUMPSQUAT,      LANDING,                         0)
    Character.edit_action_parameters(SKNIGHT,    Action.LandingSpecial,  File.GOEMON_JUMPSQUAT,      LANDING,                         0)
    Character.edit_action_parameters(SKNIGHT,    Action.LandingAirB,     File.GOEMON_JUMPSQUAT,      LANDING,                         0)
    Character.edit_action_parameters(SKNIGHT,    Action.LandingAirU,     File.GOEMON_JUMPSQUAT,      LANDING,                         0)
    Character.edit_action_parameters(SKNIGHT,    Action.LandingAirD,     File.GOEMON_JUMPSQUAT,      LANDING,                         0)
    Character.edit_action_parameters(SKNIGHT,    Action.LandingAirX,     File.GOEMON_JUMPSQUAT,      LANDING,                         0)
    Character.edit_action_parameters(SKNIGHT,    Action.LandingAirF,     -1,      LANDING,                         0)
    Character.edit_action_parameters(SKNIGHT,    Action.RunBrake,        File.GOEMON_RUN_BRAKE,      RUNBRAKE,                         -1)

    Character.edit_action_parameters(SKNIGHT, Action.DownStandU,             File.GOEMON_DOWN_STAND_U,           SHOWEL,             -1)

    Character.edit_action_parameters(SKNIGHT,    Action.ClangRecoil,     -1,      SHOWEL,                         -1)
    Character.edit_action_parameters(SKNIGHT,    Action.EnterPipe,     -1,      SHOWEL,                         -1)
    Character.edit_action_parameters(SKNIGHT,    Action.ExitPipe,     -1,      SHOWEL,                         -1)
    Character.edit_action_parameters(SKNIGHT,    Action.ExitPipeWalk,     -1,      SHOWEL,                         -1)

    Character.edit_action_parameters(SKNIGHT,    Action.CapturePulled,     -1,      SHOWEL,                         -1)
    Character.edit_action_parameters(SKNIGHT,    Action.CaptureWait,     -1,      SHOWEL,                         -1)
    Character.edit_action_parameters(SKNIGHT,    Action.ThrownDKPulled,     -1,      SHOWEL,                         -1)

    Character.edit_action_parameters(SKNIGHT, Action.ThrownMarioBros,         -1,   SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.ThrownDK,                -1,           SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.Thrown1,                 -1,             SHOWEL,                      -1)
    Character.edit_action_parameters(SKNIGHT, Action.Thrown2,                 -1,             SHOWEL,                      -1)




    // Modify Actions             // Action             // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_menu_action_parameters(SKNIGHT,  0x1,               File.SKNIGHT_SELECT,         TAUNT,                   -1)
    Character.edit_menu_action_parameters(SKNIGHT,  0x2,               File.SKNIGHT_SELECT,         TAUNT,                   -1)
    Character.edit_menu_action_parameters(SKNIGHT,  0x3,               File.SKNIGHT_SELECT,         TAUNT,                   -1)
    Character.edit_menu_action_parameters(SKNIGHT,   0xD,               File.SKNIGHT_RUN,           RUN,                         -1)          // 1P Mode Pose
    Character.edit_menu_action_parameters(SKNIGHT,   0xE,               File.SKNIGHT_RUN,          RUN,                         -1)          // CPU Pose



    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(SKNIGHT, 0xE3,              -1,             0x800D94E8,                 SKnightDSP.ground_move_,          SKnightDSP.ground_physics_,       SKnightDSP.ground_collision_)
    Character.edit_action(SKNIGHT, 0xE4,              -1,             0x800D94E8,                 SKnightDSP.air_move_,             SKnightDSP.air_physics_,          SKnightDSP.air_collision_)

    Character.edit_action(SKNIGHT, 0xE1,              -1,             SKnightUSP.main_,             SKnightUSP.change_direction_,     SKnightUSP.physics_,              SKnightUSP.collision_)

    Character.edit_action(SKNIGHT,  Action.NSPA,          -1,             SKnightNSPA.main_,     -1,                         -1,                         -1)


    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags

    Character.add_new_action_params(SKNIGHT,  DSP_Recoil_Ground,  -1,             File.CRASH_DAMAGE_FLY_MID,    DSP_RECOIL,                 0)
    Character.add_new_action_params(SKNIGHT,  DSP_Recoil_Air,     -1,             File.CRASH_DAMAGE_FLY_MID,    DSP_RECOIL,                 0)

    Character.add_new_action_params(SKNIGHT,  USPG,               -1,             File.SKNIGHT_CLOUD_IDLE,   USP_IDLE,                    0)
    Character.add_new_action_params(SKNIGHT,  USPAttack,          -1,             File.SKNIGHT_USPG_ATTACK,  USP_ATTACK,                  0)
    Character.add_new_action_params(SKNIGHT,  USPJump,            -1,             File.SKNIGHT_JUMPAERIALF,      USP_JUMP,                    0)
    Character.add_new_action_params(SKNIGHT,  USPEscape,          -1,             File.GOEMON_USP_ESCAPE,    USP_ESCAPE,                  0)


    Character.add_new_action_params(SKNIGHT, DSPA,                -1,              File.SKNIGHT_DSPA2,           DSPA,                 0)



    // Add Actions                  // Action Name      // Base Action  //Parameters                        // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.add_new_action(SKNIGHT, DSP_Recoil_Ground,  -1,             ActionParams.DSP_Recoil_Ground,     0x12,           0x800D94C4,                 0,                              0x800D8BB4,                     SKnightDSP.recoil_ground_collision_)
    Character.add_new_action(SKNIGHT, DSP_Recoil_Air,     -1,             ActionParams.DSP_Recoil_Air,        0x12,           0x800D94E8,                 SKnightDSP.recoil_move_,          SKnightDSP.recoil_physics_,       SKnightDSP.recoil_air_collision_)


    Character.add_new_action(SKNIGHT, USPG,          -1,             ActionParams.USPG,          0x11,           SKnightUSPG.main_,                       SKnightUSPG.interrupt_,         SKnightUSPG.physics_,             SKnightUSPG.collision_)
    Character.add_new_action(SKNIGHT, USPAttack,     -1,             ActionParams.USPAttack,     0x11,           SKnightUSPG.attack_main_,                0,                              SKnightUSPG.physics_,             SKnightUSPG.collision_)
    Character.add_new_action(SKNIGHT, USPJump,       -1,             ActionParams.USPJump,       0x11,           SKnightUSPG.jump_main_,                  0,                              SKnightUSPG.jump_physics_,        SKnightUSPG.collision_)
    Character.add_new_action(SKNIGHT, USPEscape,     -1,             ActionParams.USPEscape,     0x11,           SKnightUSPG.escape_main_,                0,                              0x800D9160,                       SKnightUSPG.collision_)

    Character.add_new_action(SKNIGHT, DSPA,          -1,             ActionParams.DSPA,          0x11,           SKnightDSP2.begin_main_,                 SKnightDSP2.air_move_,          SKnightDSP2.air_physics_,       SKnightDSP2.air_collision_)
 
   // Modify Actions             // Action             // Staling ID   // Main ASM         // Interrupt/Other ASM      // Movement/Physics ASM     // Collision ASM
    Character.edit_action(SKNIGHT, 0xE0,              -1,             -1,                         -1,                             0x800D91EC,                     -1)




    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(SKNIGHT, 0x0,              File.SKNIGHT_IDLE,            IDLE,                       -1)
    Character.edit_menu_action_parameters(SKNIGHT, 0x4,              File.SKNIGHT_SELECT,          TAUNT,                     -1)
    Character.edit_menu_action_parameters(SKNIGHT, 0x5,            File.SKNIGHT_CLOUD_IDLE,                             SHOWEL,            -1)
    Character.edit_menu_action_parameters(SKNIGHT, 0xE,            File.GOEMON_1P_CPU,             SHOWEL,            -1)
    Character.edit_menu_action_parameters(SKNIGHT,  0x9,      -1,   SHOWEL,                         -1)
    Character.edit_menu_action_parameters(SKNIGHT, 0xA,            -1,          TAUNT,             -1)


    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.SKNIGHT, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()


    Character.table_patch_start(air_nsp, Character.id.SKNIGHT, 0x4)
    dw      SKnightNSPA.air_initial_
    OS.patch_end()
    // Set the fireball jump table routines for Piano's book projectile.
    Character.table_patch_start(fireball, Character.id.SKNIGHT, 0x4)
    dw      Fireball.BookSK.create_
    OS.patch_end()
    Character.table_patch_start(kirby_fireball, Character.id.SKNIGHT, 0x4)
    dw      Fireball.BookSK.create_
    OS.patch_end()

    Character.table_patch_start(ground_dsp, Character.id.SKNIGHT, 0x4)
    dw      SKnightDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.SKNIGHT, 0x4)
    dw      SKnightDSP2.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_usp, Character.id.SKNIGHT, 0x4)
    dw      SKnightUSPG.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.SKNIGHT, 0x4)
    dw      SKnightUSP.initial_
    OS.patch_end()


    // Set default costumes
    Character.set_default_costumes(Character.id.SKNIGHT, 0, 1, 2, 3, 2, 0, 1)
    Teams.add_team_costume(YELLOW, SKNIGHT, 4)


    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.SKNIGHT, 0x2)
    dh  0x06DE
    OS.patch_end()


    // // down bounce
    scope dair_bounce_sknight_: {
        OS.patch_start(0xCB32C, 0x801508EC)
        j       dair_bounce_sknight_
        lw      v1, 0x0008(v0)              // v1 = character id (original line 2)
        _return:
        OS.patch_end()


        lli     at, Character.id.NCRASH     // check if stinky crash
        beq     at, v1, _crash_behaviour        // do special crash scrimblo function
        nop
        lli     at, Character.id.CRASH
        beq     at, v1, _crash_behaviour           // skip if character != Crash
        nop


        lli     at, Character.id.SKNIGHT
        beq     at, v1, _sknight_behaviour        // do special crash scrimblo function
        nop


        bne     at, v1, _original           // skip if character != Crash nor Sknight
        nop


        // if the character is Sknight, do custom DAir bounce behaviour
        // v0 = player struct
        _sknight_behaviour:
        lbu     t7, 0x018D(v0)              // ~
        andi    t7, t7, 0xFFF7              // ~
        sb      t7, 0x018D(v0)              // disable fast fall flag
        lui     at, 0x4268                  // ~
        sw      at, 0x004C(v0)              // set y velocity to 50
        lli     a1, Action.AttackAirD       // a1 (action) = AttackAirD
        lui     a2, 0x420C                  // a2 (starting frame) = 35
        lui     a3, 0x3F80                  // a3 (fsm) = 1
        sw      r0, 0x0010(sp)              // argument 4 = 0
        j       _original
        nop





        // if the character is Crash, do custom DAir bounce behaviour
        // v0 = player struct
        _crash_behaviour:
        lbu     t7, 0x018D(v0)              // ~
        andi    t7, t7, 0xFFF7              // ~
        sb      t7, 0x018D(v0)              // disable fast fall flag
        lui     at, 0x4248                  // ~
        sw      at, 0x004C(v0)              // set y velocity to 50
        lli     a1, Action.AttackAirD       // a1 (action) = AttackAirD
        lui     a2, 0x420C                  // a2 (starting frame) = 35
        lui     a3, 0x3F80                  // a3 (fsm) = 1
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0

        // end the function now
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space


        _original:
        j       _return                     // continue original function
        lli     at, 0x0005                  // original line 1

    }



}
