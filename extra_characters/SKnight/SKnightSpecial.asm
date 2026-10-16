// @ Description
// Subroutines for Up Special
scope SKnightUSPG {
    constant GROUND_SPEED(0x42A0)           // float32 80
    constant JUMP_SPEED(0x4280)             // float32 64
    constant ESCAPE_SPEED(0x4160)           // float32 14
    constant MIN_SPEED(0x4040)              // float32 3
    constant ACCELERATION(0x4000)           // float32 2
    constant LANDING_FSM(0x3E80)            // float32 0.25
    constant MAX_TIME(80)

    // @ Description
    // Initial subroutine for USP while grounded.
    scope ground_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     at, GROUND_SPEED            // at = GROUND_SPEED
        jal     0x800DEEC8                  // set aerial state
        sw      at, 0x004C(a0)              // y velocity = GROUND_SPEED
        jal     air_initial_                // transition to USP
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for USP.
    scope air_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, SKnight.Action.USPG       // a1(action id) = USP
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object

        jal     attach_cloud_               // attach_cloud_
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // a0 = player object
        jal     goemon_on_hit_subroutine_establishment_ // on hit subroutine setup
        lw      a0, 0x0084(a0)              // a0 = player struct

        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     t6, 0x3EC0                  // ~
        mtc1    t6, f0                      // f0 = 0.375
        lwc1    f2, 0x004C(a0)              // f2 = y velocity
        mul.s   f2, f2, f0                  // f2 = y velocity * 0.375
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        lli     at, 0x0001                  // ~
        sw      at, 0x0180(a0)              // temp variable 2 = 1
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        sw      r0, 0x0B18(a0)              // frame timer = 0
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        lw      t6, 0x09C8(a0)              // t6 = attribute pointer
        lw      t6, 0x0064(t6)              // t0 = max jumps
        sb      t6, 0x0148(a0)              // jumps used = max jumps
        swc1    f2, 0x004C(a0)              // store updated y velocity
        FGM.play(0x62F)                     // play cloud spawn sfx

        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Shared initial subroutine for USP actions.
    // @ Arguments
    // a0 - player object
    // a1 - action id
    scope shared_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lli     at, 0x0001                  // ~
        sw      at, 0x0180(a0)              // temp variable 2 = 1
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Checks for turnaround inputs.
    // @ Arguments
    // a0 - player object
    scope check_turn_: {
        // begin by checking for turn inputs
        lw      a1, 0x0084(a0)              // a1 = player struct
        lb      t6, 0x01C2(a1)              // t6 = stick_x
        lw      t7, 0x0044(a1)              // t7 = DIRECTION
        multu   t6, t7                      // ~
        mflo    t6                          // t6 = stick_x * DIRECTION
        slti    at, t6, -39                 // at = 1 if stick_x < -39, else at = 0
        beqz    at, _end                    // branch if stick_x >= -39
        nop

        // if we're here, stick_x is opposite the facing direction, so turn the character around
        subu    t7, r0, t7                  // ~
        sw      t7, 0x0044(a1)              // reverse and update DIRECTION

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main function for USP
    scope main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      t6, 0x0B18(v1)              // t6 = frame timer
        slti    at, t6, MAX_TIME            // at = 1 if frame timer < MAX_TIME, else at = 0
        addiu   t6, t6, 0x0001              // ~
        bnez    at, _end                    // branch if frame timer < MAX_TIME
        sw      t6, 0x0B18(v1)              // increment frame timer


        // if frame timer has reached MAX_TIME
        jal     check_turn_                 // check for turnaround inputs
        nop
        jal     shared_initial_             // transition to USP action
        lli     a1, SKnight.Action.USPJump   // a1(action id) = USPJump
        b       _end                        // end
        nop

        // _check_turn:
        // lwc1    f2, 0x0048(v1)              // ~
        // abs.s   f2, f2                      // ~
        // cvt.w.s f2, f2                      // ~
        // lui     at, 0x8000                  // at = sign bitmask
        // lw      t6, 0x0044(v1)              // t6 = DIRECTION
        // lw      t7, 0x0048(v1)              // t7 = x velocity
        // and     t6, t6, at                  // t6 = DIRECTION sign
        // and     t7, t7, at                  // t7 = x velocity sign
        // mfc1    at, f2                      // at = int(|x velocity|)
        // sltiu   at, 4                       // at = 1 if int(|x velocity|) < 4, else at = 0
        // bnezl   at, _end                    // end if x velocity < 4...
        // lw      ra, 0x0024(sp)              // ...and load ra
        // beql    t6, t7, _end                // end if DIRECTION and x velocity signs match...
        // lw      ra, 0x0024(sp)              // ...and load ra
        //
        // // if the signs of DIRECTION and x velocity don't match, begin a turn
        // jal     shared_initial_             // transition to USP action
        // lli     a1, SKnight.Action.USPTurn   // a1(action id) = USPTurn
        // lw      ra, 0x0024(sp)              // load ra

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // scrapped turn action
    // // @ Description
    // // Main function for USPTurn.
    // scope turn_main_: {
    //     addiu   sp, sp,-0x0030              // allocate stack space
    //     sw      ra, 0x0024(sp)              // store ra
    //     lw      v1, 0x0084(a0)              // v1 = player struct
    //     lw      t6, 0x0B18(v1)              // t6 = frame timer
    //     slti    at, t6, MAX_TIME            // at = 1 if frame timer < MAX_TIME, else at = 0
    //     addiu   t6, t6, 0x0001              // ~
    //     bnez    at, _check_end_transition   // branch if frame timer < MAX_TIME
    //     sw      t6, 0x0B18(v1)              // increment frame timer
    //
    //     // if frame timer has reached MAX_TIME
    //     lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
    //     or      a2, r0, r0                  // a2 (unknown) = 0
    //     lli     a3, 0x0001                  // a3 (unknown) = 1
    //     sw      r0, 0x0010(sp)              // unknown argument = 0
    //     sw      r0, 0x0018(sp)              // interrupt flag = FALSE
    //     lui     t6, LANDING_FSM             // t6 = LANDING_FSM
    //     jal     0x801438F0                  // begin special fall
    //     sw      t6, 0x0014(sp)              // store LANDING_FSM
    //     b       _end                        // end
    //     nop
    //
    //     _check_end_transition:
    //     // checks the current animation frame to see if we've reached end of the animation
    //     mtc1    r0, f6                      // ~
    //     lwc1    f8, 0x0078(a0)              // ~
    //     c.le.s  f8, f6                      // ~
    //     bc1fl   _end                        // skip if animation end has not been reached
    //     nop
    //     lw      at, 0x0044(v1)              // at = DIRECTION
    //     subu    at, r0, at                  // ~
    //     sw      at, 0x0044(v1)              // reverse and update DIRECTION
    //     jal     shared_initial_             // transition to USP action
    //     lli     a1, SKnight.Action.USPG       // a1(action id) = USP
    //
    //     _end:
    //     lw      ra, 0x0024(sp)              // load ra
    //     jr      ra                          // return
    //     addiu   sp, sp, 0x0030              // deallocate stack space
    // }

    // @ Description
    // Main function for USPAttack.
    scope attack_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      t6, 0x0B18(v1)              // t6 = frame timer
        slti    at, t6, MAX_TIME            // at = 1 if frame timer < MAX_TIME, else at = 0
        addiu   t6, t6, 0x0001              // ~
        bnez    at, _check_end_transition   // branch if frame timer < MAX_TIME
        sw      t6, 0x0B18(v1)              // increment frame timer

        // if frame timer has reached MAX_TIME
        lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        b       _end                        // end
        nop

        _check_end_transition:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     shared_initial_             // transition to USP action
        lli     a1, SKnight.Action.USPG       // a1(action id) = USP

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main subroutine for USPJump.
    // Transitions to special fall on animation end.
    scope jump_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra

        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      t6, 0x017C(v1)              // t6 = temp variable 1
        lli     at, 0x0001                  // ~
        bne     t6, at, _check_end_transition // branch if temp variable 1 != 1
        lli     at, 0x0002                  // ~

        // apply jump velocity if temp variable 1 = 1
        sw      at, 0x017C(v1)              // temp variable 1 = 2
        lui     at, JUMP_SPEED              // ~
        sw      at, 0x004C(v1)              // y velocity = JUMP_SPEED

        _check_end_transition:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        // begin a special fall if the end of the animation has been reached
        lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main subroutine for USPEscape.
    // Transitions to special fall on animation end.
    scope escape_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra

        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        // begin a special fall if the end of the animation has been reached
        lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Interrupt function for USP actions
    scope interrupt_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      a1, 0x0084(a0)              // a1 = player struct

        // begin by checking for A and B presses
        lhu     v0, 0x01BE(a1)              // v0 = buttons_pressed
        andi    at, v0, Joypad.B | Joypad.A // at = !0 if (B_PRESSED) or (A_PRESSED), else t6 = 0
        beqz    at, _check_escape           // branch if both A and B are not being pressed
        nop

        // if we're here, A or B has been pressed, so transition to USPAttack
        jal     check_turn_                 // check for turnaround inputs
        nop
        jal     shared_initial_             // transition to USP action
        lli     a1, SKnight.Action.USPAttack // a1(action id) = USPAttack
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _check_escape:
        // now check if Shield button has been pressed
        lhu     at, 0x01B8(a1)              // at = shield press bitmask
        and     at, at, v0                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _check_jump         // branch if shield is not pressed
        nop

        // if we're here, Shield has been pressed, so transition to USPEscape
        lui     at, ESCAPE_SPEED            // ~
        sw      at, 0x004C(a1)              // y velocity = ESCAPE_SPEED
        jal     shared_initial_             // transition to USP action
        lli     a1, SKnight.Action.USPEscape // a1(action id) = USPEscape
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _check_jump:
        // finally, check for C inputs
        // at = !0 if (CU_PRESSED) or (CD_PRESSED) or (CL_PRESSED) or (CR_PRESSED), else t6 = 0
        andi    at, v0, Joypad.CU | Joypad.CD | Joypad.CL | Joypad.CR
        beqzl   at, _end                    // branch if no c buttons are being pressed...
        lw      ra, 0x0014(sp)              // ...and load ra

        // if we're here, a C button has been pressed, so transition to USPJump
        jal     check_turn_                 // check for turnaround inputs
        nop
        jal     shared_initial_             // transition to USP action
        lli     a1, SKnight.Action.USPJump   // a1(action id) = USPJump
        lw      ra, 0x0014(sp)              // load ra

        _end:
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // dellocate stack space
    }

    // @ Description
    // Handles movement for USP actions.
    scope physics_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      s0, 0x0024(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct

        _check_movement:
        lb      t6, 0x01C2(s0)              // t6 = stick_x
        bltzl   t6, pc() + 8                // if stick_x is negative...
        subu    t6, r0, t6                  // ...make stick_x positive
        lb      t7, 0x01C3(s0)              // t7 = stick_y
        bltzl   t7, pc() + 8                // if stick_x is negative...
        subu    t7, r0, t7                  // ...make stick_y positive
        slti    at, t6, 11                  // at = 1 if |stick_x| < 11, else at = 0
        beqz    at, _check_stick            // branch if |stick_x| >= 10
        slti    at, t7, 11                  // at = 1 if |stick_y| < 11, else at = 0
        beqz    at, _check_stick            // branch if |stick_y| >= 10
        nop

        _check_min_speed:
        // if we're here then stick_x and stick_y are both < 11, so consider the stick neutral
        lwc1    f2, 0x0048(s0)              // f2 = x velocity
        mul.s   f2, f2, f2                  // f2 = x velocity^2
        lwc1    f4, 0x004C(s0)              // f4 = y velocity
        mul.s   f4, f4, f4                  // f4 = y velocity^2
        add.s   f4, f2, f4                  // ~
        sqrt.s  f4, f4                      // f4 = current speed = sqrt(x velocity^2 + y velocity^2)
        lui     at, MIN_SPEED               // ~
        mtc1    at, f6                      // f6 = MIN_SPEED
        c.le.s  f4, f6                      // ~
        mtc1    r0, f2                      // target x velocity = 0
        bc1fl   _apply_movement             // apply movement if current speed < MIN_SPEED...
        mtc1    r0, f4                      // ...and target y velocity = 0
        // set velocity to 0 if below minimum speed
        sw      r0, 0x0048(s0)              // x velocity = 0
        b       _end                        // end
        sw      r0, 0x004C(s0)              // y velocity = 0

        _check_stick:
        lui     at, 0x3F08                  // ~
        mtc1    at, f0                      // f0 = 0.53125
        lb      at, 0x01C2(s0)              // ~
        mtc1    at, f2                      // ~
        cvt.s.w f2, f2                      // f2 = stick_x
        mul.s   f2, f2, f0                  // f2 = target x velocity = stick_x * 0.53125
        lb      at, 0x01C3(s0)              // ~
        mtc1    at, f4                      // ~
        cvt.s.w f4, f4                      // f4 = stick_y
        mul.s   f4, f4, f0                  // f4 = target y velocity = stick_y * 0.53125
        mul.s   f6, f2, f2                  // ~
        mul.s   f8, f4, f4                  // ~
        add.s   f6, f6, f8                  // ~
        sqrt.s  f6, f6                      // f6 = absolute target velocity
        lui     at, 0x422A                  // ~
        mtc1    at, f8                      // f8 = 42.5 = 80 * 0.53125
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _apply_movement             // branch if absolute target velocity < 50
        nop

        // adjust the target velocity if it is above 80
        div.s   f10, f8, f6                 // f10 = velocity multiplier = 80 / absolute target velocity
        mul.s   f2, f2, f10                 // f2 = adjusted target x velocity
        mul.s   f4, f4, f10                 // f4 = adjusted target y velocity

        _apply_movement:
        lwc1    f6, 0x0048(s0)              // f6 = x velocity
        lwc1    f8, 0x004C(s0)              // f8 = y velocity
        sub.s   f14, f2, f6                 // f14 = X_DIFF
        jal     0x8001863C                  // f0 = atan2(f12,f14)
        sub.s   f12, f4, f8                 // f12 = Y_DIFF
        // f0 = acceleration angle
        swc1    f0, 0x0028(sp)              // 0x0028(sp) = acceleration angle
        jal     0x80035CD0                  // f0 = cos(f12)
        lwc1    f12, 0x0028(sp)             // f12 = acceleration angle
        lui     at, ACCELERATION            // ~
        mtc1    at, f2                      // f2 = ACCELERATION
        mul.s   f2, f2, f0                  // f2 = x velocity difference(ACCELERATION * cos(angle))
        lwc1    f4, 0x0048(s0)              // f4 = x velocity
        add.s   f4, f4, f2                  // f4 = x velocity + x velocity difference
        swc1    f4, 0x0048(s0)              // store updated x velocity
        // ultra64 sinf function
        jal     0x800303F0                  // f0 = sin(f12)
        lwc1    f12, 0x0028(sp)             // f12 = acceleration angle
        lui     at, ACCELERATION            // ~
        mtc1    at, f2                      // f2 = ACCELERATION
        mul.s   f2, f2, f0                  // f2 = y velocity difference(ACCELERATION * sin(angle))
        lwc1    f4, 0x004C(s0)              // f4 = y velocity
        add.s   f4, f4, f2                  // f4 = y velocity + y velocity difference
        swc1    f4, 0x004C(s0)              // store updated x velocity

        _end:
        lw      s0, 0x0024(sp)              // ~
        lw      ra, 0x0014(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Handles physics for USPJump
    scope jump_physics_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      t6, 0x017C(v1)              // t6 = temp variable 1
        bnez    t6, _control                // branch if temp variable 1 is set
        nop

        // before temp variable 1 is set
        jal     physics_                    // USP physics function
        nop
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _control:
        jal     0x800D9160                  // general physics function (allows player control)
        nop
        lw      ra, 0x0014(sp)              // load ra

        _end:
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for Goemons's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Goemon.
    scope collision_: {
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }

    // @ Description
    // Establishment of on hit routine for USP, based on 0x8015DB4C
    scope goemon_on_hit_subroutine_establishment_: {
       li       t6, goemon_on_hit_subroutine_
       sw       t6, 0x09EC(a0)
       sw       r0, 0x0B20(a0)

       jr       ra
       sw       r0, 0x017C(a0)
    }

    // @ Description
    // On hit routine for USP.
    scope goemon_on_hit_subroutine_: {
       addiu    sp, sp,-0x0018              // allocate stack space
       sw       ra, 0x0014(sp)              // store ra
       lw       a0, 0x0084(a0)              // a0 = player struct
       jal      destroy_attached_cloud_    // destroy attached minion
       sw       r0, 0x0AE4(a0)              // reset charge level
       lw       ra, 0x0014(sp)              // load ra
       jr       ra                          // return
       addiu    sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which attaches a cloud to Goemon's Feet.
    // a0 - player object
    scope attach_cloud_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0038(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct

        _goemon:
        li      t7, goemon_on_hit_subroutine_ // t7 = on hit subroutine

        _continue:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        or      a0, s0, r0                  // a0 = player struct
        jal     0x8015D35C                  // get part position
        addiu   a1, sp, 0x0028              // a1 = address to return x/y/z coordinates to
        lw      a0, 0x0038(sp)              // a0 = player object
        addiu   a2, sp, 0x0028              // x/y/z coordinates

		// makes a cloud
        lw      a0, 0x0038(sp)              // 0x0034(sp) = player object
        lw      t0, 0x0084(a0)              // loads player struct
        addiu   a3, sp, 0x0040              // a3 = unknown x/y/z offset
        sw      r0, 0x0000(a3)              // x offset
        sw      r0, 0x0004(a3)              // set y offset to 0
        sw      r0, 0x0008(a3)              // z offset
        li      a1, Item.CloudSK.item_info_array // a1 = cloud

        _create_cloud:
        jal     Item.CloudSK.SPAWN_ITEM           // create item
        addiu   a3, sp, 0x0040                  // a3 = unknown x/y/z offset
        beqz    v0, _end                     // end if item not created
        li      at, Size.item.render_routine_
        sw      at, 0x002C(v0)              // set custom render routine so size is obeyed

        _end:
        sw      v0, 0x0B20(s0)              // store attached item object
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

    // @ Description
    // Destroys Goemon's attached item object.
    // @ Arguments
    // a0 - player struct
    scope destroy_attached_cloud_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      a1, 0x0B20(a0)              // a1 = attached item object
        beqz    a1, _end                    // skip if no attached item object
        sw      r0, 0x0B20(a0)              // reset attached item object

        or      a0, a1, r0                  // a0 = attached item object
        lw      a1, 0x0084(a0)              // a1 = item special struct
        lli     at, 0x001C                  // at = fake item id
        jal     0x801728D4                  // destroy item
        sw      at, 0x000C(a1)              // override item id to prevent smoke gfx

        _end:
        lw       ra, 0x0014(sp)             // load ra
        jr       ra                         // return
        addiu    sp, sp, 0x0018             // deallocate stack space
    }

}

// @ Description


// For his neutral special, Lanky Kong wields his iconic Grape Shooter
scope SKnightNSPA {

    // @ Description
    // Subroutine which runs when Lanky initiates an aerial neutral special.
    scope air_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.LANKY_NSP_Air
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.LANKY_NSP_Air

        lli     a1, SKnight.Action.NSPA       // a1(action id) = NSPA
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lli     at, 3                       // ~
        sw      at, 0x0B20(a0)              // ammo = 3
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for neutral special.
    // If temp variable 1 is set by moveset, create a projectile.
    scope main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player object
        addu    a2, a0, r0                  // a2 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t6, 0x017C(v0)              // t6 = temp variable 1
        beq     t6, r0, _cancel_check       // skip if temp variable 1 = 0
        sw      r0, 0x017C(v0)              // reset temp variable 1 to 0

        // if we're here, then temp variable 1 was enabled, so create a projectile
        lw      t6, 0x0008(v0)              // t6 = current character ID

        // if kinetic state = aerial
        lli     at, Kirby.Action.LANKY_NSP_Air - SKnight.Action.NSPA
        lw      a2, 0x0008(v0)              // a2 = current character ID
        lli     t6, Character.id.KIRBY      // t6 = id.KIRBY
        beq     t6, a2, _kirby              // branch if Kirby
        lli     t6, Character.id.JKIRBY     // t6 = id.JKIRBY
        beq     t6, a2, _kirby              // branch if JKirby
        lw      a0, 0x0930(v0)              // a0 = part 0xE (weapon) struct
        sw      r0, 0x0020(sp)              // x offset = 0
        lui     at, 0xC348                  // ~
        sw      at, 0x0024(sp)              // y offset = -200
        b       _continue
        sw      r0, 0x0028(sp)              // z offset = 0

        _kirby:
        lw      a0, 0x092C(v0)              // a0 = part 0xD (weapon) struct
        lui     at, 0x4396                  // ~
        sw      at, 0x0020(sp)              // x offset = 200
        sw      r0, 0x0024(sp)              // y offset = 0
        sw      r0, 0x0028(sp)              // z offset = 0

        _continue:
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        sw      v0, 0x002C(sp)              // 0x002C(sp) = player struct
        sw      r0, 0x0028(sp)              // set z coordinate to 0
        lw      v0, 0x002C(sp)              // v0 = player struct
        lw      a0, 0x0034(sp)              // a0 = player object
        jal     grape_stage_setting_        // INITIATE GRAPE
        addiu   a1, sp, 0x0020              // a1 = coordinates to create projectile at
        lw      a0, 0x0034(sp)              // a0 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct

        _cancel_check:
        lw      t6, 0x0180(v0)              // t6 = temp variable 2
        beq     t6, r0, _idle_check         // skip if temp variable 2 = 0
        lhu     t7, 0x01BE(v0)              // t7 = buttons_pressed

        andi    at, t7, Joypad.B            // at = !0 if (B_PRESSED), else t6 = 0
        beqz    at, _idle_check             // skip if B isn't pressed
        nop

        // if B was pressed
        lw      t0, 0x0B20(v0)              // t0 = ammo
        addiu   at, t0,-0x0001              // at = ammo - 1
        sw      at, 0x0B20(v0)              // store updated ammo...





        beqzl   t0, _idle_check             // skip if ammo = 0
        sw      r0, 0x0B20(v0)              // and set ammo to 0
        lw      a2, 0x014C(v0)              // a2 = kinetic state
        // if kinetic state = aerial
        lli     a1, SKnight.Action.NSPA
        beqz    a2, pc() + 12               // branch if kinetic state = grounded

        // if kinetic state = aerial
        lli     at, Kirby.Action.LANKY_NSP_Air - SKnight.Action.NSPA
        lw      a2, 0x0008(v0)              // a2 = current character ID
        lli     t6, Character.id.KIRBY      // t6 = id.KIRBY
        beql    t6, a2, pc() + 20           // if Kirby, adjust action ID
        addu    a1, a1, at
        lli     t6, Character.id.JKIRBY     // t6 = id.JKIRBY
        beql    t6, a2, pc() + 8            // if J Kirby, adjust action ID
        addu    a1, a1, at
        lw      a0, 0x0034(sp)              // a0 = player object
        lui     a2, 0x4160                  // a2(starting frame) = 14
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0034(sp)              // a0 = player object

        lw      a0, 0x0034(sp)              // a0 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      r0, 0x0180(v0)              // reset temp variable 2

        _idle_check:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     0x800DEE54                  // transition to idle
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

}




    // @ Description
    // Subroutine which sets up the initial properties for the projectile.
    // TODO: this is still largely uncommented, and may contain leftover logic that isn't needed.
    scope grape_stage_setting_: {
        constant MAX_POWER(4)
        addiu   sp, sp, -0x0050
        sw      s0, 0x0018(sp)
        li      s0, grape_properties_struct // s0 = projectile properties struct address
        sw      a1, 0x0034(sp)
        sw      ra, 0x001C(sp)
        lw      t6, 0x0084(a0)
        lw      t0, 0x0024(s0)
        lw      t1, 0x0028(s0)
        li      a1, grape_projectile_struct // a1 = main projectile struct address
        lw      a2, 0x0034(sp)
        lui     a3, 0x8000
        sw      t6, 0x002C(sp)              // 0x002C(sp) = player struct
        jal     0x801655C8                  // This is a generic routine that does much of the work for defining all projectiles
        sw      t1, 0x000C(a1)

        beq     v0, r0, _end_stage_setting  // if 801655C8 returns 0, there's no space to create a new projectile object, so skip to end
        nop

        _projectile_branch:
        sw      v0, 0x0028(sp)              // 0x0028(sp) = projectile object
        lw      v1, 0x0084(v0)              // v1 = projectile struct
        lw      t3, 0x0000(s0)              // t3 = duration
        sw      t3, 0x0268(v1)              // store duration
        lw      t4, 0x002C(sp)              // t4 = player struct
        lw      t5, 0x014C(t4)              // t5 = kinetic state
        beq     t5, r0, _continue           // branch if kinetic state = grounded
        lwc1    f12, 0x0018(s0)             // f12 = initial angle (ground)
        lwc1    f12, 0x001C(s0)             // f12 = initial angle (air)

        _continue:
        mtc1    r0, f4                      // f4 = 0
        swc1    f4, 0x0028(v1)              // set z speed? to 0
        swc1    f12, 0x0020(sp)             // 0x0020(sp) = adjusted angle
        jal     0x80035CD0                  // ~
        sw      v1, 0x0024(sp)              // original logic

        lwc1    f6, 0x0020(s0)              // f6 = initial projectile speed
        lw      t6, 0x002C(sp)              // ~
        lw      v1, 0x0024(sp)              // ~
        lw      t7, 0x0044(t6)              // ~
        mul.s   f8, f0, f6                  // ~
        lwc1    f12, 0x0020(sp)             // ~
        mtc1    t7, f10                     // ~
        nop                                 // ~
        cvt.s.w f16, f10                    // ~
        mul.s   f18, f8, f16                // ~
        jal     0x800303F0                  // ~
        swc1    f18, 0x0020(v1)             // original logic

        lwc1    f4, 0x0020(s0)              // f4 = initial projectile speed
        lw      v1, 0x0024(sp)              // ~
        lw      a0, 0x0028(sp)              // ~
        mul.s   f6, f0, f4                  // ~
        swc1    f6, 0x0024(v1)              // ~
        lw      t8, 0x0074(a0)              // ~
        lwc1    f10, 0x002C(s0)             // ~
        lw      t9, 0x0080(t8)              // ~
        jal     0x80167FA0                  // ~
        swc1    f10, 0x0088(t9)             // ~
        lw      v0, 0x0028(sp)              // original logic

        _end_stage_setting:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        addiu   sp, sp, 0x0050
        jr      ra
        nop
    }

    // @ Description
    // Main subroutine for the grape.
    scope grape_main_: {
        addiu   sp, sp, 0xFFE0              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0020(sp)              // 0x0020(sp) = projectile object
        lw      a0, 0x0084(a0)              // a0 = projectile struct
        jal     0x80167FE8                  // original logic, subroutine returns 1 if projectile duration is over
        sw      a0, 0x001C(sp)              // 0x001C(sp) = projectile struct
        beq     v0, r0, _continue           // branch if projectile duration has not ended
        lw      a0, 0x001C(sp)              // a0 = projectile struct

        _end_duration:
        lw      t7, 0x0020(sp)              // t7 = projectile object
        lw      a0, 0x0074(t7)              // ~
        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z coords
        jal     0x800FE7B4                  // create smoke gfx
        lui     a1, 0x3F80                  // a1 = 1.0
        b       _end                        // branch to end
        lli     v0, OS.TRUE                 // return TRUE (destroys projectile)

        _continue:
        li      v0, grape_properties_struct // v0 = grape_properties_struct
        lw      a1, 0x000C(v0)              // a1 = gravity
        jal     0x80168088                  // apply gravity to grape
        lw      a2, 0x0004(v0)              // a2 = max speed
        lw      a0, 0x001C(sp)              // a0 = projectile struct
        lw      t1, 0x0020(sp)              // t1 = projectile object
        lw      v1, 0x0074(t1)              // v1 = projectile struct with coordinates/rotation etc (bone struct?)
        li      at, grape_properties_struct // at = grape properties struct
        lwc1    f6, 0x0014(at)              // f6 = rotation speed
        lwc1    f4, 0x0030(v1)              // f4 = current rotation
        add.s   f8, f4, f6                  // add rotation speed to current rotation
        swc1    f8, 0x0030(v1)              // update rotation
        lli     v0, OS.FALSE                // return FALSE (don't destroy)

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for the grape.
    // Based on 0x801688C4, which is the equivalent for Charge Shot.
    scope grape_collision_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x00014(sp)             // store ra

        jal     0x80167C04                  // general collision detection?
        sw      a0, 0x0018(sp)              // 0x0018(sp) = projectile object
        beqz    v0, _end                    // end if collision wasn't detected
        lw      a0, 0x0018(sp)              // a2 = projectile object
        // if collision was detected
        jal     grape_destruction_
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // This subroutine spawns a hit effect and destroys the GRAPE
    scope grape_hit_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // 0x0018(sp) = projectile object
        lw      v1, 0x0084(a0)              // v1 = projectile struct
        lw      a0, 0x0074(a0)              // ~
        addiu   a0, a0, 0x001C              // a0 = x/y/z coordinates
        or      a1, r0, r0                  // a1 = 0
        lw      a2, 0x0234(v1)              // a2 = damage
        jal     0x800FE7B4                  // create "normal hit" gfx
        or      a3, r0, r0                  // a3 = 0
        jal     grape_destruction_          // destroy the grape
        lw      a0, 0x0018(sp)              // a0 = projectile obect
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // This subroutine destroys the grape and creates a smoke gfx.
    scope grape_destruction_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      a0, 0x0074(a0)              // ~
        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z coords
        jal     0x800FE7B4                  // create smoke gfx
        lui     a1, 0x3F80                  // a1 = 1.0
        jal     0x800269C0                  // play FGM
        lli     a0, 1580                    // FGM id = 1521
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        lli     v0, OS.TRUE                 // return TRUE (destroys projectile)
    }

    OS.align(16)
    grape_projectile_struct:
    constant NUT_ID(0x1001)
    dw 0x00000000                           // unknown
    dw NUT_ID                               // projectile id
    dw Character.SKNIGHT_file_6_ptr           // address of conker's file 6 pointer
    dw 0x00000000                           // offset to hitbox
    dw 0x12470000                           // This determines z axis rotation? (samus is 1246)
    dw grape_main_                          // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw grape_collision_                     // This is the collision subroutine for the projectile, responsible for detecting collision with clipping.
    dw grape_hit_                           // This function runs when the projectile collides with a hurtbox.
    dw grape_destruction_                   // This function runs when the projectile collides with a shield.
    dw 0x801686F8                           // This function runs when the projectile collides with edges of a shield and bounces off
    dw grape_destruction_                   // This function runs when the projectile collides/clangs with a hitbox.
    dw 0x801692C4                           // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw grape_destruction_                   // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    OS.align(16)
    grape_properties_struct:
    dw 70                                   // 0x0000 - duration (int)
    float32 50                              // 0x0004 - max speed
    float32 0                               // 0x0008 - min speed
    float32 0                               // 0x000C - gravity
    float32 0                               // 0x0010 - bounce multiplier
    float32 0.4                             // 0x0014 - rotation speed
    float32 0                               // 0x0018 - initial angle (ground)
    float32 0                               // 0x001C   initial angle (air)
    float32 40                              // 0x0020   initial speed
    dw Character.SKNIGHT_file_6_ptr           // 0x0024   projectile data pointer
    dw 0x00000000                           // 0x0028   unknown (default 0)
    float32 1                               // 0x002C   palette index (0 = mario, 1 = luigi)
}














// Subroutines for Down Special
scope SKnightDSP {
    constant X_SPEED(0x42B0)                // current setting - float:64.0
    constant Y_SPEED(0x41F0)                // current setting - float:30.0
    constant JUMP_SPEED(0x4288)             // current setting - float:68.0
    constant RECOIL_X_SPEED(0xC220)         // current setting - float:-40.0
    constant RECOIL_Y_SPEED(0x4220)         // current setting - float:40.0
    constant GRAVITY(0x4030)                // current setting - float:2.75
    constant MAX_FALL_SPEED(0x4240)         // current setting - float:48.0
    constant AIR_FRICTION(0x4000)           // current setting - float:2.0
    constant GROUND_TRACTION(0x3F00)        // current setting - float:0.5

    constant BEGIN(0x1)
    constant MOVE(0x2)

    constant WALL_COLLISION_L(0x0001)       // bitmask for wall collision
    constant WALL_COLLISION_R(0x0020)       // bitmask for wall collision

    // @ Description
    // Subroutine which runs when Wario initiates a grounded down special.
    // Changes action, and sets up initial variable values.
    scope ground_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      r0, 0x0010(sp)              // original begin logic
        ori     a1, r0, 0x00E3              // a1 = action id: Wario DSP Ground
        ori     a2, r0, 0x0000              // a2 = 0 (begin action frame)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a2 = float: 1.0
        jal     0x800E0830                  // unknown original subroutine
        lw      a0, 0x0020(sp)              // unknown original subroutine
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     ra, r0, 0x0001              // ~
        sw      ra, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which runs when Wario initiates an aerial neutral special.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        addiu   t6, r0, 0x0008              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      t6, 0x0010(sp)              // original begin logic
        ori     a1, r0, 0x00E4              // a1 = action id: Wario DSP Ground
        ori     a2, r0, 0x0000              // a2 = 0 (begin action frame)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a2 = float: 1.0
        jal     0x800E0830                  // unknown original subroutine
        lw      a0, 0x0020(sp)              // unknown original subroutine
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     v1, r0, 0x0001              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        // reset fall speed
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }


    scope ground_main_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      r0, 0x0010(sp)              // original begin logic

        lhu     at, 0x01B8(a1)              // at = shield press bitmask
        and     at, at, v0                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _end         // branch if shield is not pressed
        // if we're here, Shield has been pressed, so transition to USPEscape
        jal     0x801438F0   // a1(action id) = USPJump
        b       _end                        // end
        nop


        _end:
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop


    }

    // @ Description
    // Subroutine which sets up the movement for the grounded version of Body Slam.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x2 = apply movement speed
    scope ground_move_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // store t0, t1

        _check_begin:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_move         // skip if t0 != BEGIN
        nop
        // slow x movement
        lwc1    f0, 0x0060(a2)              // f0 = current ground x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0060(a2)              // x velocity = (x velocity * 0.875)

        _check_move:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _end                // skip if t0 != MOVE
        nop
        // apply x velocity
        lui     t1, X_SPEED                 // t1 = X_SPEED
        sw		t1, 0x0060(a2)	            // ground x velocity = X_SPEED





        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles physics for Wario's grounded neutral special.
    // Copy of subroutine 0x800D8BB4, loads a hard-coded traction value instead of the character's
    // traction value.
    scope ground_physics_: {
        // Copy the first 10 lines of subroutine 0x800D8BB4
        OS.copy_segment(0x543B4, 0x28)
        // Replace original lines which load the base friction from the friction table
        constant UPPER(Surface.friction_table >> 16)
        constant LOWER(Surface.friction_table & 0xFFFF)
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)
        } else {
            lui     at, UPPER
        }
        addu    at, at, t9
        lwc1    f4, LOWER(at)
        // Replace original line which loads the character's grounded tracion value
        // lwc1 f6, 0x0024(v0)              // replaced line
        lui     a1, GROUND_TRACTION         // ~
        mtc1    a1, f6                      // f6 = GROUND_TRACTION
        // Copy the last 10 lines of subroutine 0x800D8BB4
        OS.copy_segment(0x543EC, 0x28)
    }

    // @ Description
    // Subroutine which handles collision for Wario's grounded neutral special.
    scope ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // store ra, a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lbu     a1, 0x000D(a0)              // a1 = player port
        li      a2, special_jim_flag        // ~
        addu    t0, a2, a1                  // t0 = px special_jim_flag address
        lw      a1, 0x0184(a0)              // a1 = temp variable 3
        ori     a2, r0, MOVE                // a2 = MOVE
        bnel    a1, a2, _recoil_check       // skip if a1 != MOVE
        sb      r0, 0x0000(t0)              // reset px special_jim_flag on branch

        lhu     a1, 0x00CC(a0)              // a1 = collision flags
        lw      t1, 0x0044(a0)              // t0 = direction
        bgezl   t1, _wall_collision         // branch if direction = right
        andi    a1, a1, WALL_COLLISION_L    // a1 = collision flags & WALL_COLLISION_L
        andi    a1, a1, WALL_COLLISION_R    // a1 = collision flags & WALL_COLLISION_R

        _wall_collision:
        beql    a1, r0, _recoil_check       // skip if !WALL_COLLISION
        sb      r0, 0x0000(t0)              // reset px special_jim_flag on branch
        lbu     a1, 0x0000(t0)              // a2 = px special_jim_flag
        bne     a1, r0, _recoil_check       // skip if Jim's special collision flag is enabled
        nop
        // enable the flag to begin recoil
        ori     a1, r0, 0x0001              // ~
        sw      a1, 0x017C(a0)              // temp variable 1 = 0x1 (recoil flag = true)

        _recoil_check:
        li      a1, _end                    // a1 = _end
        jal     check_recoil_               // check for recoil transition
        lw      a0, 0x0010(sp)              // load a0
        li      a1, ground_to_air_          // a1 = ground_to_air_
        jal     0x800DDDDC                  // ground collision (with slide-off)
        lw      a0, 0x0010(sp)              // load a0
        lw      a0, 0x0010(sp)              // load a0
        lw      a0, 0x0084(a0)              // a0 = player struct

        lw      a1, 0x0008(a0)              // a1 = current character id
        lli     a2, Character.id.KIRBY      // a2 = id.KIRBY
        beq     a1, a2, _kirby              // branch if character id = KIRBY
        lli     a2, Character.id.JKIRBY     // a2 = id.JKIRBY
        bne     a1, a2, _sknight              // branch if character id != JKIRBY
        nop

        _kirby:
        lw      a1, 0x0024(a0)              // a1 = current action
        lli     a2, Kirby.Action.WARIO_NSP_Ground
        bne     a1, a2, _end                // skip if action id != ground nsp
        nop
        b       _jump                       // check for jump
        nop

        _sknight:
        lw      a1, 0x0024(a0)              // a1 = current action
        ori     a2, r0, 0x00E3              // a2 = action id: ground nsp
        bne     a1, a2, _end                // skip if action id != ground nsp
        nop

        _jump:
        lw      a1, 0x0184(a0)              // a1 = temp variable 3
        ori     a2, r0, MOVE                // a2 = MOVE
        bne     a1, a2, _end                // skip if a1 != MOVE
        nop
        jal     0x8013F474                  // check jump (returns 0 for no jump)
        nop
        beq     v0, r0, _end                // skip if !jump
        nop
        lw      a0, 0x0010(sp)              // load a0
        jal     ground_to_air_              // transition from ground to air
        nop
        lw      a0, 0x0010(sp)              // load a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     a1, JUMP_SPEED              // a1 = JUMP_SPEED
        sw      a1, 0x004C(a0)              // y velocity = JUMP_SPEED
        lw      a0, 0x0078(a0)              // a0 = player x/y/z pointer
        ori     a1, r0, 0x0001              // a1 = 0x1
        lui     a2, 0x3F80                  // a2 = float: 1.0
        jal     0x800FF3F4                  // jump smoke graphic
        nop
        ori     a0, r0, 0x005E              // a0 = FGM ID

        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles ground to air transition Wario's grounded neutral special.
    scope ground_to_air_: {
        OS.copy_segment(0xDE2EC, 0x18)      // copy beginning of subroutine from Link NSP
        ori     t7, r0, 0x0003              // t7 = 0x0003 (hitbox persist)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Air
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Air

        ori     a1, r0, 0x00E4              // a1 = 0xE0

        OS.copy_segment(0xDE30C, 0x20)      // copy end of subroutine from Link NSP
    }

    // @ Description
    // Subroutine which sets up the movement for the aerial version of Body Slam.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x1 = begin
    // 0x2 = apply movement speed
    // Also uses command 58000001 for to set y velocity when movement begins.
    scope air_move_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      t0, 0x000C(sp)              // ~
        sw      t1, 0x0010(sp)              // ~
        swc1    f0, 0x0014(sp)              // ~
        swc1    f2, 0x0018(sp)              // store a0, ra, t0, t1, f0, f2

        _check_begin:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_move         // skip if t0 != BEGIN
        nop
        // slow x movement
        lwc1    f0, 0x0048(a2)              // f0 = current x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0048(a2)              // x velocity = (x velocity * 0.875)
        // freeze y position
        lw      t1, 0x09C8(a2)              // t1 = attribute pointer
        lui     t1, GRAVITY                 // t1 = gravity
        sw      t1, 0x004C(a2)              // y velocity = gravity

        _check_move:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _check_y            // skip if t0 != MOVE
        nop
        // apply x velocity
        lui     t1, X_SPEED                 // ~
        mtc1    t1, f0                      // f0 = X_SPEED
        lwc1    f2, 0x0044(a2)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        mul.s   f0, f0, f2                  // f0 = X_SPEED * DIRECTION
        swc1    f0, 0x0048(a2)              // x velocity = X_SPEED * DIRECTION

        _check_y:
        lw      t0, 0x0180(a2)              // temp variable 2
        beq     t0, r0, _end                // skip if temp variable 2 = 0
        nop
        _apply_y:
        sw      r0, 0x0180(a2)              // temp variable 2 = 0
        // falcon punch subroutine which takes stick_y and returns an angle in radians to f0
        jal     0x8015F874                  // return f0 = angle
        lb      a0, 0x01C3(a2)              // a0 = stick_y
        // ultra64 sinf function
        jal     0x800303F0                  // return f0 = sin(angle)
        mov.s   f12, f0                     // f12 = angle
        // sine used to calculate final Y_SPEED
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f2                      // f2 = X_SPEED
        mul.s   f0, f0, f2                  // f2 = sin(angle) * X_SPEED
        // multiply by 0.75 to reduce the range of angles
        lui     t0, 0x3F40                  // ~
        mtc1    t0, f2                      // f2 = 0.75
        mul.s   f0, f0, f2                  // f2 = f2 * 0.75
        // add base speed
        lui     t0, Y_SPEED                 // ~
        mtc1    t0, f2                      // f2 = Y_SPEED
        add.s   f0, f0, f2                  // f0 = f2 + Y_SPEED
        swc1    f0, 0x004C(a2)              // store final y velocity

        _end:
        lw      ra, 0x0004(sp)              // ~
        lw      a0, 0x0008(sp)              // ~
        lw      t0, 0x000C(sp)              // ~
        lw      t1, 0x0010(sp)              // ~
        lwc1    f0, 0x0014(sp)              // ~
        lwc1    f2, 0x0018(sp)              // load a0, ra, t0, t1, f0, f2
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles physics for Wario's aerial neutral special.
    // Modified version of subroutine 0x800D91EC.
    scope air_physics_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      s1, 0x0018(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        lw      s0, 0x0084(a0)              // ~
        lw      s1, 0x09C8(s0)              // ~
        or      a0, s0, r0                  // original lines
        or      a3, s1, r0                  // a3
        lui     a1, GRAVITY                 // a1 = GRAVITY
        jal     0x800D8D68                  // apply gravity/fall speed
        lui     a2, MAX_FALL_SPEED          // a2 = MAX_FALL_SPEED

        // Subroutine 0x800D9074 applies air friction. Usually, air friction is loaded from
        // 0x0054(a1), with a1 being the attribute pointer for the character. In this case, a
        // different air friction value is stored at 0x0054(sp) and then the stack pointer is
        // passed to a1 for subroutine 0x800D9074.
        or      a0, s0, r0                  // a0 = player struct
        addiu   sp, sp,-0x0058              // allocate stack space
        lui     a1, AIR_FRICTION            // a1 = AIR_FRICTION
        sw      a1, 0x0054(sp)              // store AIR_FRICTION
        jal     0x800D9074                  // apply air friction
        or      a1, sp, r0                  // a1 = stack pointer
        addiu   sp, sp, 0x0058              // deallocate stack space
        lw      ra, 0x001C(sp)              // ~
        lw      s1, 0x0018(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        jr      ra                          // ~
        addiu   sp, sp, 0x0020              // original return logic
    }

    // @ Description
    // Subroutine which handles collision for Wario's aerial neutral special.
    scope air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // store ra, a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lbu     a1, 0x000D(a0)              // a1 = player port
        li      a2, special_jim_flag        // ~
        addu    t0, a2, a1                  // t0 = px special_jim_flag address
        lw      a1, 0x0184(a0)              // a1 = temp variable 3
        ori     a2, r0, MOVE                // a2 = MOVE
        bnel    a1, a2, _recoil_check       // skip if a1 != MOVE
        sb      r0, 0x0000(t0)              // reset px special_jim_flag on branch

        lhu     a1, 0x00CC(a0)              // a1 = collision flags
        lw      t1, 0x0044(a0)              // t0 = direction
        bgezl   t1, _wall_collision         // branch if direction = right
        andi    a1, a1, WALL_COLLISION_L    // a1 = collision flags & WALL_COLLISION_L
        andi    a1, a1, WALL_COLLISION_R    // a1 = collision flags & WALL_COLLISION_R

        _wall_collision:
        beql    a1, r0, _recoil_check       // skip if !WALL_COLLISION
        sb      r0, 0x0000(t0)              // reset px special_jim_flag on branch
        ori     a1, r0, OS.TRUE             // ~
        sb      a1, 0x0000(t0)              // px special_jim_flag = TRUE

        _recoil_check:
        li      a1, _end                    // a1 = _end
        jal     check_recoil_               // check for recoil transition
        lw      a0, 0x0010(sp)              // load a0
        li      a1, air_to_ground_          // a1 = air_to_ground_
        jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
        lw      a0, 0x0010(sp)              // load a0

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which handles air to ground transition Wario's grounded neutral special.
    scope air_to_ground_: {
        OS.copy_segment(0xD098C, 0x1C)      // copy beginning of subroutine from Mario NSP
        ori     t7, r0, 0x0003              // t7 = 0x0003 (hitbox persist)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Ground

        ori     a1, r0, 0x00E3              // a1 = 0xDF

        lw      a2, 0x0078(a0)              // a2 = current animation frame
        sw      t7, 0x0010(sp)              // store t7 (some kind of parameter for change action)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0028              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which sets up the movement for the Body Slam recoil.
    // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // Variable values used by this subroutine:
    // 0x1 = end special movement
    scope recoil_move_: {
        // a2 = player struct
        // 0x180 in player struct = temp variable 2

        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        swc1    f0, 0x000C(sp)              // ~
        swc1    f2, 0x0010(sp)              // store t0, f0, f2

        _check_movement:
        lw      t0, 0x0180(a2)              // t0 = temp variable 2
        bnez    t0, _end                    // skip if t0 > 0
        nop
        // slow x movement
        lwc1    f0, 0x0048(a2)              // f0 = current x velocity
        lui     t0, 0x3F78                  // ~
        mtc1    t0, f2                      // f2 = 0.96875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.96875
        swc1    f0, 0x0048(a2)              // x velocity = (x velocity * 0.96875)
        // slow falling speed
        lw      t0, 0x0008(a2)              // t0 = character id
        lli     t1, Character.id.SKNIGHT      // t1 = id.WARIO
        beq     t1, t0, _modify_y_velocity  // branch if character id = WARIO
        lui     t0, 0x3FA0                  // t0 = 1.25

        // if we're here, the character is Kirby or J Kirby
        // (unless another character is eventually allowed to use Wario's neutral special)
        li      t0, 0x3F0CCCCD              // t0 = 0.55

        _modify_y_velocity:
        mtc1    t0, f0                      // f0 = 1.25/0.55
        lwc1    f2, 0x004C(a2)              // f2 = y velocity
        add.s   f0, f2, f0                  // f0 = y velocity + 1.25/0.55
        swc1    f0, 0x004C(a2)              // store updated y velocity
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lwc1    f0, 0x000C(sp)              // ~
        lwc1    f2, 0x0010(sp)              // load t0, t1, f0, f2
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles physics for the recoil.
    // Prevents player control when temp variable 2 = 0
    scope recoil_physics_: {
        // 0x180 in player struct = temp variable 2
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw    	ra, 0x000C(sp)              // store t0, t1, ra
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0180(t0)              // t1 = temp variable 2
        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control
        bnez    t1, _subroutine             // skip if t1 != 0
        nop
        li      t8, 0x800D91EC              // t8 = physics subroutine which prevents player control

        _subroutine:
        jalr      t8                        // run physics subroutine
        nop
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu 	sp, sp, 0x0010				// deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles hitbox collision for Wario's neutral special.
    // @ Arguments
    // a0 - entity struct?
    // a1 - return address upon collision
    scope check_recoil_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      a0, 0x000C(sp)              // ~
        sw      a1, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        swc1    f0, 0x0018(sp)              // ~
        swc1    f2, 0x001C(sp)              // store t0, t1, a0, a1, ra, f0, f2

        _check:
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x017C(t0)              // t1 = temp variable 1
        beq     t1, r0, _end                // skip if temp variable 1 = 0
        nop

        _collision:
        sw      a1, 0x0014(sp)              // overwrite return address in stack
        jal     begin_recoil_               // transition to recoil action
        nop
        lw      a0, 0x000C(sp)              // load a0
        lw      t0, 0x0084(a0)              // t0 = player struct
        sw      r0, 0x0180(t0)              // temp variable 2 = 0
        // initial x velocity
        lui     t1, RECOIL_X_SPEED          // ~
        mtc1    t1, f0                      // f0 = RECOIL_X_SPEED
        lwc1    f2, 0x0044(t0)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        mul.s   f0, f0, f2                  // f0 = RECOIL_X_SPEED * DIRECTION
        swc1    f0, 0x0048(t0)              // x velocity = RECOIL_X_SPEED * DIRECTION
        // initial y velocity
        lui     t1, RECOIL_Y_SPEED          // t1 = RECOIL_Y_SPEED
        sw      t1, 0x004C(t0)              // y velocity = RECOIL_Y_SPEED

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      a0, 0x000C(sp)              // ~
        lw      ra, 0x0014(sp)              // ~
        lwc1    f0, 0x0018(sp)              // ~
        lwc1    f2, 0x001C(sp)              // load t0, t1, ra, f0, f2
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions into Wario's neutral special recoil action.
    scope begin_recoil_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        ori     a0, r0, 0x0117              // a0 = FGM ID

        nop
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        bnez    t7, _end                    // skip if kinetic state !grounded
        nop
        jal     0x800DEEC8                  // set aerial state
        nop

        _end:
        lw      a0, 0x0020(sp)              // a0 = entity struct?
        ori     t7, r0, 0x0003              // t7 = 0x0003 (hitbox persist)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Air
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Air

        ori     a1, r0, SKnight.Action.DSP_Recoil_Air
        or      a2, r0, r0                  // a2 = 0(begin action frame)
        sw      t7, 0x0010(sp)              // store t7 (some kind of parameter for change action)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Recoil_Ground.
    scope recoil_ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, recoil_air_transition_  // a1(transition subroutine) = air_begin_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Recoil_Air.
    scope recoil_air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, recoil_ground_transition_ // a1(transition subroutine) = recoil_ground_transition_
        jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Recoil_Ground.
    scope recoil_ground_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Ground
        lli     a1, SKnight.Action.DSP_Recoil_Ground // a1(action id) = NSP_Recoil_Ground
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Recoil_Air.
    scope recoil_air_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Air
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Air
        lli     a1, SKnight.Action.DSP_Recoil_Air // a1(action id) = NSP_Recoil_Air
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // This is Jim's special collision flag.
    // Its primary purpose is to disable grounded wall collision recoil when Wario transitions from
    // air to ground while already colliding with a wall.
    // Its secondary purpose is to make Jim shut up.
    special_jim_flag:
    db 0x00 //p1
    db 0x00 //p2
    db 0x00 //p3
    db 0x00 //p4
}



// @ Description
// Subroutines for Up Special
scope SKnightUSP {
    constant Y_SPEED(0x42C0)                // current setting - float:120
    constant X_SPEED(0x4288)                // current setting - float:50
    constant LANDING_FSM(0x3E20)            // current setting - float:0.15625

    // @ Description
    // Subroutine which runs when Piano initiates an up special (both ground/air).
    // Changes action, and sets up initial variable values.
    scope initial_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        bnez    t7, _change_action          // skip if kinetic state !grounded
        nop
        jal     0x800DEEC8                  // set aerial state
        nop
        _change_action:
        lw      a0, 0x0020(sp)              // a0 = player object
        sw      r0, 0x0010(sp)              // store r0 (some kind of parameter for change action)
        ori     a1, r0, 0x00E1              // a1 = 0xE1
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     v1, r0, 0x0001              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        // reset fall speed
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        // take mid-air jumps away
        lw      t6, 0x09C8(a0)              // t6 = attribute pointer
        lw      t6, 0x0064(t6)              // t6 = max jumps
        sb      t6, 0x0148(a0)              // jumps used = max jumps
        // freeze y position
        lw      v1, 0x09C8(a0)              // v1 = attribute pointer
        lw      v1, 0x0058(v1)              // v1 = gravity
        sw      v1, 0x004C(a0)              // y velocity = gravity
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Main subroutine for Piano's up special.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    // Modified to load Piano's landing FSM value and disable the interrupt flag.
    scope main_: {
        // Copy the first 8 lines of subroutine 0x8015C750
        OS.copy_segment(0xD7190, 0x20)
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0024(sp)              // restore ra
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        lw      ra, 0x0024(sp)              // restore ra

        _end:
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which allows a direction change for Piano's up special.
    // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // Variable values used by this subroutine:
    // 0x2 = change direction
    scope change_direction_: {
        // 0x180 in player struct = temp variable 2
        lw      a1, 0x0084(a0)              // a1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // store t0, t1, ra
        lw      t0, 0x0180(a1)              // t0 = temp variable 2
        ori     t1, r0, 0x0002              // t1 = 0x2
        bne     t1, t0, _end                // skip if temp variable 2 != 2
        nop
        jal     0x80160370                  // turn subroutine (copied from captain falcon)
        nop






        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles movement for Piano's up special.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x1 = begin
    // 0x2 = begin movement
    // 0x3 = movement
    scope physics_: {
        // s0 = player struct
        // s1 = attributes pointer
        // 0x184 in player struct = temp variable 3
        constant BEGIN(0x1)
        constant BEGIN_MOVE(0x2)
        constant MOVE(0x3)
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // original store registers
        sw      t0, 0x0024(sp)              // ~
        sw      t1, 0x0028(sp)              // ~
        swc1    f0, 0x002C(sp)              // ~
        swc1    f2, 0x0030(sp)              // ~
        swc1    f4, 0x0034(sp)              // store t0, t1, f0, f2, f4

        OS.copy_segment(0x548F0, 0x40)      // copy from original air physics subroutine
        bnez    v0, _check_begin            // modified original branch
        nop
        li      t8, 0x800D8FA8              // t8 = subroutine which disallows air control
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        beq     t0, t1, _continue           // branch if temp variable 3 = BEGIN
        nop
        li      t8, air_control_            // t8 = air_control_

        _continue:
        or      a0, s0, r0                  // a0 = player struct
        jalr    t8                          // air control subroutine
        or      a1, s1, r0                  // a1 = attributes pointer
        or      a0, s0, r0                  // a0 = player struct
        jal     0x800D9074                  // air friction subroutine?
        or      a1, s1, r0                  // a1 = attributes pointer

        _check_begin:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_begin_move   // skip if temp variable 3 != BEGIN
        nop
        // slow x movement
        lwc1    f0, 0x0048(s0)              // f0 = current x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0048(s0)              // x velocity = (x velocity * 0.875)
        // freeze y position
        sw      r0, 0x004C(s0)              // y velocity = 0

        _check_begin_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN_MOVE          // t1 = BEGIN_MOVE
        bne     t0, t1, _end                // skip if temp variable 3 != BEGIN_MOVE
        nop
        // initialize x/y velocity
        lui     t0, Y_SPEED                 // ~
        mtc1    t0, f4                      // f4 = Y_SPEED
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        lb      t0, 0x01C2(s0)              // ~
        mtc1    t0, f2                      // ~
        cvt.s.w f2, f2                      // f2 = stick_x
        mul.s   f0, f2, f0                  // f0 = stick_x * direction
        mtc1    r0, f2                      // f2 = 0
        c.le.s  f2, f0                      // ~
        nop                                 // ~
        bc1f    _apply_movement             // branch if stick_x * direction =< 0
        nop

        // update x velocity based on stick_x
        // f0 = stick_x (relative to direction)
        lui     t0, 0x3F00                  // ~
        mtc1    t0, f2                      // f2 = 0.5
        mul.s   f2, f0, f2                  // f2 = x velocity (stick_x * 0.5)
        // update y velocity based on x velocity (higher x = lower y)
        lui     t0, 0x3F40                  // ~
        mtc1    t0, f0                      // f0 = 0.75
        mul.s   f0, f0, f2                  // ~
        sub.s   f4, f4, f0                  // f4 = Y_SPEED - (x velocity * 0.75)

        _apply_movement:
        // f2 = x velocity to add
        // f4 = y velocity
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f0                      // f0 = X_SPEED
        add.s   f2, f2, f0                  // f0 = final velocity
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f2, f0, f2                  // f2 = x velocity * direction
        swc1    f2, 0x0048(s0)              // store x velocity
        swc1    f4, 0x004C(s0)              // store y velocity
        ori     t0, r0, MOVE                // t0 = MOVE
        sw      t0, 0x0184(s0)              // temp variable 3 = MOVE
        b       _end                        // end
        nop

        _end:
        lw      t0, 0x0024(sp)              // ~
        lw      t1, 0x0028(sp)              // ~
        lwc1    f0, 0x002C(sp)              // ~
        lwc1    f2, 0x0030(sp)              // ~
        lwc1    f4, 0x0034(sp)              // load t0, t1, f0, f2, f4
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        lw      s1, 0x0018(sp)              // original load registers
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles Piano's horizontal control for up special.
    scope air_control_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      a1, 0x001C(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        sw      t0, 0x0020(sp)              // ~
        sw      t1, 0x0024(sp)              // store a1, ra, t0, t1
        addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
        lw      t6, 0x001C(sp)              // t6 = attribute pointer
        lw      a2, 0x004C(t6)              // a2 = air acceleration
        lw      a3, 0x0050(t6)              // a3 = max air speed
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        _check_move:
        ori     t1, r0, physics_.MOVE       // t1 = MOVE
        beql    t0, t1, _continue           // branch if temp variable 3 = MOVE
        lui     a2, 0x3C75                  // on branch, a2 = 0.0149536

        _continue:
        jal     0x800D8FC8                  // air drift subroutine?
        nop
        lw      ra, 0x0014(sp)              // ~
        lw      t0, 0x0020(sp)              // ~
        lw      t1, 0x0024(sp)              // load ra, t0, t1
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles collision for Piano's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Piano.
    scope collision_: {
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }


}






// Subroutines for Down Special
scope SKnightDSP2 {
    constant GROUND_SPEED(0x42A0)           // float32 80

    constant ESCAPE_SPEED(0x4160)           // float32 14
    constant MIN_SPEED(0x4040)              // float32 3
    constant ACCELERATION(0x4000)           // float32 2
    constant LANDING_FSM(0x3E80)            // float32 0.25
    constant MAX_TIME(80)

    constant X_SPEED(0x0)                // current setting - float:64.0
    constant Y_SPEED(0x41F0)                // current setting - float:30.0
    constant JUMP_SPEED(0x4288)             // current setting - float:68.0
    constant RECOIL_X_SPEED(0xC220)         // current setting - float:-40.0
    constant RECOIL_Y_SPEED(0x4220)         // current setting - float:40.0
    constant GRAVITY(0x4030)                // current setting - float:2.75
    constant MAX_FALL_SPEED(0x4240)         // current setting - float:48.0
    constant AIR_FRICTION(0x4000)           // current setting - float:2.0
    constant GROUND_TRACTION(0x3F00)        // current setting - float:0.5
    constant BEGIN_LANDING_FSM(0x4000)      // current setting - float:1.5
    constant B_PRESSED(0x40)                // bitmask for b press
    constant A_PRESSED(0x80)                // bitmask for b press
    constant Z_PRESSED(0x20)                // bitmask for b press

    constant BEGIN(0x1)
    constant MOVE(0x2)

    constant WALL_COLLISION_L(0x0001)       // bitmask for wall collision
    constant WALL_COLLISION_R(0x0020)       // bitmask for wall collision

    // @ Description
    // Subroutine which runs when Wario initiates a grounded down special.
    // Changes action, and sets up initial variable values.
    scope ground_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      r0, 0x0010(sp)              // original begin logic
        ori     a1, r0, 0x00E3              // a1 = action id: Wario DSP Ground
        ori     a2, r0, 0x0000              // a2 = 0 (begin action frame)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a2 = float: 1.0
        jal     0x800E0830                  // unknown original subroutine
        lw      a0, 0x0020(sp)              // unknown original subroutine
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     ra, r0, 0x0001              // ~
        sw      ra, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        sw      r0, 0x0B18(a0)              // reset button_press_buffer
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which runs when Wario initiates an aerial neutral special.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        addiu   t6, r0, 0x0008              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      t6, 0x0010(sp)              // original begin logic
        ori     a1, r0, 0x00EB              // a1 = action id: Wario DSP Ground
        ori     a2, r0, 0x0000              // a2 = 0 (begin action frame)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a2 = float: 1.0
        jal     0x800E0830                  // unknown original subroutine
        lw      a0, 0x0020(sp)              // unknown original subroutine
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     v1, r0, 0x0001              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        sw      r0, 0x0B18(a0)              // reset button_press_buffer
        // reset fall speed
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

















    // @ Description
    // Initial subroutine for USP while grounded.
    scope ground_initial2_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     at, GROUND_SPEED            // at = GROUND_SPEED
        jal     0x800DEEC8                  // set aerial state
        sw      at, 0x004C(a0)              // y velocity = GROUND_SPEED
        jal     air_initial_                // transition to USP
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for USP.
    scope air_initial2_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, SKnight.Action.USPG       // a1(action id) = USP
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object

        jal     attach_cloud_               // attach_cloud_
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // a0 = player object
        jal     goemon_on_hit_subroutine_establishment_ // on hit subroutine setup
        lw      a0, 0x0084(a0)              // a0 = player struct

        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     t6, 0x3EC0                  // ~
        mtc1    t6, f0                      // f0 = 0.375
        lwc1    f2, 0x004C(a0)              // f2 = y velocity
        mul.s   f2, f2, f0                  // f2 = y velocity * 0.375
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        lli     at, 0x0001                  // ~
        sw      at, 0x0180(a0)              // temp variable 2 = 1
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        sw      r0, 0x0B18(a0)              // frame timer = 0
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        lw      t6, 0x09C8(a0)              // t6 = attribute pointer
        lw      t6, 0x0064(t6)              // t0 = max jumps
        sb      t6, 0x0148(a0)              // jumps used = max jumps
        swc1    f2, 0x004C(a0)              // store updated y velocity
        FGM.play(0x62F)                     // play cloud spawn sfx

        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Shared initial subroutine for USP actions.
    // @ Arguments
    // a0 - player object
    // a1 - action id
    scope shared_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lli     at, 0x0001                  // ~
        sw      at, 0x0180(a0)              // temp variable 2 = 1
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Checks for turnaround inputs.
    // @ Arguments
    // a0 - player object
    scope check_turn_: {
        // begin by checking for turn inputs
        lw      a1, 0x0084(a0)              // a1 = player struct
        lb      t6, 0x01C2(a1)              // t6 = stick_x
        lw      t7, 0x0044(a1)              // t7 = DIRECTION
        multu   t6, t7                      // ~
        mflo    t6                          // t6 = stick_x * DIRECTION
        slti    at, t6, -39                 // at = 1 if stick_x < -39, else at = 0
        beqz    at, _end                    // branch if stick_x >= -39
        nop

        // if we're here, stick_x is opposite the facing direction, so turn the character around
        subu    t7, r0, t7                  // ~
        sw      t7, 0x0044(a1)              // reverse and update DIRECTION

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main function for USP
    scope main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      t6, 0x0B18(v1)              // t6 = frame timer
        slti    at, t6, MAX_TIME            // at = 1 if frame timer < MAX_TIME, else at = 0
        addiu   t6, t6, 0x0001              // ~
        bnez    at, _end                    // branch if frame timer < MAX_TIME
        sw      t6, 0x0B18(v1)              // increment frame timer


        // if frame timer has reached MAX_TIME
        jal     check_turn_                 // check for turnaround inputs
        nop
        jal     shared_initial_             // transition to USP action
        lli     a1, SKnight.Action.USPJump   // a1(action id) = USPJump
        b       _end                        // end
        nop

        // _check_turn:
        // lwc1    f2, 0x0048(v1)              // ~
        // abs.s   f2, f2                      // ~
        // cvt.w.s f2, f2                      // ~
        // lui     at, 0x8000                  // at = sign bitmask
        // lw      t6, 0x0044(v1)              // t6 = DIRECTION
        // lw      t7, 0x0048(v1)              // t7 = x velocity
        // and     t6, t6, at                  // t6 = DIRECTION sign
        // and     t7, t7, at                  // t7 = x velocity sign
        // mfc1    at, f2                      // at = int(|x velocity|)
        // sltiu   at, 4                       // at = 1 if int(|x velocity|) < 4, else at = 0
        // bnezl   at, _end                    // end if x velocity < 4...
        // lw      ra, 0x0024(sp)              // ...and load ra
        // beql    t6, t7, _end                // end if DIRECTION and x velocity signs match...
        // lw      ra, 0x0024(sp)              // ...and load ra
        //
        // // if the signs of DIRECTION and x velocity don't match, begin a turn
        // jal     shared_initial_             // transition to USP action
        // lli     a1, SKnight.Action.USPTurn   // a1(action id) = USPTurn
        // lw      ra, 0x0024(sp)              // load ra

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // scrapped turn action
    // // @ Description
    // // Main function for USPTurn.
    // scope turn_main_: {
    //     addiu   sp, sp,-0x0030              // allocate stack space
    //     sw      ra, 0x0024(sp)              // store ra
    //     lw      v1, 0x0084(a0)              // v1 = player struct
    //     lw      t6, 0x0B18(v1)              // t6 = frame timer
    //     slti    at, t6, MAX_TIME            // at = 1 if frame timer < MAX_TIME, else at = 0
    //     addiu   t6, t6, 0x0001              // ~
    //     bnez    at, _check_end_transition   // branch if frame timer < MAX_TIME
    //     sw      t6, 0x0B18(v1)              // increment frame timer
    //
    //     // if frame timer has reached MAX_TIME
    //     lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
    //     or      a2, r0, r0                  // a2 (unknown) = 0
    //     lli     a3, 0x0001                  // a3 (unknown) = 1
    //     sw      r0, 0x0010(sp)              // unknown argument = 0
    //     sw      r0, 0x0018(sp)              // interrupt flag = FALSE
    //     lui     t6, LANDING_FSM             // t6 = LANDING_FSM
    //     jal     0x801438F0                  // begin special fall
    //     sw      t6, 0x0014(sp)              // store LANDING_FSM
    //     b       _end                        // end
    //     nop
    //
    //     _check_end_transition:
    //     // checks the current animation frame to see if we've reached end of the animation
    //     mtc1    r0, f6                      // ~
    //     lwc1    f8, 0x0078(a0)              // ~
    //     c.le.s  f8, f6                      // ~
    //     bc1fl   _end                        // skip if animation end has not been reached
    //     nop
    //     lw      at, 0x0044(v1)              // at = DIRECTION
    //     subu    at, r0, at                  // ~
    //     sw      at, 0x0044(v1)              // reverse and update DIRECTION
    //     jal     shared_initial_             // transition to USP action
    //     lli     a1, SKnight.Action.USPG       // a1(action id) = USP
    //
    //     _end:
    //     lw      ra, 0x0024(sp)              // load ra
    //     jr      ra                          // return
    //     addiu   sp, sp, 0x0030              // deallocate stack space
    // }

    // @ Description
    // Main function for USPAttack.
    scope attack_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      t6, 0x0B18(v1)              // t6 = frame timer
        slti    at, t6, MAX_TIME            // at = 1 if frame timer < MAX_TIME, else at = 0
        addiu   t6, t6, 0x0001              // ~
        bnez    at, _check_end_transition   // branch if frame timer < MAX_TIME
        sw      t6, 0x0B18(v1)              // increment frame timer

        // if frame timer has reached MAX_TIME
        lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        b       _end                        // end
        nop

        _check_end_transition:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     shared_initial_             // transition to USP action
        lli     a1, SKnight.Action.USPG       // a1(action id) = USP

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main subroutine for USPJump.
    // Transitions to special fall on animation end.
    scope jump_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra

        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      t6, 0x017C(v1)              // t6 = temp variable 1
        lli     at, 0x0001                  // ~
        bne     t6, at, _check_end_transition // branch if temp variable 1 != 1
        lli     at, 0x0002                  // ~

        // apply jump velocity if temp variable 1 = 1
        sw      at, 0x017C(v1)              // temp variable 1 = 2
        lui     at, JUMP_SPEED              // ~
        sw      at, 0x004C(v1)              // y velocity = JUMP_SPEED

        _check_end_transition:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        // begin a special fall if the end of the animation has been reached
        lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main subroutine for USPEscape.
    // Transitions to special fall on animation end.
    scope escape_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra

        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        // begin a special fall if the end of the animation has been reached
        lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Interrupt function for USP actions
    scope interrupt_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      a1, 0x0084(a0)              // a1 = player struct

        // begin by checking for A and B presses
        lhu     v0, 0x01BE(a1)              // v0 = buttons_pressed
        andi    at, v0, Joypad.B | Joypad.A // at = !0 if (B_PRESSED) or (A_PRESSED), else t6 = 0
        beqz    at, _check_escape           // branch if both A and B are not being pressed
        nop

        // if we're here, A or B has been pressed, so transition to USPAttack
        jal     check_turn_                 // check for turnaround inputs
        nop
        jal     shared_initial_             // transition to USP action
        lli     a1, SKnight.Action.USPAttack // a1(action id) = USPAttack
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _check_escape:
        // now check if Shield button has been pressed
        lhu     at, 0x01B8(a1)              // at = shield press bitmask
        and     at, at, v0                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _check_jump         // branch if shield is not pressed
        nop

        // if we're here, Shield has been pressed, so transition to USPEscape
        lui     at, ESCAPE_SPEED            // ~
        sw      at, 0x004C(a1)              // y velocity = ESCAPE_SPEED
        jal     shared_initial_             // transition to USP action
        lli     a1, SKnight.Action.USPEscape // a1(action id) = USPEscape
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _check_jump:
        // finally, check for C inputs
        // at = !0 if (CU_PRESSED) or (CD_PRESSED) or (CL_PRESSED) or (CR_PRESSED), else t6 = 0
        andi    at, v0, Joypad.CU | Joypad.CD | Joypad.CL | Joypad.CR
        beqzl   at, _end                    // branch if no c buttons are being pressed...
        lw      ra, 0x0014(sp)              // ...and load ra

        // if we're here, a C button has been pressed, so transition to USPJump
        jal     check_turn_                 // check for turnaround inputs
        nop
        jal     shared_initial_             // transition to USP action
        lli     a1, SKnight.Action.USPJump   // a1(action id) = USPJump
        lw      ra, 0x0014(sp)              // load ra

        _end:
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // dellocate stack space
    }

    // @ Description
    // Handles movement for USP actions.
    scope physics_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      s0, 0x0024(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct

        _check_movement:
        lb      t6, 0x01C2(s0)              // t6 = stick_x
        bltzl   t6, pc() + 8                // if stick_x is negative...
        subu    t6, r0, t6                  // ...make stick_x positive
        lb      t7, 0x01C3(s0)              // t7 = stick_y
        bltzl   t7, pc() + 8                // if stick_x is negative...
        subu    t7, r0, t7                  // ...make stick_y positive
        slti    at, t6, 11                  // at = 1 if |stick_x| < 11, else at = 0
        beqz    at, _check_stick            // branch if |stick_x| >= 10
        slti    at, t7, 11                  // at = 1 if |stick_y| < 11, else at = 0
        beqz    at, _check_stick            // branch if |stick_y| >= 10
        nop

        _check_min_speed:
        // if we're here then stick_x and stick_y are both < 11, so consider the stick neutral
        lwc1    f2, 0x0048(s0)              // f2 = x velocity
        mul.s   f2, f2, f2                  // f2 = x velocity^2
        lwc1    f4, 0x004C(s0)              // f4 = y velocity
        mul.s   f4, f4, f4                  // f4 = y velocity^2
        add.s   f4, f2, f4                  // ~
        sqrt.s  f4, f4                      // f4 = current speed = sqrt(x velocity^2 + y velocity^2)
        lui     at, MIN_SPEED               // ~
        mtc1    at, f6                      // f6 = MIN_SPEED
        c.le.s  f4, f6                      // ~
        mtc1    r0, f2                      // target x velocity = 0
        bc1fl   _apply_movement             // apply movement if current speed < MIN_SPEED...
        mtc1    r0, f4                      // ...and target y velocity = 0
        // set velocity to 0 if below minimum speed
        sw      r0, 0x0048(s0)              // x velocity = 0
        b       _end                        // end
        sw      r0, 0x004C(s0)              // y velocity = 0

        _check_stick:
        lui     at, 0x3F08                  // ~
        mtc1    at, f0                      // f0 = 0.53125
        lb      at, 0x01C2(s0)              // ~
        mtc1    at, f2                      // ~
        cvt.s.w f2, f2                      // f2 = stick_x
        mul.s   f2, f2, f0                  // f2 = target x velocity = stick_x * 0.53125
        lb      at, 0x01C3(s0)              // ~
        mtc1    at, f4                      // ~
        cvt.s.w f4, f4                      // f4 = stick_y
        mul.s   f4, f4, f0                  // f4 = target y velocity = stick_y * 0.53125
        mul.s   f6, f2, f2                  // ~
        mul.s   f8, f4, f4                  // ~
        add.s   f6, f6, f8                  // ~
        sqrt.s  f6, f6                      // f6 = absolute target velocity
        lui     at, 0x422A                  // ~
        mtc1    at, f8                      // f8 = 42.5 = 80 * 0.53125
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _apply_movement             // branch if absolute target velocity < 50
        nop

        // adjust the target velocity if it is above 80
        div.s   f10, f8, f6                 // f10 = velocity multiplier = 80 / absolute target velocity
        mul.s   f2, f2, f10                 // f2 = adjusted target x velocity
        mul.s   f4, f4, f10                 // f4 = adjusted target y velocity

        _apply_movement:
        lwc1    f6, 0x0048(s0)              // f6 = x velocity
        lwc1    f8, 0x004C(s0)              // f8 = y velocity
        sub.s   f14, f2, f6                 // f14 = X_DIFF
        jal     0x8001863C                  // f0 = atan2(f12,f14)
        sub.s   f12, f4, f8                 // f12 = Y_DIFF
        // f0 = acceleration angle
        swc1    f0, 0x0028(sp)              // 0x0028(sp) = acceleration angle
        jal     0x80035CD0                  // f0 = cos(f12)
        lwc1    f12, 0x0028(sp)             // f12 = acceleration angle
        lui     at, ACCELERATION            // ~
        mtc1    at, f2                      // f2 = ACCELERATION
        mul.s   f2, f2, f0                  // f2 = x velocity difference(ACCELERATION * cos(angle))
        lwc1    f4, 0x0048(s0)              // f4 = x velocity
        add.s   f4, f4, f2                  // f4 = x velocity + x velocity difference
        swc1    f4, 0x0048(s0)              // store updated x velocity
        // ultra64 sinf function
        jal     0x800303F0                  // f0 = sin(f12)
        lwc1    f12, 0x0028(sp)             // f12 = acceleration angle
        lui     at, ACCELERATION            // ~
        mtc1    at, f2                      // f2 = ACCELERATION
        mul.s   f2, f2, f0                  // f2 = y velocity difference(ACCELERATION * sin(angle))
        lwc1    f4, 0x004C(s0)              // f4 = y velocity
        add.s   f4, f4, f2                  // f4 = y velocity + y velocity difference
        swc1    f4, 0x004C(s0)              // store updated x velocity

        _end:
        lw      s0, 0x0024(sp)              // ~
        lw      ra, 0x0014(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Handles physics for USPJump
    scope jump_physics_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      t6, 0x017C(v1)              // t6 = temp variable 1
        bnez    t6, _control                // branch if temp variable 1 is set
        nop

        // before temp variable 1 is set
        jal     physics_                    // USP physics function
        nop
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _control:
        jal     0x800D9160                  // general physics function (allows player control)
        nop
        lw      ra, 0x0014(sp)              // load ra

        _end:
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for Goemons's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Goemon.
    scope collision_: {
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }

    // @ Description
    // Establishment of on hit routine for USP, based on 0x8015DB4C
    scope goemon_on_hit_subroutine_establishment_: {
       li       t6, goemon_on_hit_subroutine_
       sw       t6, 0x09EC(a0)
       sw       r0, 0x0B20(a0)

       jr       ra
       sw       r0, 0x017C(a0)
    }

    // @ Description
    // On hit routine for USP.
    scope goemon_on_hit_subroutine_: {
       addiu    sp, sp,-0x0018              // allocate stack space
       sw       ra, 0x0014(sp)              // store ra
       lw       a0, 0x0084(a0)              // a0 = player struct
       jal      destroy_attached_cloud_    // destroy attached minion
       sw       r0, 0x0AE4(a0)              // reset charge level
       lw       ra, 0x0014(sp)              // load ra
       jr       ra                          // return
       addiu    sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which attaches a cloud to Goemon's Feet.
    // a0 - player object
    scope attach_cloud_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0038(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct

        _goemon:
        li      t7, goemon_on_hit_subroutine_ // t7 = on hit subroutine

        _continue:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        or      a0, s0, r0                  // a0 = player struct
        jal     0x8015D35C                  // get part position
        addiu   a1, sp, 0x0028              // a1 = address to return x/y/z coordinates to
        lw      a0, 0x0038(sp)              // a0 = player object
        addiu   a2, sp, 0x0028              // x/y/z coordinates

		// makes a cloud
        lw      a0, 0x0038(sp)              // 0x0034(sp) = player object
        lw      t0, 0x0084(a0)              // loads player struct
        addiu   a3, sp, 0x0040              // a3 = unknown x/y/z offset
        sw      r0, 0x0000(a3)              // x offset
        sw      r0, 0x0004(a3)              // set y offset to 0
        sw      r0, 0x0008(a3)              // z offset
        li      a1, Item.CloudSK.item_info_array // a1 = cloud

        _create_cloud:
        jal     Item.CloudSK.SPAWN_ITEM           // create item
        addiu   a3, sp, 0x0040                  // a3 = unknown x/y/z offset
        beqz    v0, _end                     // end if item not created
        li      at, Size.item.render_routine_
        sw      at, 0x002C(v0)              // set custom render routine so size is obeyed

        _end:
        sw      v0, 0x0B20(s0)              // store attached item object
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

    // @ Description
    // Destroys Goemon's attached item object.
    // @ Arguments
    // a0 - player struct
    scope destroy_attached_cloud_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      a1, 0x0B20(a0)              // a1 = attached item object
        beqz    a1, _end                    // skip if no attached item object
        sw      r0, 0x0B20(a0)              // reset attached item object

        or      a0, a1, r0                  // a0 = attached item object
        lw      a1, 0x0084(a0)              // a1 = item special struct
        lli     at, 0x001C                  // at = fake item id
        jal     0x801728D4                  // destroy item
        sw      at, 0x000C(a1)              // override item id to prevent smoke gfx

        _end:
        lw       ra, 0x0014(sp)             // load ra
        jr       ra                         // return
        addiu    sp, sp, 0x0018             // deallocate stack space
    }























    // @ Description
    // Deals with transition to part 2 of action
    scope usp_transition_attackl_: {
        addiu   sp, sp, -0x0020             // ~
        sw      ra, 0x001C(sp)              // ~
        addiu   t6, r0, 0x0003
        sw      a0, 0x0020(sp)
        sw      t6, 0x0010(sp)
        addiu   a1, r0, SKnight.Action.USPEscape  // insert action in a1
        addiu   a2, r0, 0x0000





        lw      t0, 0x0084(a0)              // load player struct
        sw      r0, 0x017C(t0)              // temp variable 1 = 0
        sw      r0, 0x0180(t0)              // temp variable 2 = 0
        sw      r0, 0x0184(t0)              // temp variable 3 = 0





        jal     0x800E6F24                  // change action routine
        lui     a3, 0x3f80

        jal     0x800E0830
        lw      a0, 0x0020(sp)

        jal     0x8015BFBC
        lw      a0, 0x0020(sp)






        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~

        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Deals with transition to part 2 of action
    scope usp_transition_attack_: {
        addiu   sp, sp, -0x0020             // ~
        sw      ra, 0x001C(sp)              // ~
        addiu   t6, r0, 0x0003
        sw      a0, 0x0020(sp)
        sw      t6, 0x0010(sp)
        addiu   a1, r0, 0xE4 // insert action in a1
        addiu   a2, r0, 0x0000

        lw      t0, 0x0084(a0)              // load player struct
        sw      r0, 0x017C(t0)              // temp variable 1 = 0
        sw      r0, 0x0180(t0)              // temp variable 2 = 0
        sw      r0, 0x0184(t0)              // temp variable 3 = 0

        jal     0x800E6F24                  // change action routine
        lui     a3, 0x3f80

        jal     0x800E0830
        lw      a0, 0x0020(sp)

        jal     0x8015BFBC
        lw      a0, 0x0020(sp)

        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~

        jr      ra                          // original return logic
        nop
    }



    // @ Description
    // Main subroutine for Banjo's up special begin.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    scope begin_main_: {
        addiu   sp, sp, -0x0028              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0004(sp)

        _update_buffer:
        lw      a2, 0x0084(a0)              // a2 = player struct
        lbu     t1, 0x01BE(a2)              // t1 = button_pressed
        lw      t2, 0x0B18(a2)              // t2 = button_press_buffer
        or      t1, t1, t2                  // t1 = button_pressed | button_press_buffer
        sw      t1, 0x0B18(a2)              // update button_press_buffer with current inputs
        sw      t1, 0x0018(sp)              // save button_pressed to stack

        lui     at, 0x4120                  // at = 10.0
        mtc1    at, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1tl   _animation                  // skip if haven't reached frame 8
        nop




        lw      t3, 0x0018(sp)              // load button press buffer
        andi    t1, t3, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _lusing          // skip if (!B_PRESSED)
        nop


        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE

        jal     usp_transition_attack_
        nop

        beq     r0, r0, _end
        nop



        _lusing:        
        lw      t3, 0x0018(sp)              // load button press buffer
        andi    t1, t3, A_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _zusing          // skip if (!B_PRESSED)
        nop



        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE



        jal     air_initial2_
        nop

        beq     r0, r0, _end
        nop






        _zusing:        
        lw      t3, 0x0018(sp)              // load button press buffer
        andi    t1, t3, Z_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _animation          // skip if (!B_PRESSED)
        nop



        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE



        jal     usp_transition_attackl_
        nop

        beq     r0, r0, _end
        nop






        _animation:
        lw      a0, 0x0004(sp)
        mtc1           r0, f4
        c.le.s         f8, f4
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        lui     a1, 0x3F80                  // a1 (air speed multiplier) = 1
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, BEGIN_LANDING_FSM       // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM

        _end:
        lw      ra, 0x0024(sp)              // ~
        addiu   sp, sp, 0x0028              // ~
        jr      ra                          // original return logic
        nop
    }




    scope ground_main_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      r0, 0x0010(sp)              // original begin logic

        lhu     at, 0x01B8(a1)              // at = shield press bitmask
        and     at, at, v0                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _end         // branch if shield is not pressed
        // if we're here, Shield has been pressed, so transition to USPEscape
        jal     0x801438F0   // a1(action id) = USPJump
        b       _end                        // end
        nop


        _end:
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop


    }

    // @ Description
    // Subroutine which sets up the movement for the grounded version of Body Slam.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x2 = apply movement speed
    scope ground_move_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // store t0, t1

        _check_begin:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_move         // skip if t0 != BEGIN
        nop
        // slow x movement
        lwc1    f0, 0x0060(a2)              // f0 = current ground x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0060(a2)              // x velocity = (x velocity * 0.875)

        _check_move:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _end                // skip if t0 != MOVE
        nop
        // apply x velocity
        lui     t1, X_SPEED                 // t1 = X_SPEED
        sw		t1, 0x0060(a2)	            // ground x velocity = X_SPEED





        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles physics for Wario's grounded neutral special.
    // Copy of subroutine 0x800D8BB4, loads a hard-coded traction value instead of the character's
    // traction value.
    scope ground_physics_: {
        // Copy the first 10 lines of subroutine 0x800D8BB4
        OS.copy_segment(0x543B4, 0x28)
        // Replace original lines which load the base friction from the friction table
        constant UPPER(Surface.friction_table >> 16)
        constant LOWER(Surface.friction_table & 0xFFFF)
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)
        } else {
            lui     at, UPPER
        }
        addu    at, at, t9
        lwc1    f4, LOWER(at)
        // Replace original line which loads the character's grounded tracion value
        // lwc1 f6, 0x0024(v0)              // replaced line
        lui     a1, GROUND_TRACTION         // ~
        mtc1    a1, f6                      // f6 = GROUND_TRACTION
        // Copy the last 10 lines of subroutine 0x800D8BB4
        OS.copy_segment(0x543EC, 0x28)
    }

    // @ Description
    // Subroutine which handles collision for Wario's grounded neutral special.
    scope ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // store ra, a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lbu     a1, 0x000D(a0)              // a1 = player port
        li      a2, special_jim_flag        // ~
        addu    t0, a2, a1                  // t0 = px special_jim_flag address
        lw      a1, 0x0184(a0)              // a1 = temp variable 3
        ori     a2, r0, MOVE                // a2 = MOVE
        bnel    a1, a2, _recoil_check       // skip if a1 != MOVE
        sb      r0, 0x0000(t0)              // reset px special_jim_flag on branch

        lhu     a1, 0x00CC(a0)              // a1 = collision flags
        lw      t1, 0x0044(a0)              // t0 = direction
        bgezl   t1, _wall_collision         // branch if direction = right
        andi    a1, a1, WALL_COLLISION_L    // a1 = collision flags & WALL_COLLISION_L
        andi    a1, a1, WALL_COLLISION_R    // a1 = collision flags & WALL_COLLISION_R

        _wall_collision:
        beql    a1, r0, _recoil_check       // skip if !WALL_COLLISION
        sb      r0, 0x0000(t0)              // reset px special_jim_flag on branch
        lbu     a1, 0x0000(t0)              // a2 = px special_jim_flag
        bne     a1, r0, _recoil_check       // skip if Jim's special collision flag is enabled
        nop
        // enable the flag to begin recoil
        ori     a1, r0, 0x0001              // ~
        sw      a1, 0x017C(a0)              // temp variable 1 = 0x1 (recoil flag = true)

        _recoil_check:
        li      a1, _end                    // a1 = _end
        jal     check_recoil_               // check for recoil transition
        lw      a0, 0x0010(sp)              // load a0
        li      a1, ground_to_air_          // a1 = ground_to_air_
        jal     0x800DDDDC                  // ground collision (with slide-off)
        lw      a0, 0x0010(sp)              // load a0
        lw      a0, 0x0010(sp)              // load a0
        lw      a0, 0x0084(a0)              // a0 = player struct

        lw      a1, 0x0008(a0)              // a1 = current character id
        lli     a2, Character.id.KIRBY      // a2 = id.KIRBY
        beq     a1, a2, _kirby              // branch if character id = KIRBY
        lli     a2, Character.id.JKIRBY     // a2 = id.JKIRBY
        bne     a1, a2, _sknight              // branch if character id != JKIRBY
        nop

        _kirby:
        lw      a1, 0x0024(a0)              // a1 = current action
        lli     a2, Kirby.Action.WARIO_NSP_Ground
        bne     a1, a2, _end                // skip if action id != ground nsp
        nop
        b       _jump                       // check for jump
        nop

        _sknight:
        lw      a1, 0x0024(a0)              // a1 = current action
        ori     a2, r0, 0x00E3              // a2 = action id: ground nsp
        bne     a1, a2, _end                // skip if action id != ground nsp
        nop

        _jump:
        lw      a1, 0x0184(a0)              // a1 = temp variable 3
        ori     a2, r0, MOVE                // a2 = MOVE
        bne     a1, a2, _end                // skip if a1 != MOVE
        nop
        jal     0x8013F474                  // check jump (returns 0 for no jump)
        nop
        beq     v0, r0, _end                // skip if !jump
        nop
        lw      a0, 0x0010(sp)              // load a0
        jal     ground_to_air_              // transition from ground to air
        nop
        lw      a0, 0x0010(sp)              // load a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     a1, JUMP_SPEED              // a1 = JUMP_SPEED
        sw      a1, 0x004C(a0)              // y velocity = JUMP_SPEED
        lw      a0, 0x0078(a0)              // a0 = player x/y/z pointer
        ori     a1, r0, 0x0001              // a1 = 0x1
        lui     a2, 0x3F80                  // a2 = float: 1.0
        jal     0x800FF3F4                  // jump smoke graphic
        nop
        ori     a0, r0, 0x005E              // a0 = FGM ID

        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles ground to air transition Wario's grounded neutral special.
    scope ground_to_air_: {
        OS.copy_segment(0xDE2EC, 0x18)      // copy beginning of subroutine from Link NSP
        ori     t7, r0, 0x0003              // t7 = 0x0003 (hitbox persist)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Air
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Air

        ori     a1, r0, 0x00E4              // a1 = 0xE0

        OS.copy_segment(0xDE30C, 0x20)      // copy end of subroutine from Link NSP
    }

    // @ Description
    // Subroutine which sets up the movement for the aerial version of Body Slam.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x1 = begin
    // 0x2 = apply movement speed
    // Also uses command 58000001 for to set y velocity when movement begins.
    scope air_move_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      t0, 0x000C(sp)              // ~
        sw      t1, 0x0010(sp)              // ~
        swc1    f0, 0x0014(sp)              // ~
        swc1    f2, 0x0018(sp)              // store a0, ra, t0, t1, f0, f2

        _check_begin:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_move         // skip if t0 != BEGIN
        nop
        // slow x movement
        lwc1    f0, 0x0048(a2)              // f0 = current x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0048(a2)              // x velocity = (x velocity * 0.875)


        _check_move:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _check_y            // skip if t0 != MOVE
        nop
        // apply x velocity
        lui     t1, X_SPEED                 // ~
        mtc1    t1, f0                      // f0 = X_SPEED
        lwc1    f2, 0x0044(a2)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        mul.s   f0, f0, f2                  // f0 = X_SPEED * DIRECTION
        swc1    f0, 0x0048(a2)              // x velocity = X_SPEED * DIRECTION

        _check_y:
        lw      t0, 0x0180(a2)              // temp variable 2
        beq     t0, r0, _end                // skip if temp variable 2 = 0
        nop
        _apply_y:
        sw      r0, 0x0180(a2)              // temp variable 2 = 0
        // falcon punch subroutine which takes stick_y and returns an angle in radians to f0
        jal     0x8015F874                  // return f0 = angle
        lb      a0, 0x01C3(a2)              // a0 = stick_y
        // ultra64 sinf function
        jal     0x800303F0                  // return f0 = sin(angle)
        mov.s   f12, f0                     // f12 = angle
        // sine used to calculate final Y_SPEED
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f2                      // f2 = X_SPEED
        mul.s   f0, f0, f2                  // f2 = sin(angle) * X_SPEED
        // multiply by 0.75 to reduce the range of angles
        lui     t0, 0x3F40                  // ~
        mtc1    t0, f2                      // f2 = 0.75
        mul.s   f0, f0, f2                  // f2 = f2 * 0.75
        // add base speed
        lui     t0, Y_SPEED                 // ~
        mtc1    t0, f2                      // f2 = Y_SPEED
        add.s   f0, f0, f2                  // f0 = f2 + Y_SPEED
        swc1    f0, 0x004C(a2)              // store final y velocity

        _end:
        lw      ra, 0x0004(sp)              // ~
        lw      a0, 0x0008(sp)              // ~
        lw      t0, 0x000C(sp)              // ~
        lw      t1, 0x0010(sp)              // ~
        lwc1    f0, 0x0014(sp)              // ~
        lwc1    f2, 0x0018(sp)              // load a0, ra, t0, t1, f0, f2
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles physics for Wario's aerial neutral special.
    // Modified version of subroutine 0x800D91EC.
    scope air_physics_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw    	ra, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // store t0, t1, ra, a0
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0180(t0)              // t1 = temp variable 2
        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control
        bnez    t1, _subroutine             // skip if t1 != 0
        nop


        _subroutine:
        jalr      t8                        // run physics subroutine
        nop

        _check_fall:
        lw      a0, 0x0010(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t0, 0x0184(a0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_move         // skip if temp variable 3 != BEGIN
        nop



        _check_move:
        lw      t0, 0x0184(a0)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _end                // skip if t0 != MOVE
        nop
        // apply y velocity
        lui     t1, Y_SPEED                 // ~
        sw      t1, 0x004C(a0)              // y velocity = Y_SPEED

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // load t0, t1, ra, a0
        addiu 	sp, sp, 0x0018				// deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles collision for Wario's aerial neutral special.
    scope air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // store ra, a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lbu     a1, 0x000D(a0)              // a1 = player port
        li      a2, special_jim_flag        // ~
        addu    t0, a2, a1                  // t0 = px special_jim_flag address
        lw      a1, 0x0184(a0)              // a1 = temp variable 3
        ori     a2, r0, MOVE                // a2 = MOVE
        bnel    a1, a2, _recoil_check       // skip if a1 != MOVE
        sb      r0, 0x0000(t0)              // reset px special_jim_flag on branch

        lhu     a1, 0x00CC(a0)              // a1 = collision flags
        lw      t1, 0x0044(a0)              // t0 = direction
        bgezl   t1, _wall_collision         // branch if direction = right
        andi    a1, a1, WALL_COLLISION_L    // a1 = collision flags & WALL_COLLISION_L
        andi    a1, a1, WALL_COLLISION_R    // a1 = collision flags & WALL_COLLISION_R

        _wall_collision:
        beql    a1, r0, _recoil_check       // skip if !WALL_COLLISION
        sb      r0, 0x0000(t0)              // reset px special_jim_flag on branch
        ori     a1, r0, OS.TRUE             // ~
        sb      a1, 0x0000(t0)              // px special_jim_flag = TRUE

        _recoil_check:
        li      a1, _end                    // a1 = _end
        jal     check_recoil_               // check for recoil transition
        lw      a0, 0x0010(sp)              // load a0
        li      a1, air_to_ground_          // a1 = air_to_ground_
        jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
        lw      a0, 0x0010(sp)              // load a0

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which handles air to ground transition Wario's grounded neutral special.
    scope air_to_ground_: {
        OS.copy_segment(0xD098C, 0x1C)      // copy beginning of subroutine from Mario NSP
        ori     t7, r0, 0x0003              // t7 = 0x0003 (hitbox persist)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Ground

        ori     a1, r0, 0x03B              // a1 = 0xDF

        lw      a2, 0x0078(a0)              // a2 = current animation frame
        sw      t7, 0x0010(sp)              // store t7 (some kind of parameter for change action)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0028              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which sets up the movement for the Body Slam recoil.
    // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // Variable values used by this subroutine:
    // 0x1 = end special movement
    scope recoil_move_: {
        // a2 = player struct
        // 0x180 in player struct = temp variable 2

        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        swc1    f0, 0x000C(sp)              // ~
        swc1    f2, 0x0010(sp)              // store t0, f0, f2

        _check_movement:
        lw      t0, 0x0180(a2)              // t0 = temp variable 2
        bnez    t0, _end                    // skip if t0 > 0
        nop
        // slow x movement
        lwc1    f0, 0x0048(a2)              // f0 = current x velocity
        lui     t0, 0x3F78                  // ~
        mtc1    t0, f2                      // f2 = 0.96875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.96875
        swc1    f0, 0x0048(a2)              // x velocity = (x velocity * 0.96875)
        // slow falling speed
        lw      t0, 0x0008(a2)              // t0 = character id
        lli     t1, Character.id.SKNIGHT      // t1 = id.WARIO
        beq     t1, t0, _modify_y_velocity  // branch if character id = WARIO
        lui     t0, 0x3FA0                  // t0 = 1.25

        // if we're here, the character is Kirby or J Kirby
        // (unless another character is eventually allowed to use Wario's neutral special)
        li      t0, 0x3F0CCCCD              // t0 = 0.55

        _modify_y_velocity:
        mtc1    t0, f0                      // f0 = 1.25/0.55
        lwc1    f2, 0x004C(a2)              // f2 = y velocity
        add.s   f0, f2, f0                  // f0 = y velocity + 1.25/0.55
        swc1    f0, 0x004C(a2)              // store updated y velocity
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lwc1    f0, 0x000C(sp)              // ~
        lwc1    f2, 0x0010(sp)              // load t0, t1, f0, f2
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles physics for the recoil.
    // Prevents player control when temp variable 2 = 0
    scope recoil_physics_: {
        // 0x180 in player struct = temp variable 2
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw    	ra, 0x000C(sp)              // store t0, t1, ra
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0180(t0)              // t1 = temp variable 2
        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control
        bnez    t1, _subroutine             // skip if t1 != 0
        nop
        li      t8, 0x800D91EC              // t8 = physics subroutine which prevents player control

        _subroutine:
        jalr      t8                        // run physics subroutine
        nop
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu 	sp, sp, 0x0010				// deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles hitbox collision for Wario's neutral special.
    // @ Arguments
    // a0 - entity struct?
    // a1 - return address upon collision
    scope check_recoil_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      a0, 0x000C(sp)              // ~
        sw      a1, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        swc1    f0, 0x0018(sp)              // ~
        swc1    f2, 0x001C(sp)              // store t0, t1, a0, a1, ra, f0, f2

        _check:
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x017C(t0)              // t1 = temp variable 1
        beq     t1, r0, _end                // skip if temp variable 1 = 0
        nop

        _collision:
        sw      a1, 0x0014(sp)              // overwrite return address in stack
        jal     air_initial_              // transition to recoil action
        nop
        lw      a0, 0x000C(sp)              // load a0
        lw      t0, 0x0084(a0)              // t0 = player struct
        sw      r0, 0x0180(t0)              // temp variable 2 = 0

        // initial y velocity
        lui     t1, RECOIL_Y_SPEED          // t1 = RECOIL_Y_SPEED
        sw      t1, 0x004C(t0)              // y velocity = RECOIL_Y_SPEED

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      a0, 0x000C(sp)              // ~
        lw      ra, 0x0014(sp)              // ~
        lwc1    f0, 0x0018(sp)              // ~
        lwc1    f2, 0x001C(sp)              // load t0, t1, ra, f0, f2
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions into Wario's neutral special recoil action.
    scope begin_recoil_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        ori     a0, r0, 0x0117              // a0 = FGM ID

        nop
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        bnez    t7, _end                    // skip if kinetic state !grounded
        nop
        jal     0x800DEEC8                  // set aerial state
        nop

        _end:
        lw      a0, 0x0020(sp)              // a0 = entity struct?
        ori     t7, r0, 0x0003              // t7 = 0x0003 (hitbox persist)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Air
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Air

        ori     a1, r0, SKnight.Action.DSP_Recoil_Air
        or      a2, r0, r0                  // a2 = 0(begin action frame)
        sw      t7, 0x0010(sp)              // store t7 (some kind of parameter for change action)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Recoil_Ground.
    scope recoil_ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, recoil_air_transition_  // a1(transition subroutine) = air_begin_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Recoil_Air.
    scope recoil_air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, recoil_ground_transition_ // a1(transition subroutine) = recoil_ground_transition_
        jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Recoil_Ground.
    scope recoil_ground_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Ground
        lli     a1, SKnight.Action.DSP_Recoil_Ground // a1(action id) = NSP_Recoil_Ground
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Recoil_Air.
    scope recoil_air_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Air
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Air
        lli     a1, SKnight.Action.DSP_Recoil_Air // a1(action id) = NSP_Recoil_Air
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // This is Jim's special collision flag.
    // Its primary purpose is to disable grounded wall collision recoil when Wario transitions from
    // air to ground while already colliding with a wall.
    // Its secondary purpose is to make Jim shut up.
    special_jim_flag:
    db 0x00 //p1
    db 0x00 //p2
    db 0x00 //p3
    db 0x00 //p4
}




