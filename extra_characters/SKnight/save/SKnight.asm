// Sknight.asm

// This file contains file inclusions, action edits, and assembly for Shovel Knight.

scope SKnight {


    scope MODEL {
        scope WEAPON {
            constant DEFAULT(0xA0800000)
            constant HAND(0xA0800001)
            constant SHOVEL(0xA0800002)
            constant DAGGER(0xA0800003)
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
    JAB_1:; dw MODEL.WEAPON.SHOVEL; insert "moveset/JAB_1.bin"
    JUMP:; dw MODEL.WEAPON.SHOVEL; insert "moveset/JUMPB.bin"
    TAUNT:; dw MODEL.WEAPON.SHOVEL; insert "moveset/TAUNT.bin"
    USMASH:; dw MODEL.WEAPON.SHOVEL; insert "moveset/USMASH.bin"
    JUMPA:; dw MODEL.WEAPON.SHOVEL; insert "moveset/JUMP_AERIAL.bin"
    IDLE:; dw MODEL.WEAPON.SHOVEL; insert "moveset/IDLE.bin"
    insert NSP, "moveset/NEUTRAL_SPECIAL.bin"
    insert DSP_RECOIL,"moveset/DOWN_SPECIAL_RECOIL.bin"
    insert DSP_TRAIL,"moveset/DOWN_SPECIAL_TRAIL.bin"
    DSP_GROUND:; dw MODEL.WEAPON.DAGGER; Moveset.CONCURRENT_STREAM(DSP_TRAIL); insert "moveset/DOWN_SPECIAL_GROUND.bin"
    DSP_AIR:; dw MODEL.WEAPON.DAGGER; Moveset.CONCURRENT_STREAM(DSP_TRAIL); insert "moveset/DOWN_SPECIAL_AIR.bin"
    insert USP_TRAIL,"moveset/UP_SPECIAL_TRAIL.bin"
    USP:; Moveset.CONCURRENT_STREAM(USP_TRAIL); insert "moveset/UP_SPECIAL.bin"
    insert APPEAR, "moveset/APPEAR.bin"

    USP_IDLE:; dw 0;
    insert USP_JUMP, "moveset/USP_JUMP.bin"
    insert USP_ESCAPE, "moveset/USP_ESCAPE.bin"
    insert USP_ATTACK, "moveset/USP_ATTACK.bin"


    NSPA2:
    Moveset.HIDE_ITEM()

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
    Character.edit_action_parameters(SKNIGHT, Action.Jab1,             -1,                          JAB_1,                       -1)
    Character.edit_action_parameters(SKNIGHT, 0xDE,                    File.CRASH_APPEAR_L,         APPEAR,                     -1)
    Character.edit_action_parameters(SKNIGHT, 0xDD,                    File.CRASH_APPEAR_R,         APPEAR,                     -1)
    Character.edit_action_parameters(SKNIGHT, 0x006,                   File.SKNIGHT_IDLE,           IDLE,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.AttackAirD,       File.SKNIGHT_DAIR,           DAIR,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.JumpF,            File.SKNIGHT_JUMPF,          JUMP,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.JumpB,            -1,                          JUMP,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.JumpAerialF,      -1,                          JUMPA,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.JumpAerialB,      -1,                          JUMPA,                       -1)
    Character.edit_action_parameters(SKNIGHT, Action.Fall,             File.SKNIGHT_FALL,           -1,                         -1)
	Character.edit_action_parameters(SKNIGHT, Action.Idle,             File.SKNIGHT_IDLE,           -1,                         -1)
    Character.edit_action_parameters(SKNIGHT, Action.ReviveWait,       File.SKNIGHT_IDLE,           -1,                         -1)
    Character.edit_action_parameters(SKNIGHT, Action.EggLay,           File.SKNIGHT_IDLE,           -1,                         -1)
    Character.edit_action_parameters(SKNIGHT, Action.Entry,            File.SKNIGHT_IDLE,           -1,                         -1)
    Character.edit_action_parameters(SKNIGHT, Action.AttackAirF,       File.SKNIGHT_FAIR,           ATTACK_AIR_F,               -1)
    Character.edit_action_parameters(SKNIGHT, Action.DSmash,           File.SKNIGHT_DSMASH,         DSMASH,               -1)
    Character.edit_action_parameters(SKNIGHT, Action.FSmash,           File.SKNIGHT_FSMASH,         FSMASH,               -1)
    Character.edit_action_parameters(SKNIGHT, Action.USmash,           -1,                          USMASH,               -1)
    Character.edit_action_parameters(SKNIGHT, Action.DashAttack,       File.SKNIGHT_DASH_ATTACK,    DASH_ATTACK,                -1)
    Character.edit_action_parameters(SKNIGHT, Action.Taunt,            File.SKNIGHT_SELECT,         TAUNT,                      -1)
    Character.edit_action_parameters(SKNIGHT, 0xDF,                    File.SKNIGHT_NSPG,           NSP,                        0)
    Character.edit_action_parameters(SKNIGHT, Action.NSPA,             File.GOEMON_FAIR,         NSPA,                        0)

    Character.edit_action_parameters(SKNIGHT, 0xE3,                   File.SKNIGHT_DSPG,           DSP_GROUND,                 0)
    Character.edit_action_parameters(SKNIGHT, 0xE4,                   File.SKNIGHT_DSPA,           DSP_AIR,                    0)

    Character.edit_action_parameters(SKNIGHT, 0xE1,                   File.SKNIGHT_SELECT,          USP,                        0)
    Character.edit_action_parameters(SKNIGHT, Action.ShieldOn, 	      File.GOEMON_SHIELD_ON,   	    -1,                        -1)





    // Modify Actions             // Action             // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM




    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(SKNIGHT, 0xE3,              -1,             0x800D94E8,                 SKnightDSP.ground_move_,          SKnightDSP.ground_physics_,       SKnightDSP.ground_collision_)
    Character.edit_action(SKNIGHT, 0xE4,              -1,             0x800D94E8,                 SKnightDSP.air_move_,             SKnightDSP.air_physics_,          SKnightDSP.air_collision_)

    Character.edit_action(SKNIGHT, 0xE1,              -1,             SKnightUSP.main_,             SKnightUSP.change_direction_,     SKnightUSP.physics_,              SKnightUSP.collision_)

    Character.edit_action(SKNIGHT,  Action.NSPA,          -1,             SKnightNSPA.main_,     -1,                         -1,                         -1)


    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(SKNIGHT,  DSP_Recoil_Ground,  -1,             File.SKNIGHT_FSMASH,    DSP_RECOIL,                 0)
    Character.add_new_action_params(SKNIGHT,  DSP_Recoil_Air,     -1,             File.SKNIGHT_FSMASH,    DSP_RECOIL,                 0)

    Character.add_new_action_params(SKNIGHT,  USPG,               -1,             File.GOEMON_USP_LOOP,      USP_IDLE,                    0)
    Character.add_new_action_params(SKNIGHT,  USPAttack,          -1,             File.GOEMON_USP_ATTACK,    USP_ATTACK,                  0)
    Character.add_new_action_params(SKNIGHT,  USPJump,            -1,             File.GOEMON_USP_JUMP,      USP_JUMP,                    0)
    Character.add_new_action_params(SKNIGHT,  USPEscape,          -1,             File.GOEMON_USP_ESCAPE,    USP_ESCAPE,                  0)


    // Add Actions                  // Action Name      // Base Action  //Parameters                        // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.add_new_action(SKNIGHT, DSP_Recoil_Ground,  -1,             ActionParams.DSP_Recoil_Ground,     0x12,           0x800D94C4,                 0,                              0x800D8BB4,                     SKnightDSP.recoil_ground_collision_)
    Character.add_new_action(SKNIGHT, DSP_Recoil_Air,     -1,             ActionParams.DSP_Recoil_Air,        0x12,           0x800D94E8,                 SKnightDSP.recoil_move_,          SKnightDSP.recoil_physics_,       SKnightDSP.recoil_air_collision_)


    Character.add_new_action(SKNIGHT, USPG,          -1,             ActionParams.USPG,          0x11,           SKnightUSPG.main_,                       SKnightUSPG.interrupt_,         SKnightUSPG.physics_,             SKnightUSPG.collision_)
    Character.add_new_action(SKNIGHT, USPAttack,     -1,             ActionParams.USPAttack,     0x11,           SKnightUSPG.attack_main_,                0,                              SKnightUSPG.physics_,             SKnightUSPG.collision_)
    Character.add_new_action(SKNIGHT, USPJump,       -1,             ActionParams.USPJump,       0x11,           SKnightUSPG.jump_main_,                  0,                              SKnightUSPG.jump_physics_,        SKnightUSPG.collision_)
    Character.add_new_action(SKNIGHT, USPEscape,     -1,             ActionParams.USPEscape,     0x11,           SKnightUSPG.escape_main_,                0,                              0x800D9160,                       SKnightUSPG.collision_)

    // Modify Actions             // Action             // Staling ID   // Main ASM         // Interrupt/Other ASM      // Movement/Physics ASM     // Collision ASM
    Character.edit_action(SKNIGHT, 0xE0,              -1,             -1,                         -1,                             0x800D91EC,                     -1)




    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(SKNIGHT, 0x0,              File.SKNIGHT_IDLE,            -1,                         -1)
    Character.edit_menu_action_parameters(SKNIGHT, 0x4,              File.SKNIGHT_SELECT,          SELECT,                     -1)


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
    dw      SKnightDSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_usp, Character.id.SKNIGHT, 0x4)
    dw      SKnightUSPG.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.SKNIGHT, 0x4)
    dw      SKnightUSP.initial_
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
