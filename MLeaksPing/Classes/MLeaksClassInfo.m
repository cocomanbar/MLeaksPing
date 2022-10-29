//
//  MLeaksClassInfo.m
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import "MLeaksClassInfo.h"

MLeaksEncodingType MLeaksEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return MLeaksEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return MLeaksEncodingTypeUnknown;
    
    MLeaksEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= MLeaksEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= MLeaksEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= MLeaksEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= MLeaksEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= MLeaksEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= MLeaksEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= MLeaksEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }

    len = strlen(type);
    if (len == 0) return MLeaksEncodingTypeUnknown | qualifier;

    switch (*type) {
        case 'v': return MLeaksEncodingTypeVoid | qualifier;
        case 'B': return MLeaksEncodingTypeBool | qualifier;
        case 'c': return MLeaksEncodingTypeInt8 | qualifier;
        case 'C': return MLeaksEncodingTypeUInt8 | qualifier;
        case 's': return MLeaksEncodingTypeInt16 | qualifier;
        case 'S': return MLeaksEncodingTypeUInt16 | qualifier;
        case 'i': return MLeaksEncodingTypeInt32 | qualifier;
        case 'I': return MLeaksEncodingTypeUInt32 | qualifier;
        case 'l': return MLeaksEncodingTypeInt32 | qualifier;
        case 'L': return MLeaksEncodingTypeUInt32 | qualifier;
        case 'q': return MLeaksEncodingTypeInt64 | qualifier;
        case 'Q': return MLeaksEncodingTypeUInt64 | qualifier;
        case 'f': return MLeaksEncodingTypeFloat | qualifier;
        case 'd': return MLeaksEncodingTypeDouble | qualifier;
        case 'D': return MLeaksEncodingTypeLongDouble | qualifier;
        case '#': return MLeaksEncodingTypeClass | qualifier;
        case ':': return MLeaksEncodingTypeSEL | qualifier;
        case '*': return MLeaksEncodingTypeCString | qualifier;
        case '^': return MLeaksEncodingTypePointer | qualifier;
        case '[': return MLeaksEncodingTypeCArray | qualifier;
        case '(': return MLeaksEncodingTypeUnion | qualifier;
        case '{': return MLeaksEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return MLeaksEncodingTypeBlock | qualifier;
            else
                return MLeaksEncodingTypeObject | qualifier;
        }
        default: return MLeaksEncodingTypeUnknown | qualifier;
    }
}

@implementation MLeaksClassInfo

@end

@implementation MLeaksIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) return nil;
    self = [super init];
    _ivar = ivar;
    const char *name = ivar_getName(ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    _offset = ivar_getOffset(ivar);
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = MLeaksEncodingGetType(typeEncoding);
    }
    return self;
}

@end

@implementation MLeaksPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    self = [super init];
    _property = property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    MLeaksEncodingType type = 0;
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
        switch (attrs[i].name[0]) {
            case 'T': { // Type encoding
                if (attrs[i].value) {
                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    type = MLeaksEncodingGetType(attrs[i].value);
                    
                    if ((type & MLeaksEncodingTypeMask) == MLeaksEncodingTypeObject && _typeEncoding.length) {
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                        
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
                        }
                    }
                }
            } break;
            case 'V': { // Instance variable
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'R': {
                type |= MLeaksEncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= MLeaksEncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= MLeaksEncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= MLeaksEncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= MLeaksEncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= MLeaksEncodingTypePropertyWeak;
            } break;
            case 'G': {
                type |= MLeaksEncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } break;
            case 'S': {
                type |= MLeaksEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } // break; commented for code coverage in next line
            default: break;
        }
    }
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }
    
    _type = type;
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
    return self;
}

@end
