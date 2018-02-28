/**
 * WVTransportCoding
 *
 * @copyleft (ↄ) 2018 WebView, Lab.
 *
 * @protected GNU General Public License.
 **/

#import "WVTransportCoding.h"

#include <stdlib.h>
#include <ctype.h>
#include <string.h>

@implementation WVTransportCoding

static const char base64Alphabet[] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
	'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
	'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
	'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3',
	'4', '5', '6', '7', '8', '9', '+', '/'
};

static const char base64SafeAlphabet[] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
	'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
	'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
	'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3',
	'4', '5', '6', '7', '8', '9', '-', '_'
};

static const char base32Alphabet[] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
	'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
	'Y', 'Z', '2', '3', '4', '5', '6', '7'
};

static const char base32ExtendedAlphabet[] = {
	'0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
	'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
	'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V'
};

static const char base16Alphabet[] = {
	'0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
};

+ (NSString *)encodeString:(NSString *)aString withOptions:(WVCodingOptions)aOptions {
	const char *encodedUTF8String = [self encodeUTF8String:aString.UTF8String lenght:aString.length withOptions:aOptions];
	if (!encodedUTF8String) {
		return nil;
	}
	NSString *encodedString = [NSString stringWithUTF8String:encodedUTF8String];
	return encodedString;
}

+ (const char *)encodeUTF8String:(const char *)aUTF8String lenght:(size_t)aLenght withOptions:(WVCodingOptions)aOptions {
	switch (aOptions) {
		case WVBase64:
			return [self encodeUTF8StringInBase64:aUTF8String lenght:aLenght alphabet:base64Alphabet];

		case WVSafeBase64:
			return [self encodeUTF8StringInBase64:aUTF8String lenght:aLenght alphabet:base64SafeAlphabet];

		case WVBase32:
			return [self encodeUTF8StringInBase32:aUTF8String lenght:aLenght alphabet:base32Alphabet];

		case WVExtendetBase32:
			return [self encodeUTF8StringInBase32:aUTF8String lenght:aLenght alphabet:base32ExtendedAlphabet];

		case WVBase16:
			return [self encodeUTF8StringInBase16:aUTF8String lenght:aLenght];

		default:
			return nil;
	}
}

#pragma mark - Encoding

+ (const char *)encodeUTF8StringInBase64:(const char *)aUTF8String lenght:(size_t)aLenght alphabet:(const char[])aAlphabet {
	if (aUTF8String && aLenght && aAlphabet) {
		char *tmpString = (char *)malloc(aLenght);
		if (!tmpString) {
			return nil;
		}
		strncpy(tmpString, aUTF8String, aLenght);

		char *encodeString = (char *)malloc(1);
		if (!encodeString) {
			return nil;
		}

		char *base64Block = (char *)calloc(4, 4);
		char *stringBlock = (char *)calloc(3, 3);
		if (!base64Block || !stringBlock) {
			return nil;
		}

		size_t size = 0;

		short i = 0;
		while (aLenght--) {
			stringBlock[i++] = *(tmpString++);

			if (i == 3) {
				base64Block[0] = (stringBlock[0] & 0xfc) >> 2;
				base64Block[1] = ((stringBlock[0] & 0x03) << 4) + ((stringBlock[1] & 0xf0) >> 4);
				base64Block[2] = ((stringBlock[1] & 0x0f) << 2) + ((stringBlock[2] & 0xc0) >> 6);
				base64Block[3] = stringBlock[2] & 0x3f;

				encodeString = (char *)realloc(encodeString, size + 4);
				if (!encodeString) {
					return nil;
				}

				for (short j = 0; j < 4; ++j) {
					encodeString[size++] = aAlphabet[base64Block[j]];
				}

				i = 0;
			}
		}

		if (i > 0) {
			for (short j = i; j < 3; ++j) {
				stringBlock[j] = '\0';
			}

			base64Block[0] = (stringBlock[0] & 0xfc) >> 2;
			base64Block[1] = ((stringBlock[0] & 0x03) << 4) + ((stringBlock[1] & 0xf0) >> 4);
			base64Block[2] = ((stringBlock[1] & 0x0f) << 2) + ((stringBlock[2] & 0xc0) >> 6);
			base64Block[3] = stringBlock[2] & 0x3f;

			for (short j = 0; j < (i + 1); ++j) {
				encodeString = (char *)realloc(encodeString, size + 1);
				if (!encodeString) {
					return nil;
				}
				encodeString[size++] = aAlphabet[base64Block[j]];
			}

			while (i++ < 3) {
				encodeString = (char *)realloc(encodeString, size + 1);
				if (!encodeString) {
					return nil;
				}
				encodeString[size++] = '=';
			}
		}

		encodeString = (char *)realloc(encodeString, size + 1);
		if (!encodeString) {
			return nil;
		}
		encodeString[size] = '\0';

		return encodeString;
	}

	return nil;
}

