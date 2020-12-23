/*
 ============================================================================
 Name       : twlt_uuid_util.m
 Author      : FangYuan Gui
 Copyright : All Rights Reserved
 ============================================================================
 */

#include <stdio.h>
#include <string.h>
#import "SFHFKeychainUtils.h"
#import "twlt_uuid_util.h"
#import "YYKit.h"

#define _twlt_uuid_usr_name_ @"_twlt_uuid_usr_name_"
#define _twlt_uuid_service_name_ @"_twlt_uuid_service_name_"

static inline NSString* _create_uuid()
{
    CFUUIDRef uuid_ref = CFUUIDCreate( NULL );
    CFStringRef uuid_str = CFUUIDCreateString( NULL, uuid_ref );
    NSString* uuid = (NSString*)CFBridgingRelease( CFStringCreateCopy( NULL, uuid_str ) );
    
    CFRelease( uuid_ref );
    CFRelease( uuid_str );
    
    return uuid;
}

NSString*  twlt_uuid_create()
{
    NSString* old_uuid = [SFHFKeychainUtils getPasswordForUsername: _twlt_uuid_usr_name_
        andServiceName: _twlt_uuid_service_name_ error: nil];
    
    if ( 1 < [old_uuid length] ) {
        return old_uuid;
    }
    
    NSString* new_uuid = _create_uuid();
    const char* c_new_uuid = [new_uuid cStringUsingEncoding: NSUTF8StringEncoding];
    
    char* new_uuid_pt;

    if ( -1 == asprintf( &new_uuid_pt, "%f%s%f", [[NSDate date]timeIntervalSince1970], c_new_uuid, [[NSDate date]timeIntervalSince1970])) {
        return false;
    }
    
    NSString *aString = [NSString stringWithUTF8String:new_uuid_pt];
    
    free(new_uuid_pt );
    
//
//    
//    char* new_uuid_sha1 = sw_openssl_sha1_hexlc( (uint8_t*)new_uuid_pt, strlen( new_uuid_pt ) );
//    
//    free( new_uuid_pt );
//    
//    if ( NULL == new_uuid_sha1 ) {
//        return false;
//    }
    
    
//    NSString* uuid_sha1 = sw_cstr_to_utf8_nstr( new_uuid_sha1 );
//    free( new_uuid_sha1 );
    
    NSString *md5String = [aString md5String];
    BOOL ret = [SFHFKeychainUtils storeUsername: _twlt_uuid_usr_name_ andPassword:md5String
            forServiceName: _twlt_uuid_service_name_ updateExisting: NO error: nil];
    
    return ( ret ) ? ( md5String ) : ( nil );
}

/* end */
