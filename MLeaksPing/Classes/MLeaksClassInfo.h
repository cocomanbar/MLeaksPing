//
//  MLeaksClassInfo.h
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 照搬YYModel那套
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, MLeaksEncodingType) {
    MLeaksEncodingTypeMask       = 0xFF,    ///< mask of type value
    MLeaksEncodingTypeUnknown    = 0,       ///< unknown
    MLeaksEncodingTypeVoid       = 1,       ///< void
    MLeaksEncodingTypeBool       = 2,       ///< bool
    MLeaksEncodingTypeInt8       = 3,       ///< char / BOOL
    MLeaksEncodingTypeUInt8      = 4,       ///< unsigned char
    MLeaksEncodingTypeInt16      = 5,       ///< short
    MLeaksEncodingTypeUInt16     = 6,       ///< unsigned short
    MLeaksEncodingTypeInt32      = 7,       ///< int
    MLeaksEncodingTypeUInt32     = 8,       ///< unsigned int
    MLeaksEncodingTypeInt64      = 9,       ///< long long
    MLeaksEncodingTypeUInt64     = 10,      ///< unsigned long long
    MLeaksEncodingTypeFloat      = 11,      ///< float
    MLeaksEncodingTypeDouble     = 12,      ///< double
    MLeaksEncodingTypeLongDouble = 13,      ///< long double
    MLeaksEncodingTypeObject     = 14,      ///< id
    MLeaksEncodingTypeClass      = 15,      ///< Class
    MLeaksEncodingTypeSEL        = 16,      ///< SEL
    MLeaksEncodingTypeBlock      = 17,      ///< block
    MLeaksEncodingTypePointer    = 18,      ///< void*
    MLeaksEncodingTypeStruct     = 19,      ///< struct
    MLeaksEncodingTypeUnion      = 20,      ///< union
    MLeaksEncodingTypeCString    = 21,      ///< char*
    MLeaksEncodingTypeCArray     = 22,      ///< char[10] (for example)
    
    MLeaksEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    MLeaksEncodingTypeQualifierConst  = 1 << 8,   ///< const
    MLeaksEncodingTypeQualifierIn     = 1 << 9,   ///< in
    MLeaksEncodingTypeQualifierInout  = 1 << 10,  ///< inout
    MLeaksEncodingTypeQualifierOut    = 1 << 11,  ///< out
    MLeaksEncodingTypeQualifierBycopy = 1 << 12,  ///< bycopy
    MLeaksEncodingTypeQualifierByref  = 1 << 13,  ///< byref
    MLeaksEncodingTypeQualifierOneway = 1 << 14,  ///< oneway
    
    MLeaksEncodingTypePropertyMask         = 0xFF0000,  ///< mask of property
    MLeaksEncodingTypePropertyReadonly     = 1 << 16,   ///< readonly
    MLeaksEncodingTypePropertyCopy         = 1 << 17,   ///< copy
    MLeaksEncodingTypePropertyRetain       = 1 << 18,   ///< retain
    MLeaksEncodingTypePropertyNonatomic    = 1 << 19,   ///< nonatomic
    MLeaksEncodingTypePropertyWeak         = 1 << 20,   ///< weak
    MLeaksEncodingTypePropertyCustomGetter = 1 << 21,   ///< getter=
    MLeaksEncodingTypePropertyCustomSetter = 1 << 22,   ///< setter=
    MLeaksEncodingTypePropertyDynamic      = 1 << 23,   ///< @dynamic
};

/**
 *  包装类上的Ivar信息 、 property信息
 */
@interface MLeaksClassInfo : NSObject

@end

@interface MLeaksIvarInfo : NSObject

@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) MLeaksEncodingType type;///< Ivar's type
@property (nullable, nonatomic, assign) Class cls;              ///< may be nil

/**
 Creates and returns an ivar info object.
 
 @param ivar ivar opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithIvar:(Ivar)ivar;

@end

@interface MLeaksPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) MLeaksEncodingType type;  ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign) Class cls;                ///< may be nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 Creates and returns a property info object.
 
 @param property property opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithProperty:(objc_property_t)property;

@end

NS_ASSUME_NONNULL_END