+ (const char *)encodeUTF8StringInBase32:(const char *)aUTF8String lenght:(size_t)aLenght alphabet:(const char[])aAlphabet {
	if (aUTF8String && aLenght && aAlphabet) {
		char *tmpString = (char *)malloc(aLenght);
		if (!tmpString) {
			return nil;
		}
		strncpy(tmpString, aUTF8String, aLenght);

		char *encodeString = (char *)malloc(1);
		if (!encodeString) {
			return nil;
		}

		char *base32Block = (char *)calloc(8, 8);
		char *stringBlock = (char *)calloc(5, 5);
		if (!base32Block || !stringBlock) {
			return nil;
		}

		size_t size = 0;

		short i = 0;
		while (aLenght--) {
			stringBlock[i++] = *(tmpString++);

			if (i == 5) {
				base32Block[0] = (stringBlock[0] & 0xF8) >> 3;
				base32Block[1] = ((stringBlock[0] & 0x07) << 2) + ((stringBlock[1] & 0xC0) >> 6);
				base32Block[2] = (stringBlock[1] & 0x3E) >> 1;
				base32Block[3] = ((stringBlock[1] & 0x01) << 4) + ((stringBlock[2] & 0xF0) >> 4);
				base32Block[4] = ((stringBlock[2] & 0x0F) << 1) + ((stringBlock[3] & 0x80) >> 7);
				base32Block[5] = ((stringBlock[3] & 0x7C) >> 2);
				base32Block[6] = ((stringBlock[3] & 0x03) << 3) + ((stringBlock[4] & 0xE0) >> 5);
				base32Block[7] = (stringBlock[4] & 0x1F);

				encodeString = (char *)realloc(encodeString, size + 8);
				if (!encodeString) {
					return nil;
				}

				for (short j = 0; j < 8; ++j) {
					encodeString[size++] = aAlphabet[base32Block[j]];
				}

				i = 0;
			}
		}

		if (i > 0) {
			for (short j = i; j < 5; ++j) {
				stringBlock[j] = '\0';
			}

			base32Block[0] = (stringBlock[0] & 0xF8) >> 3;
			base32Block[1] = ((stringBlock[0] & 0x07) << 2) + ((stringBlock[1] & 0xC0) >> 6);
			base32Block[2] = (stringBlock[1] & 0x3E) >> 1;
			base32Block[3] = ((stringBlock[1] & 0x01) << 4) + ((stringBlock[2] & 0xF0) >> 4);
			base32Block[4] = ((stringBlock[2] & 0x0F) << 1) + ((stringBlock[3] & 0x80) >> 7);
			base32Block[5] = ((stringBlock[3] & 0x7C) >> 2);
			base32Block[6] = ((stringBlock[3] & 0x03) << 3) + ((stringBlock[4] & 0xE0) >> 5);
			base32Block[7] = (stringBlock[4] & 0x1F);

			encodeString = (char *)realloc(encodeString, size + 8);
			if (!encodeString) {
				return nil;
			}

			for (short j = 0; j < (i + 2); ++j) {
				encodeString[size++] = aAlphabet[base32Block[j]];
			}

			while (i++ < 6) {
				encodeString = (char *)realloc(encodeString, size + 1);
				if (!encodeString) {
					return nil;
				}

				encodeString[size++] = '=';
			}
		}

		encodeString = (char *)realloc(encodeString, size + 1);
		if (!encodeString) {
			return nil;
		}
		encodeString[size] = '\0';

		return encodeString;
	}

	return nil;
}

+ (const char *)encodeUTF8StringInBase16:(const char *)aUTF8String lenght:(size_t)aLenght {
	if (aUTF8String && aLenght) {
		char *tmpString = (char *)malloc(aLenght);
		if (!tmpString) {
			return nil;
		}
		strncpy(tmpString, aUTF8String, aLenght);

		char *encodeString = (char *)malloc(1);

		char *base16Block = (char *)calloc(2, 2);
		char *stringBlock = (char *)calloc(1, 1);

		if (!base16Block || !stringBlock) {
			return nil;
		}

		size_t size = 0;

		while (aLenght--) {
			stringBlock[0] = *(tmpString++);

			base16Block[0] = (stringBlock[0] & 0xF0) >> 4;
			base16Block[1] = stringBlock[0] & 0x0F;

			encodeString = (char *)realloc(encodeString, size + 2);
			if (!encodeString) {
				return nil;
			}

			for (int j = 0; j < 2; ++j) {
				encodeString[size++] = base16Alphabet[base16Block[j]];
			}
		}

		encodeString = (char *)realloc(encodeString, size + 1);
		if (!encodeString) {
			return nil;
		}
		encodeString[size] = '\0';

		return encodeString;
	}
	return nil;
}

