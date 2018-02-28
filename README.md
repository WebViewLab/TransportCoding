# WVTransportCoding #

## Usage ##
```
NSString *string = @"Hello World!";
```

#### Encoding ####
```
NSString *encodedString = [WVTransportCoding encodeString:string withOptions:WVBase64];
```

#### Decoding ####
```
NSString *decodedString = [WVTransportCoding decodeString:encodedString withOptions:WVBase64];
```
