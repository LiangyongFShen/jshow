#ifndef BASICTYPES_H_
#define BASICTYPES_H_

#include <limits.h>
#include <stddef.h>
#include <stdint.h>

typedef int8_t int8;
typedef uint8_t uint8;
typedef int16_t int16;
typedef int32_t int32;
typedef uint16_t uint16;
typedef uint32_t uint32;

#if defined(__LP64__) && !defined(OS_MACOSX)
typedef long int64;
typedef unsigned long uint64;
#else
typedef long long int64;
typedef unsigned long long uint64;
#endif

#endif  // BASICTYPES_H_