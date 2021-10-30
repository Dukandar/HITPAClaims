//
//  OCCatch.h
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 01/10/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

#ifndef ObjecException_h
#define ObjecException_h

#import <Foundation/Foundation.h>

NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

#endif /* OCCatch_h */