#pragma mark - 

+ (NSString *)decodeString:(NSString *)aString withOptions:(WVCodingOptions)aOptions {
	const char *decodedUTF8String = [self decodeUTF8String:aString.UTF8String lenght:aString.length withOptions:aOptions];
	if (!decodedUTF8String) {
		return nil;
	}
	NSString *decodedString = [NSString stringWithUTF8String:decodedUTF8String];
	return decodedString;
}

+ (const char *)decodeUTF8String:(const char *)aUTF8String lenght:(size_t)aLenght withOptions:(WVCodingOptions)aOptions {
	switch (aOptions) {
		case WVBase64:
			return [self decodeBase64UTF8String:aUTF8String lenght:aLenght alphabet:base64Alphabet];

		case WVSafeBase64:
			return [self decodeBase64UTF8String:aUTF8String lenght:aLenght alphabet:base64SafeAlphabet];

		case WVBase32:
			return [self decodeBase32UTF8String:aUTF8String lenght:aLenght alphabet:base32Alphabet];

		case WVExtendetBase32:
			return [self decodeBase32UTF8String:aUTF8String lenght:aLenght alphabet:base32ExtendedAlphabet];

		case WVBase16:
			return [self decodeBase16UTF8String:aUTF8String lenght:aLenght];

		default:
			return nil;
	}
}

#pragma mark - Decoding

+ (const char *)decodeBase64UTF8String:(const char *)aUTF8String lenght:(size_t)aLenght alphabet:(const char[])aAlphabet {
	if (aUTF8String && aLenght && aAlphabet) {
		char *tmpString = (char *)malloc(aLenght);
		strncpy(tmpString, aUTF8String, aLenght);
		if (!tmpString) {
			return nil;
		}

		char *decodeString = (char *)calloc(1, 1);
		if (!decodeString) {
			return nil;
		}

		char *base64Block = (char *)calloc(4, 4);
		char *stringBlock = (char *)calloc(3, 3);

		size_t size = 0;

		short i = 0;
		short j = 0;
		while (aLenght--) {
			if (tmpString[j] == '=' || !isalnum(tmpString[j])) {
				break;
			}

			base64Block[i++] = tmpString[j++];

			if (i == 4) {
				for (i = 0; i < 4; ++i) {
					for (int l = 0; l < 64; ++l) {
						if (base64Block[i] == aAlphabet[l]) {
							base64Block[i] = l;
							break;
						}
					}
				}

				stringBlock[0] = (base64Block[0] << 2) + ((base64Block[1] & 0x30) >> 4);
				stringBlock[1] = ((base64Block[1] & 0xf) << 4) + ((base64Block[2] & 0x3c) >> 2);
				stringBlock[2] = ((base64Block[2] & 0x3) << 6) + base64Block[3];

				decodeString = (char *)realloc(decodeString, size + 3);
				if (!decodeString) {
					return nil;
				}
				for (i = 0; i < 3; ++i) {
					decodeString[size++] = stringBlock[i];
				}

				i = 0;
			}
		}

		if (i > 0) {
			for (int j = i; j < 4; ++j) {
				base64Block[j] = '\0';
			}

			for (i = 0; i < 4; ++i) {
				for (int l = 0; l < 64; ++l) {
					if (base64Block[i] == aAlphabet[l]) {
						base64Block[i] = l;
						break;
					}
				}
			}

			stringBlock[0] = (base64Block[0] << 2) + ((base64Block[1] & 0x30) >> 4);
			stringBlock[1] = ((base64Block[1] & 0xf) << 4) + ((base64Block[2] & 0x3c) >> 2);
			stringBlock[2] = ((base64Block[2] & 0x3) << 6) + base64Block[3];

			decodeString = (char *)realloc(decodeString, size + (i - 1));
			if (!decodeString) {
				return nil;
			}

			for (int j = 0; j < (i - 1); ++j) {
				decodeString[size++] = stringBlock[j];
			}

			decodeString = (char *)realloc(decodeString, size + 1);
			if (!decodeString) {
				return nil;
			}

			decodeString[size] = '\0';
		}

		return decodeString;
	}

	return nil;
}

