
/*
 *  neo_aea_sign.h
 *  libNeoAppleArchive
 *
 *  Created by Snoolie Keffaber on 2025/05/18.
 *  DO NOT INCLUDE THIS HEADER IN ORIGINAL SOURCE.
 *  It is currently only meant for Lina, until
 *  neo_aea_sign is complete enough...
 */

#ifndef EXCLUDE_AEA_SUPPORT

#ifndef libNeoAppleArchive_h
#error Include libNeoAppleArchive.h instead of this file
#endif

/*
 * Only NEO_AEA_PROFILE_HKDF_SHA256_HMAC_NONE_ECDSA_P256 is supported ATM.
 * NEO_AEA_PROFILE_HKDF_SHA256_AESCTR_HMAC_SYMMETRIC_NONE has plans to be
 * supported in the future as OTA/IPSWs use it.
 */

#ifndef lina_sign_h
#define lina_sign_h

#include <inttypes.h>

#ifdef __cplusplus
extern "C" {
#endif

uint8_t *sign_aea_with_private_key_and_auth_data(void *aar, size_t aarSize, void *privateKey, size_t privateKeySize, uint8_t *authData, size_t authDataSize, size_t *outSize);

#ifdef __cplusplus
}
#endif

#endif /* lina_sign_h */

#endif /* EXCLUDE_AEA_SUPPORT */
