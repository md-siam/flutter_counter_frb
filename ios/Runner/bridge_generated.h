#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
// EXTRA BEGIN
typedef struct DartCObject *WireSyncRust2DartDco;
typedef struct WireSyncRust2DartSse {
  uint8_t *ptr;
  int32_t len;
} WireSyncRust2DartSse;

typedef int64_t DartPort;
typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);
void store_dart_post_cobject(DartPostCObjectFnType ptr);
// EXTRA END
typedef struct _Dart_Handle* Dart_Handle;

void frbgen_flutter_counter_frb_wire__crate__api__decrement(int64_t port_);

void frbgen_flutter_counter_frb_wire__crate__api__get_counter(int64_t port_);

void frbgen_flutter_counter_frb_wire__crate__api__increment(int64_t port_);

void frbgen_flutter_counter_frb_wire__crate__api__reset(int64_t port_);
static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) frbgen_flutter_counter_frb_wire__crate__api__decrement);
    dummy_var ^= ((int64_t) (void*) frbgen_flutter_counter_frb_wire__crate__api__get_counter);
    dummy_var ^= ((int64_t) (void*) frbgen_flutter_counter_frb_wire__crate__api__increment);
    dummy_var ^= ((int64_t) (void*) frbgen_flutter_counter_frb_wire__crate__api__reset);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    return dummy_var;
}