+ (const char *)decodeBase32UTF8String:(const char *)aUTF8String lenght:(size_t)aLenght alphabet:(const char[])aAlphabet {
	if (aUTF8String && aLenght && aAlphabet) {
		char *tmpString = (char *)malloc(aLenght);
		strncpy(tmpString, aUTF8String, aLenght);
		if (!tmpString) {
			return nil;
		}

		char *decodeString = (char *)calloc(1, 1);
		if (!decodeString) {
			return nil;
		}

		char *base32Block = (char *)calloc(8, 8);
		char *stringBlock = (char *)calloc(5, 5);

		size_t size = 0;

		short i = 0;
		short j = 0;
		while (aLenght--) {
			if (tmpString[j] == '=' || !isalnum(tmpString[j])) {
				break;
			}

			base32Block[i++] = tmpString[j++];

			if (i == 8) {
				for (i = 0; i < 8; ++i) {
					for (int l = 0; l < 32; ++l) {
						if (base32Block[i] == aAlphabet[l]) {
							base32Block[i] = l;
							break;
						}
					}
				}

				stringBlock[0] = (base32Block[0] << 3) + ((base32Block[1] & 0x1C) >> 2);
				stringBlock[1] = ((base32Block[1] & 0x03) << 6) + (base32Block[2] << 1) + ((base32Block[3] & 0x10) >> 4);
				stringBlock[2] = ((base32Block[3] & 0x0F) << 4) + ((base32Block[4] & 0x1E) >> 1);
				stringBlock[3] = ((base32Block[4] & 0x01) << 7) + ((base32Block[5] & 0x1F) << 2) + ((base32Block[6] & 0x18) >> 3);
				stringBlock[4] = ((base32Block[6] & 0x07) << 5) + base32Block[7];

				decodeString = (char *)realloc(decodeString, size + 5);
				if (!decodeString) {
					return nil;
				}

				for (i = 0; i < 5; ++i) {
					decodeString[size++] = stringBlock[i];
				}

				i = 0;
			}
		}

		if (i > 0) {
			for (int j = i; j < 8; ++j) {
				base32Block[j] = '\0';
			}

			for (i = 0; i < 8; ++i) {
				for (int l = 0; l < 32; ++l) {
					if (base32Block[i] == aAlphabet[l]) {
						base32Block[i] = l;
						break;
					}
				}
			}

			stringBlock[0] = (base32Block[0] << 3) + ((base32Block[1] & 0x1C) >> 2);
			stringBlock[1] = ((base32Block[1] & 0x03) << 6) + (base32Block[2] << 1) + ((base32Block[3] & 0x10) >> 4);
			stringBlock[2] = ((base32Block[3] & 0x0F) << 4) + ((base32Block[4] & 0x1E) >> 1);
			stringBlock[3] = ((base32Block[4] & 0x01) << 7) + ((base32Block[5] & 0x1F) << 2) + ((base32Block[6] & 0x18) >> 3);
			stringBlock[4] = ((base32Block[6] & 0x07) << 5) + base32Block[7];

			decodeString = (char *)realloc(decodeString, size + (i - 1));
			if (!decodeString) {
				return nil;
			}

			for (int j = 0; j < (i - 1); ++j) {
				decodeString[size++] = stringBlock[j];
			}

			decodeString = (char *)realloc(decodeString, size + 1);
			if (!decodeString) {
				return nil;
			}

			decodeString[size] = '\0';
		}

		return decodeString;
	}
	return nil;
}

+ (const char *)decodeBase16UTF8String:(const char *)aUTF8String lenght:(size_t)aLenght {
	if (aUTF8String && aLenght) {
		char *tmpString = (char *)malloc(aLenght);
		strncpy(tmpString, aUTF8String, aLenght);
		if (!tmpString) {
			return nil;
		}

		char *decodeString = (char *)calloc(1, 1);
		if (!decodeString) {
			return nil;
		}

		char *base16Block = (char *)calloc(2, 2);
		char *stringBlock = (char *)calloc(1, 1);

		size_t size = 0;

		int j = 0;
		short i = 0;
		while (aLenght--) {
			if (!isalnum(tmpString[i])) {
				break;
			}

			base16Block[i++] = tmpString[j++];
			if (i == 2) {

				for (int j = 0; j < 2; ++j) {
					for (int l = 0; l < 16; ++l) {
						if (base16Block[j] == base16Alphabet[l]) {
							base16Block[j] = l;
							break;
						}
					}
				}

				stringBlock[0] = (base16Block[0] << 4) + base16Block[1];

				decodeString = (char *)realloc(decodeString, size + 1);
				if (!decodeString) {
					return nil;
				}

				decodeString[size++] = stringBlock[0];

				i = 0;
			}
		}

		decodeString = (char *)realloc(decodeString, size + 1);
		decodeString[size] = '\0';

		return decodeString;
	}
	return nil;
}

@end
