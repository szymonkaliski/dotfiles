// Netable differences vs. the default firmware for the ErgoDox EZ:
// 1. The Cmd key is now on the right side, making Cmd+Space easier.
// 2. The media keys work on OSX (But not on Windows).
#include "ergodox_ez.h"
#include "debug.h"
#include "action_layer.h"

enum {
  L_BASE,
  L_SYMB,
  L_MDIA
};

enum {
  M_ULTRA,
  M_ESC
};

enum {
  F_GUI,
  F_SFT,
  F_ALT
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
/* Keymap 0: Basic layer
 *
 * ,--------------------------------------------------.           ,--------------------------------------------------.
 * |   =+   |   1  |   2  |   3  |   4  |   5  | `~   |           |      |   6  |   7  |   8  |   9  |   0  |   -_   |
 * |--------+------+------+------+------+-------------|           |------+------+------+------+------+------+--------|
 * | Tab    |   Q  |   W  |   E  |   R  |   T  |  L2  |           |  L2  |   Y  |   U  |   I  |   O  |   P  |   \|   |
 * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * |Ctrl/Esc|   A  |   S  |   D  |   F  |   G  |------|           |------|   H  |   J  |   K  |   L  |  :;  |   "'   |
 * |--------+------+------+------+------+------|  L1  |           |  L1  |------+------+------+------+------+--------|
 * | LShift |   Z  |   X  |   C  |   V  |   B  |      |           |      |   N  |   M  |  <,  |  >.  |   ?/ | RShift |
 * `--------+------+------+------+------+-------------'           `-------------+------+------+------+------+--------'
 *   | LAlt |      |      |   {  |   }  |                                       | Left | Down | Up   |Right | RAlt |
 *   `----------------------------------'                                       `----------------------------------'
 *                                        ,-------------.       ,-------------.
 *                                        |      |      |       |      |      |
 *                                 ,------|------|------|       |------+------+------.
 *                                 |      |      | L1   |       | L2   |      |      |
 *                                 |Backsp|Ultra |------|       |------|Enter |Space |
 *                                 |ace   |      | LCmd |       | RCmd |      |      |
 *                                 `--------------------'       `--------------------'
 */

[L_BASE] = KEYMAP(
// left hand
    KC_EQL,        KC_1,  KC_2,   KC_3,    KC_4,    KC_5,       KC_GRV,
    KC_TAB,        KC_Q,  KC_W,   KC_E,    KC_R,    KC_T,       MO(L_MDIA),
    CTL_T(KC_ESC), KC_A,  KC_S,   KC_D,    KC_F,    KC_G,
    F(F_SFT),      KC_Z,  KC_X,   KC_C,    KC_V,    KC_B,       MO(L_SYMB),
    F(F_ALT),      KC_NO, KC_NO,  KC_LBRC, KC_RBRC,
                                                    KC_NO,      KC_NO,
                                                                MO(L_SYMB),
                                           KC_BSPC, M(M_ULTRA), F(F_GUI),

// right hand
    KC_ESC,     KC_6,   KC_7,    KC_8,    KC_9,    KC_0,     KC_MINS,
    MO(L_MDIA), KC_Y,   KC_U,    KC_I,    KC_O,    KC_P,     KC_BSLS,
                KC_H,   KC_J,    KC_K,    KC_L,    KC_SCLN,  KC_QUOT,
    MO(L_SYMB), KC_N,   KC_M,    KC_COMM, KC_DOT,  KC_SLSH,  F(F_SFT),
                        KC_LEFT, KC_DOWN, KC_UP,   KC_RIGHT, F(F_ALT),
    KC_NO,      KC_NO,
    MO(L_MDIA),
    F(F_GUI),   KC_ENTER, KC_SPACE
),

/* Keymap 1: Symbol Layer
 *
 * ,--------------------------------------------------.           ,--------------------------------------------------.
 * |        |  F1  |  F2  |  F3  |  F4  |  F5  |      |           |      |  F6  |  F7  |  F8  |  F9  |  F10 |        |
 * |--------+------+------+------+------+-------------|           |------+------+------+------+------+------+--------|
 * |        |   !  |   @  |   {  |   }  |   |  |      |           |      |      |   7  |   8  |   9  |   *  |        |
 * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * |        |   #  |   $  |   (  |   )  |   `  |------|           |------|      |   4  |   5  |   6  |   +  |        |
 * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * |        |   %  |   ^  |   [  |   ]  |   ~  |      |           |      |      |   1  |   2  |   3  |   \  |        |
 * `--------+------+------+------+------+-------------'           `-------------+------+------+------+------+--------'
 *   |      |      |      |      |      |                                       |      |    . |   0  |   =  |      |
 *   `----------------------------------'                                       `----------------------------------'
 *                                        ,-------------.       ,-------------.
 *                                        |      |      |       |      |      |
 *                                 ,------|------|------|       |------+------+------.
 *                                 |      |      |      |       |      |      |      |
 *                                 |      |      |------|       |------|      |      |
 *                                 |      |      |      |       |      |      |      |
 *                                 `--------------------'       `--------------------'
 */

[L_SYMB] = KEYMAP(
// left hand
    KC_TRNS, KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_TRNS,
    KC_TRNS, KC_EXLM, KC_AT,   KC_LCBR, KC_RCBR, KC_PIPE, KC_TRNS,
    KC_TRNS, KC_HASH, KC_DLR,  KC_LPRN, KC_RPRN, KC_GRV,
    KC_TRNS, KC_PERC, KC_CIRC, KC_LBRC, KC_RBRC, KC_TILD, KC_TRNS,
    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
                                        KC_TRNS, KC_TRNS,
                                                 KC_TRNS,
                               KC_TRNS, KC_TRNS, KC_TRNS,

// right hand
    KC_TRNS, KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_TRNS,
    KC_TRNS, KC_TRNS, KC_7,    KC_8,    KC_9,    KC_ASTR, KC_TRNS,
             KC_TRNS, KC_4,    KC_5,    KC_6,    KC_PLUS, KC_TRNS,
    KC_TRNS, KC_TRNS, KC_1,    KC_2,    KC_3,    KC_BSLS, KC_TRNS,
                      KC_TRNS, KC_DOT,  KC_0,    KC_EQL,  KC_TRNS,
    KC_TRNS, KC_TRNS,
    KC_TRNS,
    KC_TRNS, KC_TRNS, KC_TRNS
),

/* Keymap 2: Media and arrow keys
 *
 * ,--------------------------------------------------.           ,--------------------------------------------------.
 * |        | F14  | F15  |      |      |      |Teensy|           |      | Prev | Play | Next |VolDn |VolUp |  Mute  |
 * |--------+------+------+------+------+-------------|           |------+------+------+------+------+------+--------|
 * |        |      |      |      |      |      |      |           |      |      |      |      |      |      |        |
 * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * |        |      |      |      |      |      |------|           |------| Left | Down | Up   |Right |      |        |
 * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * |        |      |      |      |      |      |      |           |      |      |      |      |      |      |        |
 * `--------+------+------+------+------+-------------'           `-------------+------+------+------+------+--------'
 *   |      |      |      |      |      |                                       |      |      |      |      |      |
 *   `----------------------------------'                                       `----------------------------------'
 *                                        ,-------------.       ,-------------.
 *                                        |      |      |       |      |      |
 *                                 ,------|------|------|       |------+------+------.
 *                                 |      |      |      |       |      |      |      |
 *                                 |      |      |------|       |------|      |      |
 *                                 |      |      |      |       |      |      |      |
 *                                 `--------------------'       `--------------------'
 */

[L_MDIA] = KEYMAP(
// left hand - f14/f15 act as brightness controls
    KC_TRNS, KC_F14,  KC_F15,  KC_TRNS, KC_TRNS, KC_TRNS, RESET,
    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
                                        KC_TRNS, KC_TRNS,
                                                 KC_TRNS,
                               KC_TRNS, KC_TRNS, KC_TRNS,
// right hand
    KC_TRNS, KC_MPRV, KC_MPLY, KC_MNXT, KC_VOLD,  KC_VOLU, KC_MUTE,
    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,  KC_TRNS, KC_TRNS,
             KC_LEFT, KC_DOWN, KC_UP,   KC_RIGHT, KC_TRNS, KC_TRNS,
    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,  KC_TRNS, KC_TRNS,
                      KC_TRNS, KC_TRNS, KC_TRNS,  KC_TRNS, KC_TRNS,
    KC_TRNS, KC_TRNS,
    KC_TRNS,
    KC_TRNS, KC_TRNS, KC_TRNS
),

};

