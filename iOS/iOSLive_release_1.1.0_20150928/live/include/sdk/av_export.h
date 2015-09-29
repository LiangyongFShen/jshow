#ifndef AV_EXPORT_H_
#define AV_EXPORT_H_

#include "build_config.h"

#ifdef OS_WIN
#if defined(AV_IMPLEMENTATION)
#define AV_EXPORT __declspec(dllexport)
#else
#define AV_EXPORT __declspec(dllimport)
#endif  // defined(AV_IMPLEMENTATION)
#else
#define AV_EXPORT
#endif

#define DISALLOW_EVIL_DESTRUCTIONS(TypeName)    \
    protected:  \
        virtual ~TypeName() {}

#endif // #ifndef AV_EXPORT_H_