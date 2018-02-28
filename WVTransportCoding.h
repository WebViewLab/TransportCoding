/**
 * WVTransportCoding
 *
 * @copyleft (ↄ) 2018 WebView, Lab.
 *
 * @protected GNU General Public License.
 **/

#import <Foundation/NSString.h>

/*!
 * @enum WVCodingOptions
 * @brief Describes possible formats for encoding and decoding strings.
 **/
typedef NS_ENUM(NSUInteger, WVCodingOptions) {
	WVBase64,
	WVSafeBase64,
	WVBase32,
	WVExtendetBase32,
	WVBase16
};

NS_ASSUME_NONNULL_BEGIN

@interface WVTransportCoding : NSObject

/*!
 * @method encodeString:withOptions:
 * @return Encoded «NSString» in the format specified in the «WVCodingOptions» enumeration.
 **/
+ (nullable NSString *)encodeString:(nonnull NSString *)aString withOptions:(WVCodingOptions)aOptions;

/*!
 * @method encodeUTF8String:lenght:withOptions:
 * @param aLenght Accepts the full size of the C-string.
 * @return Encoded «nullable const char *» in the format specified in the «WVCodingOptions» enumeration.
 **/
+ (nullable const char *)encodeUTF8String:(nonnull const char *)aUTF8String lenght:(size_t)aLenght withOptions:(WVCodingOptions)aOptions;

/*!
 * @method decodeString:withOptions:
 * @return Decoded «NSString» that is encoded in the format specified in the «WVCodingOptions» enumeration
 **/
+ (nullable NSString *)decodeString:(nonnull NSString *)aString withOptions:(WVCodingOptions)aOptions;

/*!
 * @method decodeUTF8String:lenght:withOptions:
 * @param aLenght Accepts the full size of the C-string.
 * @return Decoded «nullable const char *» string that is encoded in the format specified in the «WVCodingOptions» enumeration
 **/
+ (nullable const char *)decodeUTF8String:(nonnull const char *)aUTF8String lenght:(size_t)aLenght withOptions:(WVCodingOptions)aOptions;

@end

NS_ASSUME_NONNULL_END