const uint16_t PROGMEM fn_actions[] = {
  [L_SYMB] = ACTION_LAYER_MOMENTARY(L_SYMB),
  [L_MDIA] = ACTION_LAYER_MOMENTARY(L_MDIA),
  [F_SFT]  = ACTION_MODS_ONESHOT(MOD_LSFT),
  [F_GUI]  = ACTION_MODS_ONESHOT(MOD_LGUI),
  [F_ALT]  = ACTION_MODS_ONESHOT(MOD_LALT)
};

const macro_t *action_get_macro(keyrecord_t *record, uint8_t id, uint8_t opt) {
  switch(id) {
    // "ultra" key - like hyper/meh but also easy to click on macbook keyboard so I can have the same modifier in HS
    case M_ULTRA:
      return record->event.pressed ?
        MACRO(D(LCTL), D(LALT), D(LGUI), END) :
        MACRO(U(LCTL), U(LALT), U(LGUI), END);

    // escape and cancel oneshot layers
    // case M_ESC:
    //   if (record->event.pressed) {
    //     if (get_oneshot_mods() && !has_oneshot_mods_timed_out()) {
    //       clear_oneshot_mods();
    //     }
    //     else {
    //       register_code(KC_ESC);
    //     }
    //   } else {
    //     unregister_code(KC_ESC);
    //   }
    //   break;
  }

  return MACRO_NONE;
};

// Runs just one time when the keyboard initializes.
void matrix_init_user(void) {
};

// Runs constantly in the background, in a loop.
void matrix_scan_user(void) {
};
